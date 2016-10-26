#m logit
if (!require("pacman")) install.packages("pacman")
pacman::p_load(mnlogit, tidyr, dplyr,data.table,purrr,broom,h5, ggplot2)


#runnning different models:
 # give a combination of the category variable name, category and formula. Setup stays the same 
source("canada/R/load_tsrc_and_alternatives.R", echo = FALSE)

p.s.uq <- unique(all_trips$purpose_season)
purpose_season_options <- p.s.uq[-grep("^other.*", p.s.uq)]

class.columns <- list("purpose" = list("visit", "leisure", "business"))
                      #"purpose_season" = as.list(purpose_season_options))

#class.columns <- list("purpose" = list("visit", "leisure", "business"))

formulas <- c(
  formula(choice ~ dist_exp + pop_log | 0),
  formula(choice ~ dist_exp + pop_log + lang.barrier | 0),
  formula(choice ~ dist_exp + pop_log + lang.barrier  + mm + rm | 0),
  formula(choice ~ dist_exp + pop_log + lang.barrier  + mm + rm + mr + rr | 0),
  formula(choice ~ dist_exp + pop_log + lang.barrier  + mm + I(min(rm+mr, 1)) | 0),
  formula(choice ~ dist_exp + pop_log + lang.barrier  + mm + I(min(rm+mr, 1)) + rr | 0)
) 


formulas_fs <- c(

  formula(choice ~ dist_exp + pop_log + fs_arts_entertainment + fs_hotel + fs_medical + fs_outdoor + fs_services + fs_skiarea | 0),
  formula(choice ~ dist_exp + pop_log + lang.barrier + fs_arts_entertainment + fs_hotel + fs_medical + fs_outdoor + fs_services + fs_skiarea | 0),
  formula(choice ~ dist_exp + pop_log + lang.barrier  + mm + rm + fs_arts_entertainment + fs_hotel + fs_medical + fs_outdoor + fs_services + fs_skiarea | 0)

)

formulas_employment <-  c(
  
  formula(choice ~ dist_exp + dist_log + pop_log + lang.barrier + employment | 0 ),  
  formula(choice ~ dist_exp + dist_log + pop_log + lang.barrier + mm + rm + employment | 0 ),  
  formula(choice ~ dist_exp + dist_log + pop_log + lang.barrier + I(log(employment)) | 0 ),  
  formula(choice ~ dist_exp + dist_log + pop_log + lang.barrier + mm + rm + I(log(employment)) | 0 )  
)

formulas_naics <- c(
  
  
  
  formula(choice ~ dist_exp + dist_log + pop_log + lang.barrier + 
            goods_industry + service_industry + professional_industry + 
            employment_health + arts_entertainment + leisure_hospitality | 0 ),
  
  formula(choice ~ dist_exp + dist_log + pop_log + lang.barrier + mm + rm  + 
            goods_industry + service_industry + professional_industry + 
            employment_health + arts_entertainment + leisure_hospitality | 0 ),
  
  formula(choice ~ dist_exp + dist_log + pop_log + lang.barrier + mm + rm  + 
            service_industry + professional_industry | 0 ),
  
  formula(choice ~ dist_exp + dist_log + pop_log + lang.barrier + mm + rm  + 
            service_industry + professional_industry + arts_entertainment | 0 ),
  
  formula(choice ~ dist_exp + dist_log + pop_log + lang.barrier + mm + rm  + 
            service_industry + professional_industry + arts_entertainment + leisure_hospitality | 0 )
)


for (f in formulas) {
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

