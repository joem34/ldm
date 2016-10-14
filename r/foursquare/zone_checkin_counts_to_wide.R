library(data.table)
library(dplyr)
library(ggplot2)
library(reshape2)

zone.venue.counts <- fread("C:/Users/Joe/canada/data/foursquare/zone_lvl2_venue_counts.csv")

#filter categories
zone.venue.counts.wide <- zone.venue.counts %>% 
  filter (search_cat_name %in% c('outdoors', 'ski area', 'arts and entertainment', 
                                 'shops and services', 'Medical Center and services','Hotel and services')) %>%
  group_by(id, search_cat_name) %>%
  summarize(checkins = sum(checkins)) %>%
  dcast(id ~ search_cat_name, value.var = 'checkins')

write.csv(zone.venue.counts.wide, 
          "C:/Users/Joe/canada/data/foursquare/zone_lvl2_venue_counts_wide.csv", 
          na = '0',
          row.names = FALSE)
