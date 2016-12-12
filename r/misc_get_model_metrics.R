income.errors <- as.data.frame(fread("canada/data/mnlogit/runs/model_errors_income.csv"))


income.errors <- as.data.frame(fread("canada/data/mnlogit/runs/good/model_2016-11-17-090455/model_errors.csv"))
income.errors %>%
  group_by (class, origin, dest) %>% summarize ( x = sum(x), ex = sum(ex)) %>%
  group_by (class) %>% summarize (
    cor = cor(x, ex),
    rsme = sqrt(mean((x - ex)^2)),
    prsme = sqrt(mean((x - ex)^2))/sd(ex)
  )
