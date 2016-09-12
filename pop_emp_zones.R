library(data.table)
library(dplyr)
working.dir = "C:/mto_longDistanceTravel/"
setwd(working.dir)

#collect employment by zone, and output
emp.data <- read.csv(paste0("SocioeconomicData/Jobs_QT_Ontario.csv"), sep = ",", header= TRUE)
trip.gen <- read.csv(paste0("tripGeneration/zones.csv"))
zone.emp <- emp.data %>% group_by(ProvID) %>% summarize(employment = n())

#population figures are already included in trip.gen, thanks carlos  
#emp.pop.total <- merge(zone.pop, zone.emp , by.x = "ID", by.y = "ProvID", all = TRUE)
gravity.model.inputs <- merge(trip.gen, zone.emp,  by.x = "zone", by.y = "ProvID", all = TRUE)

#set all na to zero
gravity.model.inputs[is.na(gravity.model.inputs)] <- 0

setcolorder(gravity.model.inputs, c("zone", "population", "employment", 
                                    "domesticVisit", "domesticBusiness", "domesticLeisure", 
                                    "internationalVisit","internationalBusiness","internationalLeisure"))

write.csv(gravity.model.inputs, paste("ontario_zone_stats.csv"), row.names = FALSE)
