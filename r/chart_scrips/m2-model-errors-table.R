m2.errors <- as.data.frame(fread("canada/data/mnlogit/runs/model_2016-11-17-090441/model_errors.csv"))

m2.errors <- m2.errors %>% 
  group_by(origin, dest, type) %>%
  summarize(x = sum(x), ex = sum(ex)) %>%
  mutate(abs.error = abs(x-ex), max.rel.error=abs.error/pmin(x,ex)) %>%
  collect() %>%
  select(Origin = origin, Destination = dest, Type = type, "Predicted" = x, "Observed" = ex, "Absolute Error" = abs.error, "Max Rel. Error" = max.rel.error) %>%
  arrange(desc(`Absolute Error`))

m2.20 <- head(m2.errors, 20)

print.xtable(
  xtable(m2.20, digits=c(0,0,0,0,2,2,2,2)), 
  type="latex",
  booktabs = TRUE,
  #file="C:\\Users\\Joe\\canada\\thesis\\Figures/m2_model_errors.tex")
)

                           