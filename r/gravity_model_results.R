#gravity model analysis
library(data.table)
library(dplyr)
library(ggplot2)
gm.visit <- as.data.frame(fread("C:/models/mto/output/tripDist_visit.csv")) %>% mutate (purpose = 'Visit')
gm.leisure <- as.data.frame(fread("C:/models/mto/output/tripDist_leisure.csv")) %>% mutate (purpose = 'Leisure')
gm.business <- as.data.frame(fread("C:/models/mto/output/tripDist_business.csv")) %>% mutate (purpose = 'Business')
gm = rbind(gm.visit, gm.leisure, gm.business)

tsrc.od <- fread("C:/Users/Joe/canada/data/tsrc_lvl2_trip_counts.csv") %>% 
  filter(refyear == 2014) %>%
  mutate(purpose = tools::toTitleCase(purpose)) %>%
  group_by(lvl2_orig, lvl2_dest, purpose) %>% 
  summarise(trips = sum(trips)) %>% 
  collect() #want trips per day /need to divide by the number of years in the survey

errors <- merge(gm, tsrc.od, by.x = c('orig', 'dest', 'purpose'), by.y = c('lvl2_orig', 'lvl2_dest', 'purpose')) %>%
  rename(x = trips.x, ex = trips.y) %>%
  mutate(
    x = x / 365,
    abs.error = abs(x-ex),
    #rel.error = (x/ex)-1,
    rel.error = abs(x-ex)/ex,
    type.o = ifelse (orig < 70, 'I', 'E'),
    type.d = ifelse (dest < 70, 'I', 'E'),
    type = as.factor(paste0(type.o, type.d))
  ) %>%
  filter(type.o == 'I') %>%
  arrange(orig, dest, purpose)

head(errors)

sum(errors$x); sum(errors$ex)

g1 <- ggplot(subset(errors, !is.infinite(rel.error))) +
    geom_point(aes(x = abs.error, y = rel.error, color=type), alpha = 7/10) +
    labs(title="Gravity Model Errors") + 
    labs(x="Absolute error (# Trips) ", y="Relative error (x Trips)") +
    scale_color_brewer(name="OD Pair Type",
                       #labels=c("II - Intra Ontario", "IE - Outgoing", "EI - Incoming"), 
                       palette = 2, type = "qual") +
  #scale_y_continuous(labels = 'x') + #, limits = c(0, 25)) +
  #xlim(0, 1000) + # good comprimise, make sure to now that outliers have been removed
  #ylim(0, 1) + 
  # facet_wrap(type ~ purpose, scales = "free")
  facet_wrap(~ purpose)


 g1 
ggsave(file="C:/Users/Joe/canada/charts/gravity_model_errors.png", width = 10, height = 6)
  
  