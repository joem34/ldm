############ Trip distribution matrix
print ("    Build trip matrix and calcuate errors")

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


#make trip dist matricies for segment
weighted.predictions = data.frame(predict(model)) * trips[[class]]$daily.weight
weighted.predictions$origin <- trips[[class]]$lvl2_orig #add origin to each row of weighted.predictions

trip.matrix <- weighted.predictions %>% 
  group_by(origin) %>% 
  summarise_each(funs(sum)) %>%
  melt(id.vars = c("origin"), variable.name = "dest", value.name="total")

#remove the x from the destination
trip.matrix$dest <- as.numeric(substring(trip.matrix$dest, 2))

#make the tsrc od counts for each category ex = expected
ex.od <- trips[[class]] %>% 
  group_by(lvl2_orig, lvl2_dest) %>%
  #need to scale weight by number of years, and to a daily count
  summarise(total = sum(daily.weight)) %>% 
  rename (origin = lvl2_orig, dest = lvl2_dest)

errors <- merge(trip.matrix, ex.od, by=c("origin", "dest"), all.x=TRUE) %>%
        rename (x = total.x, ex = total.y) %>%
        mutate(
          class.column = class.column,
          class = class,
          type = get.od.type(origin, dest),
          ex = ifelse(is.na(ex), 0, ex),
          abs_err = abs(ex - x), #calculate errors here
          rel_err = ifelse (ex > 0, abs_err / ex, 0) #if relative error would be infinity, then set it to 0 instead
        ) %>%
  select (class.column, class, origin, dest, type, x, ex, abs_err, rel_err)

#### could be useful for combining the trip matricies later
# 
# #add the category identifier to each data frame, then concatenate them all together
# category.errors <- category.errors %>% 
#   mutate(t = map2(t, category, ~ mutate(.x, category = .y)))
# combined.errors <- data.table::rbindlist(category.errors$t)
# 
# #combine trip matricies
# total.errors <- combined.errors %>% group_by (origin, dest, type) %>%
#   select(-category) %>%
#   summarise_all(sum) %>% 
#   mutate(abs_err = abs(ex - x), rel_err = abs_err / ex)


