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

start.run()
class.column <- "mrdtrip2"
for (class in c("1","2","3")) {
  class.ref <- paste(class.column, class, sep = "_")
  print (paste("processing class ", class.ref ))
 
  source("canada/R/setup_model_input.R",echo=FALSE)
  
  source("canada/R/run_mnlogit_model.R",echo=FALSE)
  
  source("canada/R/calculate_trip_distribution_and_errors.R",echo=FALSE)
  
  source("canada/R/save_model_results.R",echo=FALSE)
  
  print ("    Done")
  
}

