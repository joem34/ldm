results <- c(1, 10, 100, 2000, 300)
expected <- c(100, 12, 200, 400, 310)

require(ggplot2)

require(RPostgreSQL)

drv <- dbDriver("PostgreSQL")
# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database
con <- dbConnect(drv, dbname = "canada",
                 host = "localhost", port = 5432,
                 user = "postgres")

calculate.rel.error <- function(con, filter.exp){

  sql <- "select x1 as x, rel_err1 as rel_err, abs_err1 as abs_err, od_type from gravity_model_errors"
  
  if (!is.null(filter.exp)) {
    sql <- paste(sql, paste("where",filter.exp))
  }
  
  sql
  
  gravity_results <- dbGetQuery(con, sql)
  
  return(gravity_results)
  
}

require(grid)
grid.newpage()
# Create layout : nrow = 2, ncol = 2
layout <- matrix(c(1,1,1,1,2,3,4,5), 4, 2, byrow=TRUE)
palette = 5
pushViewport(viewport(layout = grid.layout(4, 2)))
# A helper function to define a region on the layout
define_region <- function(row, col){
  viewport(layout.pos.row = row, layout.pos.col = col)
}

res1 <- read.csv("Projects/canadia/data/gravity_model_results.txt", sep="\t")
res1$od_type <- factor(res1$od_type, levels = rev(levels(res1$od_type)))
palette = 2
g1 <- qplot(abs_err, rel_err, data = res1, main="Gravity Model Errors", 
     xlab="Absolute error ", ylab="Relative error", colour=od_type)  +
  geom_point() + labs(x="Absolute error ", y="Relative error") +
  scale_colour_brewer(drop=FALSE, type = "qual", palette = palette)  +
  scale_color_discrete(name="OD Pair Type",
        breaks=c("II", "IE", "EI"),
        labels=c("II - Intra Ontario", "IE - Outgoing", "EI - Incoming"))
g1

res <- calculate.rel.error(con, NULL)
g2 <- ggplot(res, aes(x = abs_err, y = rel_err, colour=od_type))+
  geom_point() +
  xlim(0, 1000) + ylim(0, 20) + 
  labs(title="All") + labs(x="absolute error ", y="relative error") +
  scale_colour_brewer(drop=FALSE, type = "qual", palette = palette) + 
  theme(legend.position="none")


res <- calculate.rel.error(con, "orig=3506")
g3 <- ggplot(res, aes(x = abs_err, y = rel_err, colour=od_type))+
  geom_point() +
  xlim(0, 3000) + ylim(0, 60) + 
  labs(title="CD3506 - Ottawa") + labs(x="absolute error ", y="relative error") +
  scale_colour_brewer(drop=FALSE, type = "qual", palette = palette) + 
  theme(legend.position="none")


res <- calculate.rel.error(con, "orig=3558")
g4 <-  ggplot(res, aes(x = abs_err, y = rel_err, colour=od_type))+
  geom_point() +
  labs(title="CD3518 - Durham") + labs(x="absolute error ", y="relative error") +
  scale_colour_brewer(drop=FALSE, type = "qual", palette = palette) + 
  theme(legend.position="none")

res <- calculate.rel.error(con, "orig=3518")
g5 <- ggplot(res, aes(x = abs_err, y = rel_err, colour=od_type))+
  geom_point() +
  labs(title="??") + labs(x="absolute error ", y="relative error") +
  scale_colour_brewer(drop=FALSE, type = "qual", palette = palette) + 
  theme(legend.position="none")

gg = list(g1,g2,g3,g4,g5)

for ( g in gg) {
  g <- g 
}

# Arrange the plots
print(gg[[1]], vp = define_region(1:2, 1:2))
print(gg[[2]], vp = define_region(3, 1))
print(gg[[3]], vp = define_region(3, 2))
print(gg[[4]], vp = define_region(4, 1))
print(gg[[5]], vp = define_region(4, 2))

