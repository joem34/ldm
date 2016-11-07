#################model estimation
print ("    Model estimation")


#run the model for each segment
model <- mnlogit(f, model.inputs[[class]], choiceVar = 'alt', weights=trips[[class]]$daily.weight, ncores=8)

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