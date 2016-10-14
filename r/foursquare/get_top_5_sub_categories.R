library(data.table)
library(dplyr)
library(ggplot2)

venues <- fread("C:/Users/Joe/canada/data/foursquare/by_category/all_venues.csv")

category_counts <- venues %>% 
  #filter(search_cat_id == "4d4b7105d754a06377d81259") %>%
  filter(checkins > 0) %>%
  group_by(search_cat_id, search_cat_name, category_name) %>% 
  summarise(count = n(), checkins = sum(checkins)) %>%
  top_n(5, wt=count)
  #arrange(desc(checkins))
write.csv(category_counts, file="C:/Users/Joe/canada/data/foursquare/top_5_sub_categories.csv", row.names = FALSE)

outdoors = c("Beach", "Other Great Outdoors", "Scenic Lookout", "Trail", 
             "Campground", "National Park", "Farm", "Island", "Mountain", 
             "Lighthouse", "Waterfall", "Nature Preserve", "Forest", "lake", "river")



#group by category, take the top 5 types for 

outdoor_venues <- venues %>% 
  filter(category_name %in% outdoors & country == 'Canada' & checkins > 1000) %>% 
  arrange(desc(checkins)) 


ggplot(outdoor_venues, aes(checkins)) + geom_histogram()

search_counts <- venues %>% 
  filter(checkins > 0 & country=="Canada") %>%
  mutate(important = ifelse(checkins > 1000, 1, 0)) %>%
  group_by(search_cat_name) %>% 
  summarise(n(), sum(important), checkins = sum(checkins)) %>%
  arrange(desc(checkins))
