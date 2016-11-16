#m logit
if (!require("pacman")) install.packages("pacman")
pacman::p_load(mnlogit, tidyr, dplyr,data.table,purrr,broom,h5, ggplot2, gtools, xtable)


#runnning different models:
 # give a combination of the category variable name, category and formula. Setup stays the same 
source("canada/R/load_tsrc_and_alternatives.R", echo = FALSE)

p.s.uq <- unique(all_trips$purpose_season)
purpose_season_options <- p.s.uq[-grep("^other.*", p.s.uq)]

class.columns <- list("purpose" = list("Visit", "Leisure", "Business"))

class.k = c('Leisure' = 0.0035, 'Visit' = 0.0030, 'Business' = 0.0013)

#set up model inputs for each class
for (class.column in names(class.columns)) {
  model.inputs <- c()
  trips = c()
  for (class in class.columns[[class.column]]) {
    source("canada/R/setup_model_input.R",echo=FALSE)
  }
}

for (f in formulas) {
  run.date <- start.run()
  print (paste("processing formula:", Reduce(paste0, deparse(f)) ))
    #run model for each class
  for (class.column in names(class.columns)) {
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
    source("canada/R/output_combined_results.R", echo=FALSE)
  }
}
