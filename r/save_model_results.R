
########### Save results
run.folder <- paste("model", format(Sys.time(), "%Y-%m-%d-%H%M%S"), sep = "_")
current.run.folder <- file.path("canada/data/mnlogit/runs", run.folder)
dir.create(current.run.folder)

capture.output(segments$model_summary, file = file.path(current.run.folder, "model_summary.txt"))
#write all formulas
lapply(
  map(segments$model, ~ deparse(.$formula)), 
  cat, "\n",  
  file = file.path(current.run.folder, "formulas.txt"), 
  append=TRUE
)

#save(), file = file.path(current.run.folder, "models.dat"))
#write errors to file
write.csv(x = combined.errors, file = file.path(current.run.folder, "category_model_errors.csv"))
write.csv(x = total.errors, file = file.path(current.run.folder, "total_model_errors.csv"))

#save graph
source("canada/R/mto_graphing.R")
error.plot <- category_error_chart(
  combined.errors, file.path(current.run.folder, "category_error_charts.png"))
error.plot <- error_chart(total.errors, file.path(current.run.folder, "total_error_chart.png"))
