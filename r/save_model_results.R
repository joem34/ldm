
########### Save results
run.folder <- paste("model", format(Sys.time(), "%Y-%m-%d-%H%M%S"), sep = "_")
current.run.folder <- file.path("canada/data/mnlogit/runs", run.folder)
dir.create(current.run.folder)

capture.output(trip_models$model_summary, file = file.path(current.run.folder, "model_summary.txt"))
#write all formulas
lapply(
  map(trip_models$model, ~ deparse(.$formula)), 
  cat, "\n",  
  file = file.path(current.run.folder, "formulas.txt"), 
  append=TRUE
)

#save(), file = file.path(current.run.folder, "models.dat"))
#write errors to file
write.csv(x = errors, file = file.path(current.run.folder, "errors.csv"))

#save graph
source("canada/R/mto_graphing.R")
error.plot <- error_chart(
  errors,
  trip_models$model[[1]]$formula, 
  file.path(current.run.folder, "error_chart.png")
)
