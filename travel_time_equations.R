#print travel time equations
library(RColorBrewer)
cols <- brewer.pal(3, "Set2")
curve(2.1e-01*log(x) + 5.24*exp(-0.003*x), 40, 4000, ylim=range(c(0,6)), xlab = "Travel Time",
      col=cols[1], lwd=2.5,
      ylab="a*log(tt) + b*exp(-0.003*tt)")
legend(3000,5, # places a legend at the appropriate place 
       c("Leisure","Visit", "Business"), # puts text in the legend 
       lty=c(1,1), # gives the legend appropriate symbols (lines)
       lwd=c(2.5,2.5),
       col=cols # gives the legend lines the correct color and width
) 
curve(1.4359e-01*log(x) + 4.8903e+00*exp(-0.003*x), 40, 4000, col=cols[2], lwd=2.5, axes=FALSE, add=TRUE)
curve(2.6e-01*log(x) + 6.01e+00*exp(-0.003*x), 40, 4000, col=cols[3], lwd=2.5, axes=FALSE, add=TRUE)

title("Combined Travel Time Functions by Purpose")

