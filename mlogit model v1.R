#m logit
install.packages("mnlogit")
install.packages("tidyr")
install.packages("dplyr")
install.packages("data.table")
install.packages("purrr")
install.packages("broom")

require(mnlogit)
require(tidyr)
require(dplyr)
require(data.table)
require(purrr)
require(broom)

trips <- as.data.frame(fread("canada/data/mnlogit/mlogit_trip_input_67.csv"))
weights <- as.data.frame(fread("canada/data/mnlogit/mlogit_trip_weights_67.csv"))

trips$dist_log <- log(trips$dist)
trips$dist_log[trips$dist_log<0] <- 0
trips$dist_exp <- exp(-trips$dist)
trips$retail_emp <- trips$naics_44
trips$professional_employment <- trips$naics_51 + trips$naics_52 + trips$naics_54 + trips$naics_55

trips.by.purpose <- trips %>% filter(purpose < 2) %>% group_by(purpose) %>% nest()


f <- formula(choice ~ exp(-dist) + retail_emp + professional_employment | 0 )

trip_models <- trips.by.purpose %>% mutate(model = map(data, ~ mnlogit(f, ., choiceVar = 'alt', ncores=8)))
trip_models <- trip_models %>% mutate(model_summary = map(model, ~ summary(.)))                    

trip_models$model_summary

ml.trip <- mnlogit(f, data = trips.by.purpose$data[[1]], choiceVar = 'alt', ncores=8) #, weights=weights)
summary(ml.trip)

#lrtest(ml.trip, ml.trip.i)


cor(trips$professional_employment, trips$retail_emp)

library("mnlogit")

data(Fish, package = "mnlogit")
fm <- formula(mode ~ price | income | catch)
fit <- mnlogit(fm, Fish, ncores=8) 
summary(fit)

