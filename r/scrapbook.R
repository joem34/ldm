
cor(trips[[class]]$professional_employment, trips[[class]]$retail_emp)

setdiff(results$df[[i]]$origin[[2]], results$df[[i]]$origin[[3]])

tm.1 <- total_matrix[[1]]

#predicting using random sampling
sample(attr(results,"dimnames")[[2]], 100, prob = results[1,], replace = TRUE)
as.numeric(names(which.max(table(results.1))))



formulas <- c(
  formula(choice ~ dist_exp + pop | 0),
  formula(choice ~ dist_exp + pop_log | 0),
  #employment
  formula(choice ~ dist_exp + pop_log + employment | 0),
  #naics
  formula(choice ~ dist_exp + pop_log +
            goods_industry + service_industry + professional_industry + 
            employment_health + arts_entertainment + leisure_hospitality | 0 ),  
  formula(choice ~ dist_exp + pop_log +
            service_industry + professional_industry + 
            employment_health + arts_entertainment + leisure_hospitality | 0 ),
  #lang_barrier, rm
  formula(choice ~ dist_exp + pop_log  + 
            service_industry + professional_industry + arts_entertainment + leisure_hospitality + lang.barrier | 0 ),
)

formulas <- c(
  formula(choice ~ dist_exp + dist_log + pop_log  + 
            service_industry + professional_industry + arts_entertainment + leisure_hospitality + lang.barrier + mm | 0 ),
  formula(choice ~ dist_exp + dist_log + pop_log  + 
            service_industry + professional_industry + arts_entertainment + leisure_hospitality + lang.barrier + rm | 0 ),
  formula(choice ~ dist_exp + dist_log + pop_log  + 
            service_industry + professional_industry + arts_entertainment + leisure_hospitality + lang.barrier + mm + rm | 0 ),
  formula(choice ~ dist_exp + dist_log + pop_log  + 
            service_industry + professional_industry + arts_entertainment + leisure_hospitality + lang.barrier + mm + mr | 0) #signular
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