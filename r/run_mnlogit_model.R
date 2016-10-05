

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
#make trip dist matricies
results <- data.frame(purpose = segments$purpose)
for (i in results$purpose) { 
  trip_columns <- (trips %>% filter(purpose == i))
  results$df[[i]] <- data.frame(predict(trip_models$model[[i]]))
  
  results$df[[i]]<- data.frame(sapply(results$df[[i]], function(x) x * trip_columns$daily.weight)) # multiply values by weight
  
  results$df[[i]]$origin <- trip_columns$lvl2_orig #link to origin 
  results$trip.matrx[[i]] <- results$df[[i]] %>% group_by(origin) %>% summarise_each(funs(sum))
  results$trip.matrx[[i]] <- melt(results$trip.matrx[[i]], 
                                  id.vars = c("origin"), variable.name = "dest", value.name=paste0("purpose.",toString(i)))
}  

