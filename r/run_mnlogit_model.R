#################model estimation
print ("    Model estimation")


f <- formula(choice ~ dist_log + dist_exp + dist_2 + dist + pop_log + lang.barrier + mm + rm | 0 )
#run the model for each segment
model <- mnlogit(f, trips.long, choiceVar = 'alt', weights=trips$daily.weight, ncores=8)

model_summary <- summary(model)                    

model.coefficients <- tibble::rownames_to_column(data.frame(model_summary['CoefTable']), var = "parameter") %>% 
  mutate (
    class.column = class.column,
    class = class
  ) %>%
  rename (
    coef = CoefTable.Estimate, 
    std.err = CoefTable.Std.Error, 
    t = CoefTable.t.value, 
    p = CoefTable.Pr...t..
    ) %>%
  select (class.column, class, parameter, coef, std.err, t, p)