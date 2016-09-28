#m logit
install.packages("mnlogit")
install.packages("tidyr")
install.packages("dplyr")
install.packages("data.table")
install.packages("purrr")
install.packages("broom")
install.packages("h5")

require(mnlogit)
require(tidyr)
require(dplyr)
require(data.table)
require(purrr)
require(broom)
library( h5 )
setwd("C:/Users/Joe/")

trips <- as.data.frame(fread("canada/data/mnlogit/mnlogit_all_trips.csv"))
trips <- trips %>% rename(purpose = mrdtrip2, chid = id)
alternatives <- as.data.frame(fread("canada/data/mnlogit/mnlogit_all_alternatives.csv"))
alternatives <- alternatives %>% rename(alt = zone_lvl2)

#load skim
f <- h5file("canada/data/mnlogit/cd_travel_times.omx")
tt <- f["data/cd_traveltimes"]
cd_tt <- tt[]
cds = h5attr(tt, "rownames")
row.names(cd_tt) <- h5attr(tt, "rownames")
colnames(cd_tt) <- h5attr(tt, "colnames")
#build an indexing of the cds/zones to speed things up when cacluating all travel times
cd_index <- vector(mode="integer", length=10000)
for (i in seq_along(cds)){
  cd_index[cds[i]] = i
}

s_trips <- trips[c(1:5)]#[1:1000,]
#filter alternatives that don't appear in the trip destinations (check by purpose too?)
valid_alternatives <- alternatives[c(1:3)] %>% filter(alt %in% unique(s_trips$lvl2_dest))
print ("excluded alternatives with no recorded trps (probably mostly US trips)")
setdiff(alternatives$alt, valid_alternatives$alt)

#need to build list of alternative choices: one for each trip, and every alternative
trips_long <- merge(x = valid_alternatives, y = s_trips, by = NULL) %>% mutate(choice = lvl2_dest == alt)

#make a vectorised version of a function to get distance between two cds, that can be applied to a column with dplyr
get_dist <- function(o,d) { cd_tt[cd_index[o], cd_index[d]] }
get_dist_v <- Vectorize(get_dist)

#compute distance #this is a bit slow
trips_long <- trips_long %>% 
  mutate(
    dist = get_dist_v(lvl2_orig, alt),
    dist_log = log(dist),
    dist_exp = exp(-dist)
  ) 

trips_long$dist_log[trips_long$dist_log<0] <- 0

#trips$retail_emp <- trips$naics_44
#trips$professional_employment <- trips$naics_51 + trips$naics_52 + trips$naics_54 + trips$naics_55

f <- formula(choice ~ dist_log + dist_exp + population | 0 )


ml.trip <- mnlogit(f, data = trips_long, choiceVar = 'alt', ncores=8) #, weights=weights)
summary(ml.trip)

trips.by.purpose <- trips %>% filter(purpose < 2) %>% group_by(purpose) %>% nest()


trip_models <- trips.by.purpose %>% mutate(model = map(data, ~ mnlogit(f, ., choiceVar = 'alt', ncores=8)))
trip_models <- trip_models %>% mutate(model_summary = map(model, ~ summary(.)))                    

trip_models$model_summary


#lrtest(ml.trip, ml.trip.i)


cor(trips$professional_employment, trips$retail_emp)

library("mnlogit")

data(Fish, package = "mnlogit")
fm <- formula(mode ~ price | income | catch)
fit <- mnlogit(fm, Fish, ncores=8) 
summary(fit)

