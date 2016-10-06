############### Setup Model Input

print ("    Setup input files")

#use underscore and then quoted arguments to filter by a string
trips <- all_trips %>% filter_(paste0(class.column, " == '", class, "'")) 
  

#from here on it varies by 

#get valid alternatives for each category, and sort them. i.e. business has no records for one of the lvl2 zones
alt.ids <- unique(trips$lvl2_dest)

#filter alternatives for each category
valid.alternatives <- filter(alternatives, alt %in% alt.ids)

#make a vectorised version of a function to get distance between two cds, that can be applied to a column with dplyr
get_dist_v <- Vectorize(function(o,d) { cd_tt[o, d] })

build_long_trips <- function (a,t) {
  #merge(x = a, y = t, by = NULL) 
  a1 <- data.table(a) #hack using data tables that is alot faster than doing a merge on dataframes
  t1 <- data.table(t)
  setkeyv(a1[,k:=1], c(key(a1), "k"))
  setkeyv(t1[,k:=1], c(key(t1), "k"))
  merge(t1, a1, by=.EACHI, allow.cartesian = TRUE) %>% 
    mutate(
      choice = lvl2_dest == alt,
      dist = get_dist_v(lvl2_orig, alt),
      dist_log = log(dist),
      dist_log = ifelse (dist_log < 0, 0, dist_log),
      dist_2 = dist^2,
      dist_exp = exp(-0.003 * dist),
      pop_log = log(population),
      lang.barrier = (o.lang+d.lang)%%2, #calculate if the origin and dest have different languages
      mm = orig_is_metro * alt_is_metro,
      rm = (1-orig_is_metro)*alt_is_metro,
      mr = (1-alt_is_metro)*orig_is_metro,
      rr = (1-orig_is_metro)*(1-alt_is_metro)
    )
}

#need to build list of alternative choices for each category: one for each trip, and every alternative
trips.long <- build_long_trips(valid.alternatives, trips)


