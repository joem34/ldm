#m logit
if (!require("pacman")) install.packages("pacman")
pacman::p_load(mnlogit, tidyr, dplyr,data.table,purrr,broom,h5, ggplot2)

#setwd("C:/Users/Joe/")

trips <- as.data.frame(fread("canada/data/mnlogit/mnlogit_all_trips.csv"))
trips <- trips %>% rename(purpose = mrdtrip2, chid = id)
alternatives <- as.data.frame(fread("canada/data/mnlogit/mnlogit_all_alternatives.csv"))
alternatives <- alternatives %>% rename(alt = zone_lvl2)

#load skim
f <- h5file("canada/data/mnlogit/cd_travel_times.omx")
tt <- f["data/cd_traveltimes"]
cd_tt <- tt[]
cds = f["lookup/cd"][]
#build an indexing of the cds/zones to speed things up when cacluating all travel times
cd_index <- vector(mode="integer", length=max(cds))
for (i in seq_along(cds)){
  cd_index[cds[i]] = i
}

s_trips <- trips[c(1:8)]#[1:1000,]
#filter alternatives that don't appear in the trip destinations (check by purpose too?)
valid_alternatives <- alternatives[c(1:3, ncol(alternatives))] %>% 
  filter(alt %in% unique(s_trips$lvl2_dest)) %>%
  mutate(metro = as.numeric(metro == 't')) %>% #convert to numeric
  rename(alt_is_metro = metro)

print ("excluded alternatives with no recorded trps (probably mostly US trips)")
setdiff(alternatives$alt, valid_alternatives$alt)

#compute language change of trips, alternatives (TODO; make this more robust later)
get_zone_language <- Vectorize(function(z) { if (z %in% c(9750,9752,9753,9754,9755,9756,
                                                          9757,9758,9759,9760,9761,9762,
                                                          9763,9764,9767,9768, 9770,9771,
                                                          9773,9774,9775,9776,9777,9778,
                                                          9779,9780,9781,9782,9783,9784,
                                                          9785, 9788)) { 1 } else { 0 } })

s_trips <- s_trips %>% mutate(o.lang = get_zone_language(lvl2_orig))
valid_alternatives <- valid_alternatives %>% mutate(d.lang = get_zone_language(alt)) 

#need to build list of alternative choices: one for each trip, and every alternative
trips_long <- merge(x = valid_alternatives, y = s_trips, by = NULL) %>% mutate(choice = lvl2_dest == alt)

#make a vectorised version of a function to get distance between two cds, that can be applied to a column with dplyr
get_dist_v <- Vectorize(function(o,d) { cd_tt[cd_index[o], cd_index[d]] })

#compute distance #this is a bit slow
trips_long <- trips_long %>% 
  mutate(
    dist = get_dist_v(lvl2_orig, alt),
    dist_log = log(dist),
    dist_2 = dist^2,
    dist_exp = exp(-0.003 * dist),
    lang.barrier = (o.lang+d.lang)%%2 #calculate if the origin and dest have different languages
  ) 
trips_long$dist_log[trips_long$dist_log<0] <- 0

trips_long <- trips_long %>%
  mutate(
    mm = orig_is_metro * alt_is_metro,
    rm = (1-orig_is_metro)*alt_is_metro,
    mr = (1-alt_is_metro)*orig_is_metro,
    rr = (1-orig_is_metro)*(1-alt_is_metro)
  )


#trips$retail_emp <- trips$naics_44
#trips$professional_employment <- trips$naics_51 + trips$naics_52 + trips$naics_54 + trips$naics_55


#ml.trip <- mnlogit(f, data = trips_long, choiceVar = 'alt', ncores=8) #, weights=weights)
#summary(ml.trip)

trips.by.purpose <- trips_long %>% filter(purpose < 4) %>% group_by(purpose) %>% nest()
#build weights for each purpose
weights.by.purpose <- trips %>% select(purpose, wtep) %>% filter(purpose < 4) %>% group_by(purpose) %>% nest()
trips.by.purpose$weights <- weights.by.purpose$data


f <- formula(choice ~ dist_log + dist_exp + dist_2 + dist + population + lang.barrier + mm + rm | 0 )
trip_models <- trips.by.purpose %>% mutate(model = map2(data, weights, ~ mnlogit(f, .x, choiceVar = 'alt', weights=.y$wtep, ncores=8)))

trip_models <- trip_models %>% mutate(model_summary = map(model, ~ summary(.)))                    

trip_models$model_summary

data.frame(coef(trip_models$model_summary[[1]]))

#lrtest(ml.trip, ml.trip.i)
#make trip dist matricies
results <- data.frame(purpose = c(1:3))
for (i in results$purpose) { 
  trip_columns <- (trips %>% filter(purpose == i))
  results$df[[i]] <- data.frame(predict(trip_models$model[[i]]))
  
  results$df[[i]]<- data.frame(sapply(results$df[[i]], function(x) x * trip_columns$wtep)) # multiply values by weight
  
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
tsrc.by.purpose <- trips %>% 
  filter(purpose < 4) %>%
  group_by (lvl2_orig, lvl2_dest) %>%
  summarise(total = n()) %>%
  rename (origin = lvl2_orig, dest = lvl2_dest)
errors <- merge(total_matrix, tsrc.by.purpose, by=c("origin", "dest"), all=FALSE)
errors <- errors %>% mutate(abs_err = abs(total.x - total.y),
                 rel_err = abs_err / total.y)


#write errors to file, plot error graph
write.csv(x = errors, file = "canada/data/mnlogit_results_weighted.csv")
res1 <- res1 %>% mutate(od_type = ifelse(origin < 4000 & dest < 4000, "II", 
                                         ifelse(origin < 4000 & dest > 4000, "IE", 
                                                ifelse(origin > 4000 & dest < 4000, "EI", "EE" 
                                                ))))
res1$od_type <- as.factor(res1$od_type)

res1$od_type <- factor(res1$od_type, levels = rev(levels(res1$od_type)))
g1 <- ggplot(res1) +
  geom_point(data = res1, aes(x = abs_err, y = rel_err, color=od_type)) +
  geom_point(data = subset(res1, od_type == 'II'),
             aes(x = abs_err, y = rel_err, color = od_type )) +
  xlim(0, 6000) + ylim(0, 200) + 
  labs(title="Discrete Choice Model Errors") + labs(x="Absolute error ", y="Relative error") +
  scale_color_brewer(name="OD Pair Type",
                     labels=c("II - Intra Ontario", "IE - Outgoing", "EI - Incoming", "EE - External"), 
                     palette = 2, type = "qual")

g1
#save graph as png file
png(file="canada/docs/mnlogit_results_weighted.png",width=1400,height=800,res=150)
g1
dev.off()

cor(trips$professional_employment, trips$retail_emp)

setdiff(results$df[[i]]$origin[[2]], results$df[[i]]$origin[[3]])

tm.1 <- total_matrix[[1]]

#predicting using random sampling
sample(attr(results,"dimnames")[[2]], 100, prob = results[1,], replace = TRUE)
as.numeric(names(which.max(table(results.1))))
