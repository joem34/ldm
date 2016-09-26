#m logit
library("mnlogit")

#data("Fishing", package = "mlogit")
#head(Fishing, 3)

num.alternatives = 16

trip_dataset <- read.csv("C:/mto_longDistanceTravel/mlogit/mlogit_trip_input_dummies_16.csv",
                         colClasses=c("choice"="logical"))

trip_dataset$weight <- trip_dataset$weight / (sum(trip_dataset$weight))
weights <- trip_dataset$weight[seq(1, length(trip_dataset$weight), num.alternatives)]

f <- formula(choice ~ exp(-dist) + employment | income + 0 )
ml.trip <- mnlogit(f, data = trip_dataset, choiceVar = 'alt', weights=weights, ncores=4)
summary(ml.trip)

cor(trip_dataset$employment, trip_dataset$population)

library("mnlogit")

data(Fish, package = "mnlogit")
fm <- formula(mode ~ price | income | catch)
fit <- mnlogit(fm, Fish, ncores=4) 
summary(fit)
