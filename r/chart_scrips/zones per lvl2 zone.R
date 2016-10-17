library("ggplot2")
library("dplyr")
library("data.table")

zone_mapping <- fread("canada/data/zone_lvl2_mapping.csv")
cd_mapping <- fread("canada/data/zone_cd_mapping.csv")
cd_cma_mapping <- fread("canada/data/zone_cd_cma_mapping.csv")


zone_mapping_count <- zone_mapping %>% filter (zone_lvl2 < 70) %>% group_by (zone_lvl2) %>% summarise(number.of.zones = n())
cd_mapping_count <- cd_mapping %>% filter (cd < 4000) %>% group_by (cd) %>% summarise(number.of.zones = n())

ggplot() + 
  stat_ecdf(data=zone_mapping_count, aes(number.of.zones, color="Level 2 Zones")) +
  stat_ecdf(data=cd_mapping_count, aes(number.of.zones, color="Census Divisions only")) +
  stat_ecdf(data=cd_cma_mapping, aes(count, color="CD + CMA")) +
  ggtitle("number of TAZs per lvl2 zone") + 
  scale_x_continuous(breaks = seq(0,max(cd_cma_mapping$count),500)) + 
  scale_colour_manual("Zone Aggregation Methods", values = c("black", "red", "Green")) +
  ggtitle("Comparing Internal Zone Aggregation Methods") +
  labs(x="Number of Aggregated Zones", y="Cumulative Density")
  
