#density plot for population + employment

install.packages("corrplot")
library(corrplot)

alternatives <- as.data.frame(fread("canada/data/mnlogit/mnlogit_canada_alternatives3.csv"))
attach(alternatives)

m <- alternatives %>%
           select("Population" = population, 
                  "Total Employment" = employment, 
                  "Goods Industry" = goods_industry, 
                  "Service Industry" = service_industry, 
                  "Professional" = professional_industry,
                  "Employment & Health" = employment_health, 
                  "Arts & Entertainment" = arts_entertainment, 
                  "Leisure & Hospitality" = leisure_hospitality)
corrplot(cor(m), col=colorRampPalette(c("white","black"))(100), tl.col="black", method="number", cl.pos="n")

cor(log(population), log(employment))

plot(density(population+employment), main="", xlab = "Population + Employment")