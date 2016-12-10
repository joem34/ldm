library(data.table)
library(dplyr)
library(ggplot2)
library(reshape2)
require("RPostgreSQL")

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database
con <- dbConnect(drv, dbname = "canada",
                 host = "localhost", port = 5432,
                 user = "postgres", password = 'postgres')

zone.venue.counts <-  dbGetQuery(con, "select id, pruid, category, 
                                 count as num_venues, 
                                 sum as checkins 
                                 from foursquare.zone_category_counts;")

#filter categories
zone.venue.counts.wide <- zone.venue.counts %>% 
  group_by(id, category) %>%
  summarize(checkins = sum(checkins)) %>%
  dcast(id ~ category, value.var = 'checkins', fill = 0)


write.csv(zone.venue.counts.wide, 
          "C:/Users/Joe/canada/data/foursquare/zone_lvl2_venue_counts_wide.csv", 
          na = '0',
          row.names = FALSE)
