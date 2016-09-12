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

  sql <- "select * from gravity_model_errors"
  
  if (!is.null(filter.exp)) {
    sql <- paste(sql, paste("where",filter.exp))
  }
  
  sql
  
  gravity_results <- dbGetQuery(con, sql)
  
  return(gravity_results)
  
}

layout <- matrix(c(1,1,1,1,2,3,4,5), 4, 2, byrow=TRUE)

res1 <- calculate.rel.error(con, NULL)
g1 <- qplot(abs_err, rel_err, data = res1, main="All lvl2 zones", 
     xlab="absolute error ", ylab="relative error", colour=od_type)  +
  geom_point() +
  scale_color_manual(values=c("II"="red", "IE"="blue", "EI"="green"))


res <- calculate.rel.error(con, NULL)
g2 <- qplot(abs_err, rel_err, data = res, main="All lvl2 zones", 
     xlab="absolute error ", ylab="relative error", colour=od_type, xlim=c(0, 3000), ylim=c(0, 60))

res <- calculate.rel.error(con, "orig=3506")
g3 <-qplot(abs_err, rel_err, data = res, main="CD3506 - Ottawa", 
     xlab="absolute error ", ylab="relative error", colour=od_type)

res <- calculate.rel.error(con, "orig=3558")
g4 <- qplot(abs_err, rel_err, data = res, main="CD3518 - Durham", 
     xlab="absolute error ", ylab="relative error", colour=od_type)

res <- calculate.rel.error(con, "orig=3518")
g5 <- ggplot(res, aes(x = abs_err, y = rel_err, colour=od_type)) +
  geom_point() +
  scale_color_manual(values=c("II"="red", "IE"="blue", "EI"="green"))

require(grid)
grid.newpage()
# Create layout : nrow = 2, ncol = 2
pushViewport(viewport(layout = grid.layout(4, 2)))
# A helper function to define a region on the layout
define_region <- function(row, col){
  viewport(layout.pos.row = row, layout.pos.col = col)
} 
# Arrange the plots
print(g1, vp = define_region(1:2, 1:2))
print(g2, vp = define_region(3, 1))
print(g3, vp = define_region(3, 2))
print(g4, vp = define_region(4, 1))
print(g5, vp = define_region(4, 2))


