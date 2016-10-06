#m logit
if (!require("pacman")) install.packages("pacman")
pacman::p_load(mnlogit, tidyr, dplyr,data.table,purrr,broom,h5)


#runnning different models:
 # give a combination of the category variable name, category and formula. Setup stays the same 
start.run <- function () {
  run.folder <- paste("model", format(Sys.time(), "%Y-%m-%d-%H%M%S"), sep = "_")
  current.run.folder <<- file.path("canada/data/mnlogit/runs", run.folder) #<<- adds to global environment
  dir.create(current.run.folder)
}


alternatives <- as.data.frame(fread("canada/data/mnlogit/mnlogit_canada_alternatives2.csv"))
alternatives <- alternatives %>% select (alt, population, employment, alt_is_metro, d.lang = speak_french)

all_trips <- as.data.frame(fread("canada/data/mnlogit/mnlogit_all_trips2.csv"))
all_trips <- all_trips %>% rename(chid = id) %>%
  mutate( 
    daily.weight = wtep / (365 * 3),
    o.lang = alternatives[lvl2_orig,]$d.lang
    purpose_season = paste(purpose, season, sep="_")
  )  #need to scale weight by number of years, and to a daily count


#load skim
f <- h5file("canada/data/mnlogit/cd_travel_times2.omx")
tt <- f["data/cd_traveltimes"]
cd_tt <- tt[]


class.columns <- list("mrdtrip2" = list("1","2","3"))

start.run()
for (class.column in names(class.columns)) {
  for (class in class.columns[[class.column]]) {

    class.ref <- paste(class.column, class, sep = "_")
    print (paste("processing class:", class.ref ))

    source("canada/R/setup_model_input.R",echo=FALSE)
    
    source("canada/R/run_mnlogit_model.R",echo=FALSE)
    
    source("canada/R/calculate_trip_distribution_and_errors.R",echo=FALSE)
    
    source("canada/R/save_model_results.R",echo=FALSE)
    
    print ("    Done")
  } 
}

