
########### Save results
print ("    Saving")


append.csv <- function(x, file) {
  write.table(x = x, file = file,na = "", sep = ",", append = TRUE, row.names = FALSE)
}

append.csv(model.coefficients, file.path(current.run.folder, "model_coefficients.csv"))
append.csv(x = errors, file = file.path(current.run.folder, "model_errors.csv"))

capture.output(model_summary, file = file.path(current.run.folder, "model_summary.txt"))
#write all formulas
cat(deparse(f), "\n", file = file.path(current.run.folder, "formulas.txt"), append=TRUE)

#save graph
source("canada/R/mto_graphing.R")
error.plot <- error_chart(errors, file.path(current.run.folder, "total_error_chart.png"))
