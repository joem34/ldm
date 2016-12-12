#load leisure m3 data
m3 <- as.data.frame(fread("C:/Users/Joe/canada/data/mnlogit/runs/good/model_2016-11-17-090425/model_errors.csv"))
m3.1 <- m3 %>% filter (class == "Leisure") %>% transmute(origin, dest, err3 = (x-ex), ex)
#load leisure m5 data
m5 <- as.data.frame(fread("C:/Users/Joe/canada/data/mnlogit/runs/good/model_2016-12-10-102706/model_errors.csv"))
m5.1 <- m5 %>% filter (class == "Leisure") %>% transmute(origin, dest, err5 = (x-ex), ex)

m.35 <- merge(m3.1, m5.1, by=c("origin", "dest", "ex"))

ggplot(m.35) +
  #geom_point(aes(x = ex, y = err3, color="m3")) +
  geom_point(aes(x = ex, y = err5, color="m5")) +
  geom_segment(aes(x = ex, y = err3, xend = ex, yend = err5, colour = "Change from m3") 
#               ,arrow = arrow(length = unit(0.015, "npc"))
  ) + 
  geom_abline(intercept = 0, slope = 0, linetype="dashed") +
  guides(color=guide_legend(override.aes=list(shape=c(NA,16),linetype=c(1,0))))+
  labs(x="Observed Trips ", y="Error") +
  theme_bw() +
  ylim(c(-2000, 2000))

ggsave("C:\\Users\\Joe\\canada\\thesis\\Figures/leisure-m3-m5.png", width = 8, height = 5)



m3 <- as.data.frame(fread("C:/Users/Joe/canada/data/mnlogit/runs/good/model_2016-11-17-090425/model_errors.csv"))
m3.1 <- m3 %>% filter (origin == dest) %>% group_by(origin) %>% summarize(abs.error = (sum(x) - sum(ex)))


m3.niagara <- m3 %>% filter (class == "Leisure" & dest == 30) 
1 - m3.niagara %>% summarize (error = (sum(x) / sum(ex)))

l1 <- -21053; l2 = -20288
lt <- 2*(l2-l1)
qchisq(lt, 11-2)
aic1 <- 41201; aic2 <- 40590
exp((aic2-aic1)/2)
