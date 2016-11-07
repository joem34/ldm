#m logit
if (!require("pacman")) install.packages("pacman")
pacman::p_load(mnlogit, tidyr, dplyr,data.table,purrr,broom,h5, ggplot2)


#runnning different models:
 # give a combination of the category variable name, category and formula. Setup stays the same 
source("canada/R/load_tsrc_and_alternatives.R", echo = FALSE)

p.s.uq <- unique(all_trips$purpose_season)
purpose_season_options <- p.s.uq[-grep("^other.*", p.s.uq)]

#class.columns <- list("purpose" = list("visit", "leisure", "business"),
                      #"purpose_season" = as.list(purpose_season_options))

class.columns <- list("purpose" = list("visit", "leisure", "business"))


for (f in formulas) {
  run.date <- start.run()
  print (paste("processing formula:", Reduce(paste0, deparse(f)) ))
  #set up model inputs for each class
  for (class.column in names(class.columns)) {
    model.inputs <- c()
    trips = c()
    for (class in class.columns[[class.column]]) {
      source("canada/R/setup_model_input.R",echo=FALSE)
    }
    #run model for each class
    for (class in class.columns[[class.column]]) {
      
      class.ref <- paste(class.column, class, sep = "_")
      print (paste("processing class:", class.ref ))
  
      tryCatch({
        source("canada/R/run_mnlogit_model.R",echo=FALSE)
        source("canada/R/calculate_trip_distribution_and_errors.R",echo=FALSE)
        source("canada/R/save_model_results.R",echo=FALSE)
      }, error = function(e) {
        print(paste("    Error: r", e))
      })
      
      print ("    Done")
    } 
  }
}

f <- formula(choice ~ dist_exp + pop_log  + 
               goods_industry + service_industry + professional_industry + employment_health + arts_entertainment + leisure_hospitality | 0 )
source("canada/R/run_mnlogit_model.R",echo=FALSE)
