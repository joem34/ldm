#m logit
library("mlogit")

#data("Fishing", package = "mlogit")
#head(Fishing, 3)

trip_dataset <- read.csv("C:/mto_longDistanceTravel/mlogit/mlogit_trip_input_small.csv",
                         colClasses=c("choice"="logical"))

trip_dataset$weight <- trip_dataset$weight / (sum(trip_dataset$weight) / 16)

trip.long <- mlogit.data(trip_dataset, chid.var='trip_id', alt.var = "dest",
                         choice = "choice", shape = "long", drop.index = TRUE)

head(trip.long)
f <- mFormula(choice ~ exp(-dist) + attraction + production | income + education - 1 )
head(model.matrix(f, trip.long))
ml.trip <- mlogit(f, data = trip.long, weights=weight)
summary(ml.trip)


#data("Train", package = "mlogit")
#Tr <- mlogit.data(Train, shape = "wide", choice = "choice", varying = 4:11,sep = "", alt.levels = c(1, 2), id = "id")
#Tr$price <- Tr$price/100 * 2.20371
#Tr$time <- Tr$time/60
#ml.Train <- mlogit(choice ~ price + time + change + comfort | -1, Tr)
#summary(ml.Train)

data("Heating", package = "mlogit")

cor(trip_dataset$age, trip_dataset$education)

