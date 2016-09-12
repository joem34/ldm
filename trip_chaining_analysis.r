library(dtplyr)

trips <- read.csv("C:/models/mto/output/tripCounts.csv", sep = ",", header= TRUE)

w_trips = trips %>% 
  filter(tour_distance > 0) %>% 
  mutate(
  mode_length = paste(mode, trip_length, sep="_"),
  w_tour_d = tour_distance* weighted_num_trips,
  w_min_d = min_distance* weighted_num_trips,
  w_diff_d = w_tour_d - w_min_d
  )

trips_by_length = w_trips %>%
  group_by(mode_length) %>%
  summarise(total_trips = sum(num_trips), 
            w_total_trips = sum(weighted_num_trips),
            w_total_distance = sum(w_tour_d),
            avg_trip_dist_km = w_total_distance/w_total_trips) %>%
  mutate(pc_w_trips = w_total_trips/sum(w_total_trips),
         pc_w_dist = w_total_distance/sum(w_total_distance)) %>% 
  arrange(desc(pc_w_dist))

write.csv(trips_by_length, "C:/models/mto/output/tripChainingModeStats.csv", row.names=FALSE)

sum(w_trips$w_diff_d, na.rm=TRUE) / sum(w_trips$w_tour_d) 

head(trips %>% filter(tour_distance-min_distance < 0))
