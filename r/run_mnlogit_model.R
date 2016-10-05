

#################model estimation

f <- formula(choice ~ dist_log + dist_exp + dist_2 + dist + pop_log + lang.barrier + mm + rm | 0 )
#run the model for each segment
trip_models <- segments %>% 
  transmute(model = map2(trips.long, s_trips, 
                      function(t.l,t.s) mnlogit(f, t.l, choiceVar = 'alt', weights=t.s$daily.weight, ncores=8))
  )

trip_models <- trip_models %>% mutate(model_summary = map(model, ~ summary(.)))                    

data.frame(coef(trip_models$model_summary[[1]]))

#lrtest(ml.trip, ml.trip.i)

