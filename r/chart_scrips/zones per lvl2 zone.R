library("ggplot2")
library("dplyr")
library("data.table")

zone_mapping <- fread("canada/data/zone_lvl2_mapping.csv")
cd_mapping <- fread("canada/data/zone_cd_mapping.csv")
cd_cma_mapping <- fread("canada/data/zone_cd_cma_mapping.csv") %>% transmute(cd = cd_cma_zone, number.of.zones=count)
cd_cma_mapping$type <- "CD, CMA"

zone_mapping_count <- zone_mapping %>% 
  filter (zone_lvl2 < 70) %>% 
  group_by (zone_lvl2) %>% 
  rename (cd = zone_lvl2) %>% 
  summarise(number.of.zones = n())
zone_mapping_count$type <- "CD x CMA Intersection"

cd_mapping_count <- cd_mapping %>% filter (cd < 4000) %>% group_by (cd) %>% summarise(number.of.zones = n())
cd_mapping_count$type <- "CD Only"

all_zone_methods <- rbind(zone_mapping_count, cd_cma_mapping, cd_mapping_count)
all_zone_methods$type <-factor(all_zone_methods$type, levels = c("CD Only", "CD, CMA", "CD x CMA Intersection"))

length(unique(cd_cma_mapping$cd_cma_zone))

#box plot comparison
ggplot() +
  geom_boxplot(data=all_zone_methods, aes(x = factor(type), y= number.of.zones)) +
  scale_y_continuous(breaks = seq(0,max(cd_cma_mapping$number.of.zones),100)) +
  theme_bw() +
  xlab("Aggregation Method") + ylab("Number of Zones") +
  theme(legend.position="none")

ggsave(file="C:\\Users\\Joe\\canada\\thesis\\Figures/zoning_methods.pdf", width = 5, height = 7)

boxplot(zone_mapping_count$number.of.zones)
boxplot(cd_mapping_count$number.of.zones)

#purpose and season count
tsrc_trips %>% group_by (purpose, season) %>% summarise(n(), sum(wtep))


#impact of season on destination choice
binom_t = Vectorize(function(summer, winter) { binom.test(as.integer(winter), as.integer(summer+winter), p=5/12)$p.value })

trips.by.season <- all_trips %>% 
  filter (lvl2_dest < 70) %>% 
  group_by(lvl2_dest, purpose, season) %>% 
  summarise(count = sum(wtep)) %>% 
  dcast(lvl2_dest + purpose ~ season)

trips.by.season[is.na(trips.by.season)] <- 0

#get split by season for this dataset
trips.by.season %>% group_by(purpose) %>% summarize_each(funs(sum)) %>% mutate(pc = winter/(summer+winter))
winter.split <- c("visit" = 0.4023761, "leisure" = 0.2782862, "business" = 0.4368920, "other" = 0.4380849)

season.difference.by.dest <- trips.by.season %>% 
  transmute (
    lvl2_dest,purpose,
    #p = binom_t(summer, winter),
    diff = winter/(summer+winter) - winter.split[purpose]
  ) %>% 
  dcast(lvl2_dest ~ purpose, value.var = 'diff')
season.difference.by.dest[is.na(season.difference.by.dest)] <- 0


write.csv(season.difference.by.dest, file="canada/data/season_difference_by_dest.csv", row.names=FALSE)
