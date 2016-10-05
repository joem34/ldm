############ Trip distribution matrix

#make trip dist matricies for segment
results <- data.frame(category = segments$category)
for (i in results$category) { 
  trip_columns <- (trips %>% filter(category == i))
  results$df[[i]] <- data.frame(predict(trip_models$model[[i]]))
  
  results$df[[i]]<- data.frame(sapply(results$df[[i]], function(x) x * trip_columns$daily.weight)) # multiply values by weight
  
  results$df[[i]]$origin <- trip_columns$lvl2_orig #link to origin 
  results$trip.matrix[[i]] <- results$df[[i]] %>% group_by(origin) %>% summarise_each(funs(sum))
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
total.errors <- combined.errors %>% group_by (origin, dest) %>%
  summarise_all(sum) %>% 
  mutate(abs_err = abs(ex - x), rel_err = abs_err / ex)


