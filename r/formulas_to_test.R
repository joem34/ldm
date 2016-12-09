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
f <-formula(choice ~ choice ~ dist_exp + I(log(attraction)) + mm_inter + mm_intra + I((purpose == "Visit")*log_medical) + I((!mm_intra)*log_hotel) + I((purpose == "Leisure")*(season == "summer")*log_outdoors) + I(mm_inter*log_sightseeing)  + I((purpose == "Leisure")*(alt == 30)*log_sightseeing) + I((purpose == "Leisure")*(season == "winter")*log_skiing) | 0)
f <-formula(choice ~ choice ~ dist_exp + I(log(attraction)) + mm_inter + mm_intra + r_intra + I((purpose == "Visit")*log_medical) + I((!mm_intra)*log_hotel) + I((purpose == "Leisure")*(season == "summer")*log_outdoors) + I(mm_inter*log_sightseeing)  + I((purpose == "Leisure")*(alt == 30)*log_sightseeing) + I((purpose == "Leisure")*(season == "winter")*log_skiing) | 0)
f <-formula(choice ~ choice ~ dist_exp + I(log(attraction)) + mm_inter + mm_intra + r_intra + lang.barrier + I((purpose == "Visit")*log_medical) + I((!mm_intra)*log_hotel) + I((purpose == "Leisure")*(season == "summer")*log_outdoors) + I(mm_inter*log_sightseeing)  + I((purpose == "Leisure")*(alt == 30)*log_sightseeing) + I((purpose == "Leisure")*(season == "winter")*log_skiing) | 0)

formulas <- c(
  #formula(choice ~ choice ~ dist_exp + I((purpose == "Visit")*log_medical) + I((!mm_intra)*log_hotel) + I((purpose == "Leisure")*(season == "summer")*log_outdoors) + I(mm_inter*log_sightseeing)  + I((purpose == "Leisure")*(alt == 30)*log_sightseeing) + I((purpose == "Leisure")*(season == "winter")*log_skiing) | 0),
  formula(choice ~ choice ~ dist_exp + I(log(attraction)) + mm_inter + mm_intra + r_intra + I((purpose == "Visit")*log_medical) + I((!mm_intra)*log_hotel) + I((purpose == "Leisure")*(season == "summer")*log_outdoors) + I(mm_inter*log_sightseeing)  + I((purpose == "Leisure")*(alt == 30)*log_sightseeing) + I((purpose == "Leisure")*(season == "winter")*log_skiing) | 0)
)

#seasons



#income

