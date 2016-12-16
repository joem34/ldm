
exp.only <- 2016-12-14-080328
exp.log <- 2016-12-14-080404

observed.trips <- as.data.frame(fread("canada/data/mnlogit/mnlogit_trips_no_intra_province.csv")) %>%
  transmute (
    trip.purpose = purpose,
    origin = lvl2_orig,
    dest = lvl2_dest,
    wtep,
    weight = wtep/sum(wtep),
    distance = get_dist_v(origin, dest)
  )

all.errors.pre <- as.data.frame(fread("C:/Users/Joe/canada/data/mnlogit/runs/model_2016-12-14-144517/model_errors.csv"))
density.errors.pre <- all.errors.pre  %>% transmute(origin, dest, class, distance = get_dist_v(origin, dest), x, ex)
density.errors.pre <- density.errors.pre %>% 
  #filter(class == "Visit") %>% 
  mutate (predicted = x/sum(x), observed =ex/sum(ex))
  
  
all.errors.post <- as.data.frame(fread("C:/Users/Joe/canada/data/mnlogit/runs/model_2016-12-14-100221/model_errors.csv"))
density.errors.post <- all.errors.post %>% transmute(origin, dest, class, distance = get_dist_v(origin, dest), x, ex)
density.errors.post <- density.errors.post %>% 
  filter(class == "Business") %>% 
  mutate (predicted = x/sum(x), observed =ex/sum(ex))

predicted.trips <- density.errors.post

mean.obs <- weighted.mean(predicted.trips$distance, predicted.trips$observed)
mean.pred <- weighted.mean(predicted.trips$distance, predicted.trips$predicted)

observed.label <- paste0("observed (", round(mean.obs, 2), ")")
predicted.label <- paste0("predicted (", round(mean.pred, 2), ")")

adjust = 0.3

ggplot(predicted.trips) + 
  stat_density(aes(distance, linetype="observed",  color = "observed", weight=observed), size=1,  geom="line", position="identity", adjust = adjust) +
  stat_density(aes(distance, linetype="predicted",  color = "predicted", weight=predicted),size=1.2,   geom="line", position="identity", adjust = adjust) +
  theme_bw() +
  xlab ("distance (km)") +
  #scale_x_log10() +
  #xlim(c(0,200)) +
  scale_colour_manual(name = "mean trip length (km)",
                      labels = c(observed.label, predicted.label),
                      values = c("darkgrey", "black")
  ) +   
  scale_linetype_manual(name = "mean trip length (km)",
                        labels = c(observed.label, predicted.label),
                        values = c("solid", "dotted")) 

ggsave(file="canada/thesis\\Figures/density_exp_dist.png", width = 10, height = 5)





ggplot() + 
  stat_density(data = observed.trips, aes(distance, linetype="1. observed",  color = "1. observed", weight=weight), size=1,  geom="line", position="identity") +
  stat_density(data = density.errors.pre, aes(distance, linetype="2. model m5",  color = "2. model m5", weight=predicted),size=1,   geom="line", position="identity") +
  stat_density(data = density.errors.post, aes(distance, linetype="3. m5 with log(dist)",  color = "3. m5 with log(dist)", weight=predicted),size=1,   geom="line", position="identity") +
  theme_bw() +
  xlab ("log(distance)") +
  scale_x_log10() +
  #xlim(c(0,200)) +
  scale_colour_manual(name = "Legend",
                      #     labels = c("observed", "pre-calibration", "post-calibration"),
                      values = c("darkgrey", "black", "black")
  ) +   
  scale_linetype_manual(name = "Legend",
                        #       labels = c("observed", "pre-calibration", "post-calibration"),
                        values = c("solid", "dotted", "dashed")) 

ggsave(file="canada/thesis\\Figures/log_density_dist_pre_post_calibration.png", width = 10, height = 5)


