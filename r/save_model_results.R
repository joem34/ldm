
########### Save results
print ("    Saving")


append.csv <- function(x, file, ...) {
  inc.col.names <- !file.exists(file)
  write.table(x = x, file = file,na = "", sep = ",", append = TRUE, row.names = FALSE, col.names = inc.col.names, ...)
}

append.csv(model.coefficients, file.path(current.run.folder, "model_coefficients.csv"))
append.csv(x = errors, file = file.path(current.run.folder, "model_errors.csv"))

#write all formulas
cat(deparse(f), "\n", file = file.path(current.run.folder, "formulas.txt"), append=TRUE)

#save graph
source("canada/R/mto_graphing.R")
chart_folder <- file.path(current.run.folder, "charts")
dir.create(chart_folder, showWarnings = FALSE)

error.file.name <- paste0(class.ref, "_error_chart.png")
error.plot <- error_chart(errors, file.path(chart_folder, error.file.name))

#summaries
summary_folder <- file.path(current.run.folder, "summaries")
dir.create(summary_folder, showWarnings = FALSE)
capture.output(model_summary, file = file.path(current.run.folder, paste(class.column, "-", class,"-model_summary.txt")))

#append run results to main file
run_list_file <- file.path("canada/data/mnlogit/runs", "runs.csv")
run.results <- data.frame(
  'date' = run.date,
  'grouping' = class.column,
  'class' = class,
  'formula' = Reduce(paste0, deparse(f)),
  'loglik' = logLik(model_summary), 
  'AIC' = model_summary[['AIC']]
)

append.csv(run.results, run_list_file)




