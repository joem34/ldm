#m logit
if (!require("pacman")) install.packages("pacman")
pacman::p_load(mnlogit, tidyr, dplyr,data.table,purrr,broom,h5)


#runnning different models:
 # give a combination of the category variable name, category and formula. Setup stays the same 
source("canada/R/load_tsrc_and_alternatives.R", echo = FALSE)

p.s.uq <- unique(all_trips$purpose_season)
purpose_season_options <- p.s.uq[-grep("^other.*", p.s.uq)]

class.columns <- list("purpose" = list("visit", "leisure", "business"),
                      "purpose_season" = as.list(purpose_season_options))

#class.columns <- list("purpose" = list("visit", "leisure", "business"))

formulas <- c(
  formula(choice ~ dist_exp + population + lang.barrier | 0 ),
  formula(choice ~ dist_log + dist_exp + population + lang.barrier | 0 ),
  formula(choice ~ dist_log + dist_exp + population + lang.barrier + mm + rm | 0 ),
  formula(choice ~ dist_exp + pop_log + lang.barrier | 0 ),
  formula(choice ~ dist_log + dist_exp + pop_log + lang.barrier | 0 ),
  formula(choice ~ dist_log + dist_exp + pop_log + lang.barrier + mm + rm | 0 ),
  formula(choice ~ dist_log + dist_exp + dist_2 + dist + population + lang.barrier | 0 ),
  formula(choice ~ dist_log + dist_exp + dist_2 + dist + population + lang.barrier + mm + rm | 0 ),
  formula(choice ~ dist_log + dist_exp + dist_2 + dist + pop_log + lang.barrier | 0 ),
  formula(choice ~ dist_log + dist_exp + dist_2 + dist + pop_log + lang.barrier + mm + rm | 0 )
)

formulas_short <- tail(formulas, n=1)

for (f in formulas_short) {
  run.date <- start.run()
  print (paste("processing formula:", Reduce(paste0, deparse(f)) ))

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
}

