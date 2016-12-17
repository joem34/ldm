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
    
    dist_exp = exp(-class.k[purpose]*dist),

    dist_log = log(dist+1),
    
    lang.barrier = (o.lang+d.lang)%%2, #calculate if the origin and dest have different languages
    mm = orig_is_metro * alt_is_metro,
    intra = (lvl2_orig == alt),
    mm_intra = mm * intra,
    mm_inter = mm * (!intra),
    r_intra = (!orig_is_metro) * intra,
    rm = (1-orig_is_metro)*alt_is_metro,
    mr = (1-alt_is_metro)*orig_is_metro,
    rr = (1-alt_is_metro)*(1-orig_is_metro),
    
    attraction = attraction,
    civic = log(attraction+1),

    log_airport = log(airport+1),
    log_hotel = log(hotel+1),
    log_medical = log(medical+1),
    log_nightlife = log(nightlife+1),
    log_outdoors = log(outdoors+1),
    log_sightseeing = log(sightseeing+1),
    log_skiing = log(skiing+1),
    
    mm_inter_no_visit = (purpose != "Visit")*mm_inter,
    mm_intra_no_business = (purpose != "Business")*mm_intra,
    visit_log_medical = (purpose == "Visit")*log_medical,
    niagara = (purpose == "Leisure")*(alt == 30)*log_sightseeing,
    
    summer_log_outdoors = (purpose == "Leisure")*(season == "summer")*log_outdoors,
    leisure_log_outdoors = (purpose == "Leisure")*log_outdoors,
    winter_log_skiing = (purpose == "Leisure")*(season == "winter")*log_skiing,
    leisure_log_skiing = (purpose == "Leisure")*log_skiing
    
  ) 
  for (j in 1:ncol(dt)) set(dt, which(is.infinite(dt[[j]])), j, 0)
  for (j in 1:ncol(dt)) set(dt, which(is.nan(dt[[j]])), j, 0)
  dt
}


#need to build list of alternative choices for each category: one for each trip, and every alternative
model.inputs[[class]] <- build_long_trips(valid.alternatives, trips[[class]])
  


