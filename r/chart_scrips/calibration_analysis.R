if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, data.table, h5, ggplot2, xtable, corrplot)

setwd("C:/Users/joe")

f2 <- h5file("canada/data/mnlogit/combined_zones_distance.omx")
tt <- f2["data/distance"]
cd_tt <- tt[]

get_dist_v <- Vectorize(function(o,d) { cd_tt[o, d] })

#TSRC
observed.trips <- as.data.frame(fread("canada/data/mnlogit/mnlogit_trips_no_intra_province.csv")) %>%
  transmute (
    trip.purpose = purpose,
    origin = lvl2_orig,
    dest = lvl2_dest,
    wtep,
    weight = wtep/sum(wtep),
    distance = get_dist_v(origin, dest)
    
  )  %>% 
  #filter (!(origin == dest & origin >= 70)) %>% 
  filter (origin < 70 | dest < 70)

#model run
predicted.trips <- as.data.frame(fread("C:/models/mto/output/trips.csv")) %>% 
  filter (international == 'false') %>% 
  transmute (
    trip.purpose = tripPurpose,
    origin = tripOriginCombinedZone,
    dest = tripDestCombinedZone,
    distance = get_dist_v(origin, dest)
    
  ) %>%
  filter (origin < 70 | dest < 70) %>%
  filter (origin < 70 & dest < 70) %>%
  filter (!(origin == dest & origin >= 70)) 
#filter (!(origin == dest))


sum((observed.trips %>% filter(origin == dest))$wtep)
nrow(predicted.trips %>% filter(origin == dest))

mean.obs <- weighted.mean(observed.trips$distance, observed.trips$wtep)
mean.pred <- mean(predicted.trips$distance)


observed.label <- paste0("Observed (", round(mean.obs, 2), ")")
predicted.label <- paste0("Predicted (", round(mean.pred, 2), ")")

ggplot() + 
  stat_density(aes(distance, linetype="Predicted",  color = "Predicted"), size=1.3,  geom="line", position="identity", data=predicted.trips) +
  stat_density(aes(distance, weight=weight, linetype="Observed",  color = "Observed"), size=1.3,  geom="line", position="identity", data=observed.trips) +
  theme_bw() +
  xlab ("log(distance)") +
  #scale_x_log10() +
  #xlim(c(0,200)) +
  scale_colour_manual(name = "Legend",
                                      labels = c(observed.label, predicted.label),
                                      values = c(1,2)
                                      ) +   
  scale_linetype_manual(name = "Legend",
                     labels = c(observed.label, predicted.label),
                     values = c("solid", "dashed"))

ggsave(file="canada/thesis\\Figures/pre_calibration.png", width = 10, height = 5)

mean(predicted.trips$distance)
weighted.mean(observed.trips$distance, observed.trips$wtep)

#get outliers above 3000km
predicted.trips %>% 
  filter (distance > 3000) %>% 
  group_by(pmax(origin, dest)) %>% 
  summarize(n = n()) %>% ungroup() %>% 
  mutate(pc = n/sum(n)) %>% 
  arrange(desc(pc))



