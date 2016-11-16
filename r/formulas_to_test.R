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
  formula(choice ~ dist_exp + I(log(attraction)) + mm_inter + mm_intra | 0 )
)

#foursquare
f <- formula(choice ~ dist_exp + I(log(attraction)) + mm_inter + mm_intra + r_intra | 0 )
f <-formula(choice ~ choice ~ dist_exp + I(log(attraction)) + mm_inter + mm_intra + log_fs_arts_entertainment + log_fs_hotel + log_fs_medical + log_fs_outdoor + log_fs_services + log_fs_skiarea | 0)

formulas <- c(
  formula(choice ~ fs_arts_entertainment + fs_hotel + fs_medical + fs_outdoor + fs_services + fs_skiarea | 0),
  formula(choice ~ log(fs_arts_entertainment) + log(fs_hotel) + log(fs_medical) + log(fs_outdoor) + log(fs_services) + log(fs_skiarea) | 0),
  formula(choice ~ choice ~ dist_exp + I(log(attraction)) + lang.barrier + mm + rm + fs_arts_entertainment + fs_hotel + fs_medical + fs_outdoor + fs_services + fs_skiarea | 0)

    
)


#seasons



#income

