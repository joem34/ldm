start.run <- function () {
  run.date <<- format(Sys.time(), "%Y-%m-%d-%H%M%S")
  run.folder <- paste("model", run.date, sep = "_")
  current.run.folder <<- file.path("canada/data/mnlogit/runs", run.folder) #<<- adds to global environment
  dir.create(current.run.folder)
  return (run.date)
}


alternatives <- as.data.frame(fread("canada/data/mnlogit/mnlogit_canada_alternatives3.csv"))
alternatives <- alternatives %>% 
  rename (d.lang = speak_french, pop = population) %>%
  mutate (attraction = pop + employment)

all_trips <- as.data.frame(fread("canada/data/mnlogit/mnlogit_trips_no_intra_province.csv"))
all_trips <- all_trips %>% rename(chid = id) %>%
  mutate( 
    daily.weight = wtep / (365 * 4),
    #employment = employment/1e5, #gives better coefficients
    o.lang = alternatives[lvl2_orig,]$d.lang,
    purpose_season = paste(purpose, season, sep="_")
  )  #need to scale weight by number of years, and to a daily count


#load skim
f2 <- h5file("canada/data/mnlogit/cd_travel_times2.omx")
tt <- f2["data/travel_time"]
cd_tt <- tt[]