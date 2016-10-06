
########### Save results
print ("    Saving")


append.csv <- function(x, file) {
  inc.col.names <- !file.exists(file)
  write.table(x = x, file = file,na = "", sep = ",", append = TRUE, row.names = FALSE, col.names = inc.col.names)
}

append.csv(model.coefficients, file.path(current.run.folder, "model_coefficients.csv"))
append.csv(x = errors, file = file.path(current.run.folder, "model_errors.csv"))

capture.output(model_summary, file = file.path(current.run.folder, "model_summary.txt"))
#write all formulas
cat(deparse(f), "\n", file = file.path(current.run.folder, "formulas.txt"), append=TRUE)

#save graph
source("canada/R/mto_graphing.R")
chart_folder <- file.path(current.run.folder, "charts")
dir.create(chart_folder, showWarnings = FALSE)

error.file.name <- paste0(class.ref, "_error_chart.png")
error.plot <- error_chart(errors, file.path(chart_folder, error.file.name))
