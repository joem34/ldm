#m logit
library("mnlogit")

#data("Fishing", package = "mlogit")
#head(Fishing, 3)

num.alternatives = 12

trip_dataset <- read.csv("C:/mto_longDistanceTravel/mlogit/mlogit_trip_input_dummies_12.csv",
                         colClasses=c("choice"="logical"))

trip_dataset$dist_log <- log(trip_dataset$dist)
trip_dataset$dist_log[trip_dataset$dist_log<0] <- 0
trip_dataset$retail_emp <- trip_dataset$naics_44
trip_dataset$professional_employment <- trip_dataset$naics_51 + trip_dataset$naics_52 + trip_dataset$naics_54 + trip_dataset$naics_55

trip_dataset$weight <- trip_dataset$weight / (sum(trip_dataset$weight))
weights <- trip_dataset$weight[seq(1, length(trip_dataset$weight), num.alternatives)]

lesiure_trips <- subset(trip_dataset, purpose == 1 )
business_trips <- subset(trip_dataset, purpose == 2 )
visit_trips <- subset(trip_dataset, purpose == 3 )

f <- formula(choice ~ exp(-dist) + dist_log + dist + professional_employment | income + 0 )

ml.trip <- mnlogit(f, data = business_trips, choiceVar = 'alt') #, weights=weights)
summary(ml.trip)

cor(trip_dataset$retail_emp, trip_dataset$professional_employment)

library("mnlogit")

data(Fish, package = "mnlogit")
fm <- formula(mode ~ price | income | catch)
fit <- mnlogit(fm, Fish, ncores=1) 
summary(fit)
