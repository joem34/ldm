library("ggplot2")
library("dplyr")
library("h5")
library("data.table")
library(reshape2)
library(svglite)
setwd("C:/Users/Joe")
#load skim
f <- h5file("canada/data/mnlogit/combined_zones_distance.omx")
tt <- f["data/distance"]
cd_tt <- tt[]


#get od pair type
internal.zone.cutoff = 70

#function to calculate the od pair type. need to input the internal zone cutoff, assumes that internal zones are first in list
get.od.type <- function (origin, dest) {
  factor(
    ifelse(origin < internal.zone.cutoff & dest < internal.zone.cutoff, "II", 
           ifelse(origin < internal.zone.cutoff & dest >= internal.zone.cutoff, "IE", 
                  ifelse(origin >= internal.zone.cutoff & dest < internal.zone.cutoff, "EI", "EE" 
                  ))), levels = c("II", "IE", "EI", "EE")
  )
}


get_dist_v <- Vectorize(function(o,d) { cd_tt[o, d] })

tsrc_trips <- as.data.frame(fread("canada/data/mnlogit/mnlogit_trips_more_variables.csv")) %>% 
  mutate (distance = get_dist_v(lvl2_orig, lvl2_dest),
          odtype = get.od.type(lvl2_orig, lvl2_dest),
          quebec = orig_pr == 24 & dest_pr == 24 & (lvl2_orig %in% c(85, 117) | lvl2_dest %in% c(85, 117)),
          is.included = ifelse((orig_pr <= 35 & dest_pr >= 35) | (orig_pr >= 35 & dest_pr <= 35) | quebec, "Included in Model", "Excluded from Model"),
          count = "All",
          weight = wtep) %>%
  filter (purpose != 'other' & dist2 < 99999)

tsrc_trips$is.included <- factor(tsrc_trips$is.included,
                       levels = c("Included in Model", "Excluded from Model"))
mm.tsrc <- tsrc_trips %>% 
  select(id, dist2, distance, is.included) %>% 
  melt(id.vars=c("id", "is.included")) %>%
  mutate (variable = ifelse(variable == "dist2", "Observed", "Estimated"))

mm.tsrc$variable <- factor(mm.tsrc$variable,
                           levels = c("Observed", "Estimated"))

#ob vs est by include/exclude
ggplot() + 
  geom_histogram(data=subset(mm.tsrc, value < 4000), aes(value), bins = 30) +
  facet_wrap(is.included ~ variable) +
  #ggtitle("Estimated vs Observed Trip Distance") + 
  theme_bw() +
  xlab("Distance") +
  ylab("Number of Records") +
  theme(text=element_text(family="serif"))

ggsave(file="C:\\Users\\Joe\\canada\\thesis\\Figures/est_vs_obs_distance.pdf", width = 5, height = 4)


#combined ob vs est
ggplot() + 
  geom_histogram(data=subset(mm.tsrc, value < 4000), aes(value), bins = 30) +
  facet_wrap(~ variable) +
  ggtitle("Estimated vs Observed Trip Distance") + theme_bw() +
  xlab("Distance") +
  ylab("Number of Records")

