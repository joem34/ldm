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
    x = x / 365, 1,
    abs.error = x-ex,
    abs.error2 = abs(x-ex),
    rel.error = (x/ex)-1,
    rel.errorx = (x-ex)/x,
    rel.errorxy = abs(x-ex)/pmin(x,ex),
    rel.error2 = abs(x-ex)/ex,
    type.o = ifelse (orig < 70, 'I', 'E'),
    type.d = ifelse (dest < 70, 'I', 'E'),
    type = as.factor(paste0(type.o, type.d))
  ) %>%
  filter(type != 'EE') %>%
  arrange(orig, dest, purpose)

head(errors)

sum(errors$x); sum(errors$ex)

g1 <- ggplot(subset(errors, !is.infinite(rel.error))) +
    geom_point(aes(x = abs.error2, y = rel.error2, color=type), alpha = 7/10) +
    labs(title="Gravity Model Errors") + 
    labs(x="Absolute error (# Trips) ", y="Relative error (x Trips)") +
    scale_color_brewer(name="OD Pair Type",
                       #labels=c("II - Intra Ontario", "IE - Outgoing", "EI - Incoming"), 
                       palette = 2, type = "qual") +
  #scale_y_continuous(labels = 'x') + #, limits = c(0, 25)) +
  #ylim(-1,0) +
  facet_wrap( ~ purpose, scales = "free_x")
  #facet_wrap(~ purpose)


 g1 
ggsave(file="C:/Users/Joe/canada/charts/gravity_model_errors.png", width = 10, height = 6)
  
g2 <- ggplot(subset(errors, !is.infinite(rel.error))) +
  geom_point(aes(x = x, y = (x-ex)/ex, color=type), alpha = 7/10) +
  labs(title="Gravity Model Errors") + 
  labs(x="fitted values (# Trips) ", y="Residuals (# Trips)") +
  scale_color_brewer(name="OD Pair Type",
                     #labels=c("II - Intra Ontario", "IE - Outgoing", "EI - Incoming"), 
                     palette = 2, type = "qual") +
  #scale_y_continuous(labels = 'x') + #, limits = c(0, 25)) +
  
  #scale_y_log10() +
  #scale_x_log10() +
  facet_wrap( ~ purpose, scales = "free_x")
facet_wrap(~ purpose)

g2
ggsave(file="C:/Users/Joe/canada/charts/gravity_model_residuals.png", width = 10, height = 6)
