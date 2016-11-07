#setup

#distance, population and employment
formulas <- c(
  formula(choice ~ dist_exp | 0),
  formula(choice ~ dist_exp + population + employment | 0),
  formula(choice ~ dist_exp + pop_log + employment | 0),

#considering employment categories
formula(choice ~ dist_exp + pop_log  + 
          goods_industry + service_industry + professional_industry + employment_health + arts_entertainment + leisure_hospitality | 0 ),

formula(choice ~ dist_exp + pop_log  + 
          service_industry + professional_industry | 0 ),

formula(choice ~ dist_exp + pop_log  + 
          service_industry + professional_industry + arts_entertainment | 0 ),

formula(choice ~ dist_exp + pop_log  + 
          service_industry + professional_industry + arts_entertainment + leisure_hospitality | 0 ),

#origin destination interactions

  formula(choice ~ dist_exp + pop_log  + 
            service_industry + professional_industry + arts_entertainment + leisure_hospitality + lang.barrier | 0),
  formula(choice ~ dist_exp + pop_log  + 
            service_industry + professional_industry + arts_entertainment + leisure_hospitality + lang.barrier + mm | 0 ),
  formula(choice ~ dist_exp + pop_log  + 
            service_industry + professional_industry + arts_entertainment + leisure_hospitality + lang.barrier + rm | 0 ),
  formula(choice ~ dist_exp + pop_log  + 
            service_industry + professional_industry + arts_entertainment + leisure_hospitality + lang.barrier + mm + rm | 0 )
)

#foursquare


#seasons



#income

