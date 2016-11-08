#setup

#distance, population and employment
formulas <- c( 
  formula(choice ~ dist_exp | 0),
  formula(choice ~ dist_exp + I(attraction) | 0),
  formula(choice ~ dist_exp + I(log(attraction)) | 0),
  formula(choice ~ dist_exp + pop + employment | 0),
  formula(choice ~ dist_exp + pop_log + employment | 0),

#considering employment categories
formula(choice ~ dist_exp + I(log(pop + service_industry + professional_industry)) | 0),
formula(choice ~ dist_exp + I(log(pop + service_industry + professional_industry + arts_entertainment)) | 0),
formula(choice ~ dist_exp + I(log(pop + service_industry + professional_industry + arts_entertainment + leisure_hospitality)) | 0),

#origin destination interactions

formula(choice ~ dist_exp + I(log(attraction)) + lang.barrier | 0 ),
formula(choice ~ dist_exp + I(log(attraction)) + lang.barrier + mm | 0 ),
formula(choice ~ dist_exp + I(log(attraction)) + lang.barrier + rm | 0 ),
formula(choice ~ dist_exp + I(log(attraction)) + lang.barrier + mr | 0 ),
formula(choice ~ dist_exp + I(log(attraction)) + lang.barrier + rr | 0 ),
formula(choice ~ dist_exp + I(log(attraction)) + lang.barrier + mm + rm | 0 )
)

#foursquare
f <- formula(choice ~ dist_exp + I(log(attraction)) | 0)

#seasons



#income

