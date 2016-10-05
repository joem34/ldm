############### Setup Model Input

trips <- as.data.frame(fread("canada/data/mnlogit/mnlogit_all_trips2.csv"))
trips <- trips %>% 
  rename(category = mrdtrip2, chid = id) %>%
  mutate(daily.weight = wtep / (365 * 3)) #need to scale weight by number of years, and to a daily count

alternatives <- as.data.frame(fread("canada/data/mnlogit/mnlogit_canada_alternatives2.csv"))
alternatives <- alternatives %>% select (alt, population, employment, alt_is_metro, d.lang = speak_french)

#load skim
f <- h5file("canada/data/mnlogit/cd_travel_times2.omx")
tt <- f["data/cd_traveltimes"]
cd_tt <- tt[]

#filter trips to only those that we want to use, and get the origin language
s_trips <- trips %>% filter(category < 4) %>%
  mutate(o.lang = alternatives[lvl2_orig,]$d.lang)

#get valid alternatives for each category, and sort them. i.e. business has no records for one of the lvl2 zones
segments <- s_trips %>% 
  group_by(category) %>% 
  nest() %>% 
  mutate(alt.ids = map(data, function (x) sort(unique(x$lvl2_dest)))) %>% 
  rename (s_trips = data)


#filter alternatives for each category
segments <- segments %>% 
  mutate (alternatives = map(alt.ids, function (x) filter(alternatives, alt %in% x)))

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
segments <- segments %>% mutate( trips.long = map2 (alternatives, s_trips, build_long_trips) )


