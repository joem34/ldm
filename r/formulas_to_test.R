#setup

#distance, population and employment
formulas <- c( 
  #formula(choice ~ dist_exp + pop + employment | 0),
  formula(choice ~ dist_exp + I(attraction) | 0),
  formula(choice ~ dist_exp + I(log(attraction)) | 0),

  #origin destination interactions
  
  formula(choice ~ dist_exp + I(log(attraction)) + lang.barrier | 0 ),
  formula(choice ~ dist_exp + I(log(attraction)) + lang.barrier + mm | 0 ),
  formula(choice ~ dist_exp + I(log(attraction)) + lang.barrier + rm | 0 ),
  formula(choice ~ dist_exp + I(log(attraction)) + lang.barrier + mm + rm | 0 ),
  formula(choice ~ dist_exp + I(log(attraction)) + mm_inter + mm_intra | 0 ),
  formula(choice ~ dist_exp + I(log(attraction)) + mm_inter + mm_intra + r_intra | 0 )
  #formula(choice ~ dist_exp + I(log(attraction)) + mm_inter + mm_intra + r_intra | incomgr2 + 0 )
)

#foursquare
f <-formula(choice ~ dist_exp + I(log(attraction)) + mm_inter + mm_intra + I((purpose == "Visit")*log_medical) + I((!mm_intra)*log_hotel) + I((purpose == "Leisure")*(season == "summer")*log_outdoors) + I(mm_inter*log_sightseeing)  + I((purpose == "Leisure")*(alt == 30)*log_sightseeing) + I((purpose == "Leisure")*(season == "winter")*log_skiing) | 0)
f <-formula(choice ~ dist_exp + I(log(attraction)) + mm_inter + mm_intra + r_intra + I((purpose == "Visit")*log_medical) + I((!mm_intra)*log_hotel) + I((purpose == "Leisure")*(season == "summer")*log_outdoors) + I(mm_inter*log_sightseeing)  + I((purpose == "Leisure")*(alt == 30)*log_sightseeing) + I((purpose == "Leisure")*(season == "winter")*log_skiing) | 0)
f <- formula( choice ~ dist_exp + I(log(attraction)) + I((purpose != "Visit") *      mm_inter) + mm_intra + r_intra + I((purpose == "Visit") *      log_medical) + log_hotel + I((purpose == "Leisure") * (season ==      "summer") * log_outdoors) + log_sightseeing + I((purpose ==      "Leisure") * (alt == 30) * log_sightseeing) + I((purpose ==      "Leisure") * (season == "winter") * log_skiing) | 0 )

formulas <- c(
  formula(choice ~ dist_exp + civic + mm_inter_no_visit + mm_intra_no_business + r_intra + visit_log_medical + log_hotel + summer_log_outdoors + log_sightseeing  + niagara + winter_log_skiing | 0),
  formula(choice ~ dist_exp + dist_log  + civic + mm_inter_no_visit + mm_intra_no_business + r_intra + visit_log_medical + log_hotel + log_sightseeing  + niagara + summer_log_outdoors + winter_log_skiing | 0)
  )

f <-   formula(choice ~ dist_exp + civic + mm_inter_no_visit + mm_intra_no_business + r_intra + visit_log_medical + log_hotel + summer_log_outdoors + log_sightseeing  + niagara + winter_log_skiing | 0)
#calibration
f <-  formula(choice ~ dist_exp + civic + mm_inter_no_visit + mm_intra + r_intra + visit_log_medical + log_hotel + summer_log_outdoors + log_sightseeing  + niagara + winter_log_skiing | 0)


#income

