#m logit
if (!require("pacman")) install.packages("pacman")
pacman::p_load(mnlogit, tidyr, dplyr,data.table,purrr,broom,h5)

#setwd("C:/Users/Joe/")

trips <- as.data.frame(fread("canada/data/mnlogit/mnlogit_all_trips2.csv"))
trips <- trips %>% 
  rename(purpose = mrdtrip2, chid = id) %>%
  mutate(daily.weight = wtep / (365 * 3)) #need to scale weight by number of years, and to a daily count

alternatives <- as.data.frame(fread("canada/data/mnlogit/mnlogit_canada_alternatives2.csv"))
alternatives <- alternatives %>% select (alt, population, employment, alt_is_metro, d.lang = speak_french)

#load skim
f <- h5file("canada/data/mnlogit/cd_travel_times2.omx")
tt <- f["data/cd_traveltimes"]
cd_tt <- tt[]

#filter trips to only those that we want to use, and get the origin language
s_trips <- trips %>% filter(purpose < 4) %>%
  mutate(o.lang = alternatives[lvl2_orig,]$d.lang)

#get valid alternatives for each purpose, and sort them. i.e. business has no records for one of the lvl2 zones
segments <- s_trips %>% 
  group_by(purpose) %>% 
  nest() %>% 
  mutate(alt.ids = map(data, function (x) sort(unique(x$lvl2_dest)))) %>% 
  rename (s_trips = data)


#filter alternatives for each purpose
segments <- segments %>% 
  mutate (alternatives = map(alt.ids, function (x) filter(alternatives, alt %in% x)))

#make a vectorised version of a function to get distance between two cds, that can be applied to a column with dplyr
get_dist_v <- Vectorize(function(o,d) { cd_tt[o, d] })

build_long_trips <- function (a,t) {
  #merge(x = a, y = t, by = NULL) 
  a1 <- data.table(a) #hack using data tables that is alot faster than doing a merge on dataframes
  t1 <- data.table(t)
  setkeyv(a1[,k:=1], c(key(a1), "k"))
  setkeyv(t1[,k:=1], c(key(t1), "k"))
  merge(t1, a1, by=.EACHI, allow.cartesian = TRUE) %>% 
    mutate(
      choice = lvl2_dest == alt,
      dist = get_dist_v(lvl2_orig, alt),
      dist_log = log(dist),
      dist_log = ifelse (dist_log < 0, 0, dist_log),
      dist_2 = dist^2,
      dist_exp = exp(-0.003 * dist),
      pop_log = log(population),
      lang.barrier = (o.lang+d.lang)%%2, #calculate if the origin and dest have different languages
      mm = orig_is_metro * alt_is_metro,
      rm = (1-orig_is_metro)*alt_is_metro,
      mr = (1-alt_is_metro)*orig_is_metro,
      rr = (1-orig_is_metro)*(1-alt_is_metro)
    )
}

#need to build list of alternative choices for each purpose: one for each trip, and every alternative
segments <- segments %>% mutate( trips.long = map2 (alternatives, s_trips, build_long_trips) )

f <- formula(choice ~ dist_log + dist_exp + dist_2 + dist + pop_log + lang.barrier + mm + rm | 0 )
#run the model for each segment
trip_models <- segments %>% 
  transmute(model = map2(trips.long, s_trips, 
                      function(t.l,t.s) mnlogit(f, t.l, choiceVar = 'alt', weights=t.s$daily.weight, ncores=8))
  )

trip_models <- trip_models %>% mutate(model_summary = map(model, ~ summary(.)))                    

trip_models$model_summary

data.frame(coef(trip_models$model_summary[[1]]))

#lrtest(ml.trip, ml.trip.i)
#make trip dist matricies
results <- data.frame(purpose = segments$purpose)
for (i in results$purpose) { 
  trip_columns <- (trips %>% filter(purpose == i))
  results$df[[i]] <- data.frame(predict(trip_models$model[[i]]))
  
  results$df[[i]]<- data.frame(sapply(results$df[[i]], function(x) x * trip_columns$daily.weight)) # multiply values by weight
  
  results$df[[i]]$origin <- trip_columns$lvl2_orig #link to origin 
  results$trip.matrx[[i]] <- results$df[[i]] %>% group_by(origin) %>% summarise_each(funs(sum))
  results$trip.matrx[[i]] <- melt(results$trip.matrx[[i]], 
                                  id.vars = c("origin"), variable.name = "dest", value.name=paste0("purpose.",toString(i)))
}  

#combine trip matricies
total_matrix <- merge(results$trip.matrx[[1]], results$trip.matrx[[2]], all = TRUE, by=c("origin", "dest"))
total_matrix <- merge(total_matrix, results$trip.matrx[[3]], all = TRUE, by=c("origin", "dest"))
total_matrix[is.na(total_matrix)] <- 0 #convert all NA to 0
total_matrix$dest <- as.numeric(substr(total_matrix$dest, 2, 5)) #remove x from start of destination
total_matrix <- total_matrix %>% mutate(total = purpose.1 + purpose.2 + purpose.3)

#calculate errors
tsrc.by.purpose <- s_trips %>% 
  group_by (lvl2_orig, lvl2_dest) %>%
  summarise(total = sum(daily.weight)) %>% #need to scale weight by number of years, and to a daily count
  rename (origin = lvl2_orig, dest = lvl2_dest)
errors <- merge(total_matrix, tsrc.by.purpose, by=c("origin", "dest"), all=FALSE)
errors <- errors %>% mutate(abs_err = abs(total.x - total.y),
                            rel_err = abs_err / total.y)

#save results
run.folder <- paste("model", format(Sys.time(), "%Y-%m-%d-%H%M%S"), sep = "_")
current.run.folder <- file.path("canada/data/mnlogit/runs", run.folder)
dir.create(current.run.folder)

capture.output(trip_models$model_summary, file = file.path(current.run.folder, "model_summary.txt"))
#save(), file = file.path(current.run.folder, "models.dat"))
#write errors to file
write.csv(x = errors, file = file.path(current.run.folder, "errors.csv"))

#save graph
source("canada/R/mto_graphing.R")
error.plot <- error_chart(errors,file.path(current.run.folder, "error_chart.png"))
