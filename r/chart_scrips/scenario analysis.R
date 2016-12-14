f <- formula(choice ~ dist_exp + dist_log  + civic + mm_inter_no_visit + mm_intra_no_business + r_intra + visit_log_medical + log_hotel + log_sightseeing  + niagara + summer_log_outdoors + winter_log_skiing | 0)
source("canada/R/load_tsrc_and_alternatives.R", echo = FALSE)

p.s.uq <- unique(all_trips$purpose_season)
purpose_season_options <- p.s.uq[-grep("^other.*", p.s.uq)]

class.columns <- list("purpose" = list("Visit", "Leisure", "Business"))

class.k = c('Visit' = 0.0030, 'Leisure' = 0.0035, 'Business' = 0.0013)

#filter by income
#all_trips <- all_trips %>% filter(incomgr2 >= 3 & incomgr2 <= 4)

#set up model inputs for each class
for (class.column in names(class.columns)) {
  model.inputs <- c()
  trips = c()
  for (class in class.columns[[class.column]]) {
    source("canada/R/setup_model_input.R",echo=FALSE)
  }
}

models <- c()
for (class in class.columns[[class.column]]) {
  print ("    Model estimation")
  models[[class]] <- mnlogit(f, model.inputs[[class]], choiceVar = 'alt', weights=trips[[class]]$daily.weight, ncores=8)
}

#load scenario
alternatives <- as.data.frame(fread("canada/data/mnlogit/mnlogit_canada_alternatives-scenario.csv"))
alternatives <- alternatives %>% 
  rename (d.lang = speak_french, pop = population) %>%
  mutate (attraction = pop + employment)


#set up model inputs for each class again for scenario
for (class.column in names(class.columns)) {
  model.inputs <- c()
  trips = c()
  for (class in class.columns[[class.column]]) {
    source("canada/R/setup_model_input.R",echo=FALSE)
  }
}
for (class in class.columns[[class.column]]) {
  print(class)
  scenario.inputs <- c()
  model <- models[[class]]
  scenario.inputs[[class]] <- model.inputs[[class]] %>% select(choice, dist_exp, dist_log, civic, mm_inter_no_visit,
                                                              mm_intra, r_intra, visit_log_medical, 
                                                              log_hotel, log_sightseeing, niagara, 
                                                              summer_log_outdoors, winter_log_skiing, alt)
  
#  scenario.inputs[[class]] <- mnlogit(f, model.inputs[[class]], choiceVar = 'alt', weights=trips[[class]]$daily.weight, ncores=8)
  
  
  weighted.predictions = data.frame(predict(model, newdata= scenario.inputs[[class]] , choiceVar = 'alt' )) * trips[[class]]$daily.weight
  weighted.predictions$origin <- trips[[class]]$lvl2_orig #add origin to each row of weighted.predictions
  
  trip.matrix <- weighted.predictions %>%
    group_by(origin) %>% 
    summarise_each(funs(sum)) %>%
    melt(id.vars = c("origin"), variable.name = "dest", value.name="total")  
  
  #remove the x from the destination
  trip.matrix$dest <- as.numeric(substring(trip.matrix$dest, 2))
  
  
  
  
  print(trip.matrix %>% filter(dest == 24) %>% summarise(sum(total)))
}

