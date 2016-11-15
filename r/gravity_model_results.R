#gravity model analysis
library(data.table)
library(dplyr)
library(ggplot2)
gm.visit <- as.data.frame(fread("C:/models/mto/output/tripDist_visit.csv")) %>% mutate (purpose = 'Visit')
gm.leisure <- as.data.frame(fread("C:/models/mto/output/tripDist_leisure.csv")) %>% mutate (purpose = 'Leisure')
gm.business <- as.data.frame(fread("C:/models/mto/output/tripDist_business.csv")) %>% mutate (purpose = 'Business')
gm = rbind(gm.visit, gm.leisure, gm.business)

od.filter <- function( orig_pr, lvl2_orig, dest_pr, lvl2_dest ){
  quebec.exceptions = lvl2_orig != lvl2_dest & 
    orig_pr == 24 & dest_pr == 24 & 
    (lvl2_orig %in% c(85, 117) | lvl2_dest %in% c(85, 117))
  is.included = (orig_pr <= 35 & dest_pr >= 35) | (orig_pr >= 35 & dest_pr <= 35) | quebec.exceptions
  return (is.included)
  
}

tsrc.od <- fread("canada/data/mnlogit/mnlogit_trips_no_intra_province.csv") %>% 
  mutate(purpose = tools::toTitleCase(purpose)) %>%
  group_by(orig_pr, lvl2_orig, dest_pr, lvl2_dest, purpose) %>% 
  summarise(trips = sum(wtep)) %>% 
  collect() #want trips per day /need to divide by the number of years in the survey

errors <- merge(gm, tsrc.od, by.x = c('orig', 'dest', 'purpose'), by.y = c('lvl2_orig', 'lvl2_dest', 'purpose')) %>%
  rename(x = trips.x, ex = trips.y) %>%
  mutate(
    x2 = x*2,
    ex = ex / (365 * 4),
    abs.error = abs(x-ex),
    rel.errorx = abs(x-ex)/(x+ex),
    rel.errory = abs(x-ex)/pmin(x,ex),
    rel.errory = ifelse(is.infinite(rel.errory), 0, rel.errory),
    rel.error2 = abs(x-ex)/ex,
    type.o = ifelse (orig < 70, 'I', 'E'),
    type.d = ifelse (dest < 70, 'I', 'E'),
    type = as.factor(paste0(type.o, type.d))
  ) %>%
  filter(od.filter(orig_pr, orig, dest_pr, dest)) %>%
  arrange(orig, dest, purpose)

head(errors)

sum(errors$x); sum(errors$ex)

g1 <- ggplot(errors) +
    geom_point(aes(abs.error, rel.errory)) +
    labs(x="Absolute error (# Trips) ", y="Maximum relative error (x Trips)") +
  theme_bw() +
    scale_color_brewer(name="OD Pair Type",
                       #labels=c("II - Intra Ontario", "IE - Outgoing", "EI - Incoming"), 
                       palette = 2, type = "qual") +
  #scale_y_continuous(labels = 'x') + #, limits = c(0, 25)) +
  #ylim(-1,0) +
  facet_wrap( ~ purpose, scales = "free_x")
  #facet_wrap(~ purpose)


 g1 
ggsave(file="C:\\Users\\Joe\\canada\\thesis\\Figures/gravity_model_errors.png", width = 10, height = 5)
  
g2 <- ggplot(errors) +
  geom_point(aes(ex,x-ex)) +
  labs(x="Observed Trips ", y="Error") +
  theme_bw() +
  facet_wrap(~ purpose) + 
  geom_abline(intercept = 0, slope = 0, linetype="dashed")
g2


ggsave(file="C:\\Users\\Joe\\canada\\thesis\\Figures/gravity_model_residuals.png", width = 10, height = 5)


errors %>% group_by(purpose) %>% summarise ( rmse = sqrt(mean((x - ex)^2)), trips = sum(ex), r2 = cor(x, ex))

