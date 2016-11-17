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
  group_by(lvl2_orig, lvl2_dest, orig_pr, dest_pr) %>%
  #need to scale weight by number of years, and to a daily count
  summarise(total = sum(daily.weight)) %>% 
  rename (origin = lvl2_orig, dest = lvl2_dest)

od.filter <- function( orig_pr, lvl2_orig, dest_pr, lvl2_dest ){
  quebec.exceptions = lvl2_orig != lvl2_dest & 
    orig_pr == 24 & dest_pr == 24 & 
    (lvl2_orig %in% c(85, 117) | lvl2_dest %in% c(85, 117))
  is.included = (orig_pr <= 35 & dest_pr >= 35) | (orig_pr >= 35 & dest_pr <= 35) | quebec.exceptions
  return (is.included)
            
}

errors <- merge(trip.matrix, ex.od, by=c("origin", "dest"), all.x=TRUE) %>%
        rename (x = total.x, ex = total.y) %>%
        mutate(
          class.column = class.column,
          class = class,
          type = get.od.type(origin, dest),
          ex = ifelse(is.na(ex), 0, ex),
          abs.error = abs(ex - x), #calculate errors here
          max.rel.error = abs(x-ex)/pmin(x,ex),
          max.rel.error = ifelse(is.infinite(max.rel.error), 0, max.rel.error)
        ) %>%
  filter(od.filter(orig_pr, origin, dest_pr, dest)) %>%
  select (class.column, class, origin, dest, type, x, ex, abs.error, max.rel.error)

