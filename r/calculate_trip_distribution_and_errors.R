############ Trip distribution matrix

#get od pair type
internal.zone.cutoff = 70

#function to calculate the od pair type. need to input the internal zone cutoff, assumes that internal zones are first in list
get.od.type <- function (origin, dest) {
  factor(
    ifelse(origin < internal.zone.cutoff & dest < internal.zone.cutoff, "II", 
           ifelse(origin < internal.zone.cutoff & dest > internal.zone.cutoff, "IE", 
                  ifelse(origin > internal.zone.cutoff & dest < internal.zone.cutoff, "EI", "EE" 
                  ))), levels = c("II", "IE", "EI", "EE")
  )
}


#make trip dist matricies for segment
results <- segments %>% select(category, s_trips)

results <- segments %>% transmute(
  category = category,
  s_trips = s_trips,
  weighted.predictions = map2(model, s_trips, function(m, t) data.frame(predict(m)) * t$daily.weight)
)
#add origin to each row of weighted.predictions
for (i in as.numeric(results$category)) { 
  results$weighted.predictions[[i]]$origin <- segments$s_trips[[i]]$lvl2_orig
  
  results$trip.matrix[[i]] <- results$weighted.predictions[[i]] %>% group_by(origin) %>% summarise_each(funs(sum))
  results$trip.matrix[[i]] <- melt(results$trip.matrix[[i]], 
                                  id.vars = c("origin"), variable.name = "dest", value.name="total")
  #remove the x from the destination
  results$trip.matrix[[i]]$dest <- as.numeric(substring(results$trip.matrix[[i]]$dest, 2))
}  
########### Calculate segment errors
results$s_trips <- segments$s_trips

#make the tsrc od counts for each category ex = expected
results <- results %>% 
  mutate ( ex.od = map(s_trips, ~ group_by(., lvl2_orig, lvl2_dest) %>%
                                                   #need to scale weight by number of years, and to a daily count
                                                   summarise(total = sum(daily.weight)) %>% 
                                                   rename (origin = lvl2_orig, dest = lvl2_dest)
                                          )
           )

category.errors <- results %>% 
  select(category, trip.matrix, ex.od) %>%
  mutate(
    t = map2(trip.matrix, ex.od, function(x, ex) {
      merge(x, ex, by=c("origin", "dest"), all.x=TRUE) %>%
        rename (x = total.x, ex = total.y) %>%
        mutate(
          type = get.od.type(origin, dest),
          ex = ifelse(is.na(ex), 0, ex),
          abs_err = abs(ex - x), #calculate errors here
          rel_err = abs_err / ex)
    }
  ))

#add the category identifier to each data frame, then concatenate them all together
category.errors <- category.errors %>% 
  mutate(t = map2(t, category, ~ mutate(.x, category = .y)))
combined.errors <- data.table::rbindlist(category.errors$t)

#combine trip matricies
total.errors <- combined.errors %>% group_by (origin, dest, type) %>%
  select(-category) %>%
  summarise_all(sum) %>% 
  mutate(abs_err = abs(ex - x), rel_err = abs_err / ex)


