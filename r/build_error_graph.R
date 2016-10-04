library(ggplot2)

error_chart <- function(error.results, save.file.name=NULL) {
  
  #plot error graph
  res1 <- res1 %>% mutate(od_type = ifelse(origin < 4000 & dest < 4000, "II", 
                                           ifelse(origin < 4000 & dest > 4000, "IE", 
                                                  ifelse(origin > 4000 & dest < 4000, "EI", "EE" 
                                                  ))))
  res1$od_type <- as.factor(res1$od_type)
  
  res1$od_type <- factor(res1$od_type, levels = rev(levels(res1$od_type)))
  g1 <- ggplot(res1) +
    geom_point(data = res1, aes(x = abs_err, y = rel_err, color=od_type)) +
    geom_point(data = subset(res1, od_type == 'II'),
               aes(x = abs_err, y = rel_err, color = od_type )) +
    xlim(0, 6000) + ylim(0, 200) + 
    labs(title="Discrete Choice Model Errors") + labs(x="Absolute error ", y="Relative error") +
    scale_color_brewer(name="OD Pair Type",
                       labels=c("II - Intra Ontario", "IE - Outgoing", "EI - Incoming", "EE - External"), 
                       palette = 2, type = "qual")
  
  if (!is.null(save.file.name)) {
    #save graph as png file
    png(file=save.file.name,width=1400,height=800,res=150)
    g1
    dev.off()
  }
  return (g1)
}
