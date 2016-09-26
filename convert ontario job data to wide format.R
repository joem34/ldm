library("reshape2")
library("dplyr")
jobs <- read.csv("C:/mto_longDistanceTravel/SocioeconomicData/Jobs_QT_Ontario.csv")
jobs_by_zone <- jobs %>% group_by(ProvID, Naics2) %>% summarise(count=n())

molten = melt(jobs, id = c("X", "ProvID", "Naics2", "EmpID"))
jobs_wide <- dcast(molten, ProvID ~ Naics2, length)

write.csv(file = "C:/mto_longDistanceTravel/SocioeconomicData/Jobs_QT_Ontario_wide.csv", x=jobs_wide, row.names = FALSE )
