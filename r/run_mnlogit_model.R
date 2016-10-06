

#################model estimation

f <- formula(choice ~ dist_log + dist_exp + dist_2 + dist + pop_log + lang.barrier + mm + rm | 0 )
#run the model for each segment
segments <- segments %>% 
  mutate(model = map2(trips.long, s_trips, 
                      function(t.l,t.s) mnlogit(f, t.l, choiceVar = 'alt', weights=t.s$daily.weight, ncores=8))
  )

segments <- segments %>% mutate(model_summary = map(model, ~ summary(.)))                    

data.frame(coef(segments$model_summary[[1]]))

#lrtest(ml.trip, ml.trip.i)

#get the coefficients into a dataframe in a nice format
category.coefficients <- segments %>% 
  transmute(coefs = map2(model_summary, category, 
                         ~ tibble::rownames_to_column(data.frame(coef(.x)), var = "parameter") %>% 
                           mutate (
                             category = .y
                          ) )
            ) %>% 
  unnest() %>% dcast( category ~ parameter, value.var="coef..x.")
