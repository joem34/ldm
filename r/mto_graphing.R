library(ggplot2)

error_chart <- function(res1, save.file.name, x.max = NULL, y.max = NULL) {

  g1 <- ggplot(subset(res1, !is.infinite(rel_err))) +
    geom_point(aes(x = abs_err, y = rel_err, color=type), alpha = 8/10) +
    xlim(0, 6000) + ylim(0, 200) + 
    labs(title="Discrete Choice Model Errors") + 
    labs(x="Absolute error ", y="Relative error") +
    scale_color_brewer(name="OD Pair Type",
                       labels=c("II - Intra Ontario", "IE - Outgoing", "EI - Incoming", "EE - External"), 
                       palette = 2, type = "qual")
  if (!is.null(x.max) & !is.null(y.max)) {
    g1 <- g1 + xlim(0, x.max) + ylim(0, y.max)
  }
  
  ggsave(file=save.file.name, width = 10, height = 6)


}


category_error_chart <- function(res1, save.file.name, x.max = NULL, y.max = NULL) {

  g1 <- ggplot(subset(res1, !is.infinite(rel_err))) +
    geom_point(aes(x = abs_err, y = rel_err, color=type)) +
    facet_grid(category ~ .) +
    labs(title="Discrete Choice Model Errors") + 
    labs(x="Absolute error ", y="Relative error") +
    scale_color_brewer(name="OD Pair Type",
                       labels=c("II - Intra Ontario", "IE - Outgoing", "EI - Incoming", "EE - External"), 
                       palette = 2, type = "qual")
  
  if (!is.null(x.max) & !is.null(y.max)) {
    g1 <- g1 + xlim(0, x.max) + ylim(0, y.max)
  }
  
  ggsave(file=save.file.name, width = 10, height = 12)
  
  
}