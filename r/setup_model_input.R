############### Setup Model Input

print (paste0("    Setup input files - ", class))

#use underscore and then quoted arguments to filter by a string
trips[[class]] <- all_trips %>% 
  filter_(paste0(class.column, " == '", class, "'")) # %>%
  #filter (lvl2_orig < 70 | lvl2_dest < 70) #try again with external inter-province trips
  

  

#from here on it varies by 

#get valid alternatives for each category, and sort them. i.e. business has no records for one of the lvl2 zones
alt.ids <- unique(trips[[class]]$lvl2_dest)

#filter alternatives for each category
valid.alternatives <- filter(alternatives, alt %in% alt.ids) %>%
  mutate (
    alt_is_metro = ifelse(alt_is_metro == 1, 1, 0) #2 means remainer of state, we only want 1)
  )

#make a vectorised version of a function to get distance between two cds, that can be applied to a column with dplyr
get_dist_v <- Vectorize(function(o,d) { cd_tt[o, d] })

build_long_trips <- function (a,t) {
  #merge(x = a, y = t, by = NULL) 
  a1 <- data.table(a) #hack using data tables that is alot faster than doing a merge on dataframes
  t1 <- data.table(t)
  setkeyv(a1[,k:=1], c(key(a1), "k"))
  setkeyv(t1[,k:=1], c(key(t1), "k"))
  dt <- merge(t1, a1, by=.EACHI, allow.cartesian = TRUE) %>% 
  mutate(
    choice = lvl2_dest == alt,
    dist = get_dist_v(lvl2_orig, alt),
    dist_log = log(dist),
    dist_log = ifelse (dist_log < 0, 0, dist_log),
    dist_2 = dist^2,
    dist_exp = exp(-class.k[purpose]*dist),
    pop_log = log(pop),
    lang.barrier = (o.lang+d.lang)%%2, #calculate if the origin and dest have different languages
    mm = orig_is_metro * alt_is_metro,
    intra = (lvl2_orig == alt),
    mm_intra = mm * intra,
    mm_inter = mm * (!intra),
    rm = (1-orig_is_metro)*alt_is_metro,
    mr = (1-alt_is_metro)*orig_is_metro,
    rr = (1-alt_is_metro)*(1-orig_is_metro),
    log_fs_arts_entertainment = log(fs_arts_entertainment),
    log_fs_hotel = log(fs_hotel),
    log_fs_medical = log(fs_medical),
    log_fs_outdoor = log(fs_outdoor),
    log_fs_services = log(fs_services),
    log_fs_skiarea = log(fs_skiarea)
  ) 
  for (j in 1:ncol(dt)) set(dt, which(is.infinite(dt[[j]])), j, 0)
  dt
}

#need to build list of alternative choices for each category: one for each trip, and every alternative
model.inputs[[class]] <- build_long_trips(valid.alternatives, trips[[class]])
  


