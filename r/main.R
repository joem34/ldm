#m logit
if (!require("pacman")) install.packages("pacman")
pacman::p_load(mnlogit, tidyr, dplyr,data.table,purrr,broom,h5)

source("canada/R/setup_model_input.R",echo=TRUE)

source("canada/R/run_mnlogit_model.R",echo=TRUE)

source("canada/R/calculate_trip_distribution_and_errors.R",echo=TRUE)

source("canada/R/save_model_results.R",echo=TRUE)