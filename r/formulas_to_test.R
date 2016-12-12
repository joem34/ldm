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
  #formula(choice ~ dist_exp + I((purpose == "Visit")*log_medical) + I((!mm_intra)*log_hotel) + I((purpose == "Leisure")*(season == "summer")*log_outdoors) + I(mm_inter*log_sightseeing)  + I((purpose == "Leisure")*(alt == 30)*log_sightseeing) + I((purpose == "Leisure")*(season == "winter")*log_skiing) | 0),
  #formula(choice ~ dist_exp + I((purpose == "Visit")*log_medical) + I((!mm_intra)*log_hotel) + I((purpose == "Leisure")*(season == "summer")*log_outdoors) + I((!mm_intra)*log_sightseeing)  + I((purpose == "Leisure")*(alt == 30)*log_sightseeing) + I((purpose == "Leisure")*(season == "winter")*log_skiing) | 0)
  formula(choice ~ dist_exp + I((purpose == "Visit")*log_medical) + log_hotel + I((purpose == "Leisure")*(season == "summer")*log_outdoors) + log_sightseeing  + I((purpose == "Leisure")*(alt == 30)*log_sightseeing) + I((purpose == "Leisure")*(season == "winter")*log_skiing) | 0),
  formula(choice ~ dist_exp + I(log(attraction)) + I((purpose != "Visit")*mm_inter) + mm_intra + r_intra + I((purpose == "Visit")*log_medical) + log_hotel + I((purpose == "Leisure")*(season == "summer")*log_outdoors) + log_sightseeing  + I((purpose == "Leisure")*(alt == 30)*log_sightseeing) + I((purpose == "Leisure")*(season == "winter")*log_skiing) | 0)
  
  )

#distance bins
f <- formula( choice ~ I((dist<40)*dist_exp) + I((dist>=40 & dist<500)*dist_exp) + I((dist>=500 & dist<1000)*dist_exp) + I((dist>=1000 & dist<3000)*dist_exp) + I((dist>=3000)*dist_exp) +
                I(log(attraction)) + I((purpose != "Visit") *      mm_inter) + mm_intra + r_intra + I((purpose == "Visit") *      log_medical) + log_hotel + I((purpose == "Leisure") * (season ==      "summer") * log_outdoors) + log_sightseeing + I((purpose ==      "Leisure") * (alt == 30) * log_sightseeing) + I((purpose ==      "Leisure") * (season == "winter") * log_skiing) | 0 )

#calibration
f <- formula( choice ~ dist_exp + I((alt == 78 | alt == 77) * dist_exp) +
                I(log(attraction)) + I((purpose != "Visit") *      mm_inter) + mm_intra + r_intra + I((purpose == "Visit") *      log_medical) + log_hotel + I((purpose == "Leisure") * (season ==      "summer") * log_outdoors) + log_sightseeing + I((purpose ==      "Leisure") * (alt == 30) * log_sightseeing) + I((purpose ==      "Leisure") * (season == "winter") * log_skiing) | 0 )



#income

