library(directlabels)

scenario_results <- as.data.frame(fread("canada/data/scenario/scenario_results.csv"))
scenario_results$scenario <- factor(scenario_results$scenario, as.character(scenario_results$scenario))
# Define the top and bottom of the errorbars
limits <- aes(group=purpose, ymax = max, ymin=min)

p <- ggplot(scenario_results, aes(group=purpose, color=purpose, y=average, x=scenario))

p + geom_line() + geom_errorbar(limits, width=0.25) +
  ylab("visitors") +
  theme_bw() + scale_y_continuous(limits = c(0, 7000), breaks=scales::pretty_breaks(n=8))+
  geom_dl(aes(label=purpose),method= list(dl.trans(x = x + 0.2), "last.points", cex = 0.8))+
  scale_colour_discrete(guide = 'none') 


ggsave(file="canada/thesis\\Figures/scenario_analysis.png", width = 10, height = 5)


alternatives <- as.data.frame(fread("canada/data/mnlogit/mnlogit_canada_alternatives2.csv")) %>%
  select(airport, hotel, medical, nightlife, outdoors, sightseeing, skiing)

bw = colorRampPalette(c("white", "black"))
corrplot(cor(alternatives), method="number",cl.pos="n", col=bw(100),  tl.col = "black")

ggsave(file="canada/thesis\\Figures/foursquare_correlation.png", width = 5, height = 5)
