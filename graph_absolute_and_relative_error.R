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

res1 <- read.csv("canada/data/mnlogit_results.csv") # %>% filter(origin < 4000 | dest < 4000)
res1 <- res1 %>% mutate(od_type = ifelse(origin < 4000 & dest < 4000, "II", 
                                         ifelse(origin < 4000 & dest > 4000, "IE", 
                                                ifelse(origin > 4000 & dest < 4000, "EI", "EE" 
                                                ))))
res1$od_type <- as.factor(res1$od_type)

res1$od_type <- factor(res1$od_type, levels = rev(levels(res1$od_type)))
res1 <- calculate.rel.error(con, NULL)

g1 <- ggplot(res1) +
  geom_point(data = res1, aes(x = abs_err, y = rel_err, color=od_type)) +
  geom_point(data = subset(res1, od_type == 'IE'),
             aes(x = abs_err, y = rel_err, color = od_type )) +
  xlim(0, 6000) + ylim(0, 200) + 
  labs(title="Gravity Model Errors") + labs(x="Absolute error ", y="Relative error") +
  scale_color_brewer(name="OD Pair Type",
                    labels=c("II - Intra Ontario", "IE - Outgoing", "EI - Incoming", "EE - External"), 
                     palette = 2, type = "qual")

g1
png(file="canada/docs/gravity_model_results.png",width=1400,height=800,res=150)
g1
dev.off()

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

