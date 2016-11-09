library("ggplot2")
library("dplyr")
library("h5")
library("data.table")
#load skim
f <- h5file("canada/data/mnlogit/lvl2_zones_distance.omx")
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
          intra.pr = orig_pr == dest_pr,
          weight = wtep) %>%
  filter (purpose != 'other' & dist2 < 99999)


ggplot() + 
  geom_histogram(data=tsrc_trips, aes(dist2, fill=purpose, weight=wtep), bins = 30)  +
  facet_wrap(~odtype) +
  ggtitle("Histogram of distance for TSRC Trips - Observed Distance")

ggplot() + 
  geom_histogram(data=tsrc_trips, aes(distance, fill=purpose, weight=wtep), bins = 30) +
  facet_wrap(~odtype) +
  ggtitle("Histogram of distance for TSRC Trips - Estimated Distance")

#external zones, only trips between provinces
ggplot() + 
  geom_histogram(data=subset(tsrc_trips, odtype='EE'), aes(distance, fill=purpose, weight=wtep), bins = 30) +
  facet_wrap(~intra.pr) +
  ggtitle("Interprovince? for TSRC Trips - Estimated Distance")




tt.anomalies <- tsrc_trips %>% 
  filter (distance > 1000 & distance < 2000) %>% 
  group_by (lvl2_orig, lvl2_dest, odtype, distance) %>% 
  summarize(count = sum(weight)) %>% 
  arrange(desc(count))

head(tt.anomalies, 20)


tt_function <- function (x) -6314.508108*exp(-1 * x)

ggplot() +
  stat_function(data = data.frame(x=c(40, 4000)), aes(x), fun=tt_function)

#grid.arrange(histo, tt_func)


ggplot(data.frame(x=c(40, 4000)), aes(x)) + stat_function(fun=tt_function)


