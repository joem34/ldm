if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, data.table, h5, ggplot2, xtable, corrplot)

setwd("C:/Users/joe")

f2 <- h5file("canada/data/mnlogit/combined_zones_distance.omx")
tt <- f2["data/distance"]
cd_tt <- tt[]

get_dist_v <- Vectorize(function(o,d) { cd_tt[o, d] })

selected = "uisness"

#TSRC
observed.trips <- as.data.frame(fread("canada/data/mnlogit/mnlogit_trips_no_intra_province.csv")) %>%
  filter (purpose != 'other') %>%
  transmute (
    trip.purpose = purpose,
    origin = lvl2_orig,
    dest = lvl2_dest,
    wtep,
    weight = wtep/sum(wtep),
    distance = get_dist_v(origin, dest)
    
  ) 

observed.trips.filtered = observed.trips %>% filter (trip.purpose == 'Business') %>% mutate (weight = wtep/sum(wtep))
#observed.trips.filtered = observed.trips %>% filter (distance > 40) %>% mutate (weight = wtep/sum(wtep))

#model run
predicted.trips <- as.data.frame(fread("C:/models/mto/output/scenario.csv")) %>% 
  filter (international == 'false') %>% 
  transmute (
    trip.purpose = tripPurpose,
    origin = tripOriginCombinedZone,
    dest = tripDestCombinedZone,
    distance = get_dist_v(origin, dest)
    
  )  %>% filter (trip.purpose == 'business')

observed.trips.filtered %>% group_by(trip.purpose) %>% summarize(weighted.mean(distance, wtep))
predicted.trips %>% group_by(trip.purpose)  %>% summarize(mean(distance))

mean.obs <- weighted.mean(observed.trips.filtered$distance, observed.trips.filtered$wtep)
mean.pred <- mean(predicted.trips$distance)

observed.label <- paste0("observed (", round(mean.obs, 2), ")")
predicted.label <- paste0("predicted (", round(mean.pred, 2), ")")

adjust1 = 0.3
adjust2 = 1

ggplot() + 
  stat_density(data=observed.trips.filtered, aes(distance, weight=weight, linetype="Observed",  color = "Observed"), size=1.5,  geom="line", position="identity", adjust = adjust1) +
  stat_density(data=predicted.trips, aes(distance, linetype="Predicted",  color = "Predicted"),size=1,      geom="line", position="identity", adjust = adjust2) +
  theme_bw() +
  xlab ("distance") +
  #scale_x_log10() +
  #xlim(c(0,200)) +
  scale_colour_manual(name = "mean trip length (km)",
                      labels = c(observed.label, predicted.label),
                      values = c("darkgrey", "black")
  ) +   
  scale_linetype_manual(name = "mean trip length (km)",
                        labels = c(observed.label, predicted.label),
                        values = c("solid", "solid")) 




ggsave(file="canada/thesis\\Figures/calibration/m6_calibrated_business.png", width = 10, height = 5)

mean(predicted.trips$distance)
weighted.mean(observed.trips$distance, observed.trips$wtep)

#get outliers above 3000km
predicted.trips %>% 
  filter (distance < 50) %>% 
  group_by(origin, dest) %>% 
  summarize(n = n()) %>% ungroup() %>% 
  mutate(pc = n/sum(n)) %>% 
  arrange(desc(pc))


#predicted.trips %>% filter(origin >= 70) %>% summarize(n())

