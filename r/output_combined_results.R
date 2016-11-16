# save thesis friendly coefficients
a <- fread(file.path(current.run.folder, "model_output.csv")) %>% select (class, parameter, coef, p)
b <- a %>% dcast(parameter ~ class, value.var=c("coef", "p")) %>% 
  mutate (p_business = stars.pval(p_Business),
          p_leisure = stars.pval(p_Leisure),
          p_visit = stars.pval(p_Visit)) %>%
  transmute(parameter, 
            Visit = signif(coef_Visit, 3), visit_p = p_visit, 
            Leisure = signif(coef_Leisure, 3), leisure_p = p_leisure, 
            Business = signif(coef_Business, 3), business_p = p_business)
write.csv(b, file.path(current.run.folder, "model_coefficients.csv"), row.names = FALSE)

print.xtable(
  xtable(b), 
  type="latex", 
  file=file.path(current.run.folder, "model_coefficients.tex"), 
  include.rownames=FALSE
)

all.errors <- fread(file.path(current.run.folder, "model_errors.csv"))


g1 <- ggplot(all.errors) +
  geom_point(aes(abs.error, max.rel.error), shape=1) +
  labs(x="Absolute error (# Trips) ", y="Maximum relative error (x Trips)") +
  theme_bw() +
  scale_color_brewer(name="OD Pair Type",
                     #labels=c("II - Intra Ontario", "IE - Outgoing", "EI - Incoming"), 
                     palette = 2, type = "qual") +
  facet_wrap(~ class)

g1 
ggsave(file=file.path(chart_folder, "all_model_errors.png"), width = 10, height = 5)

g2 <- ggplot(all.errors) +
  geom_point(aes(ex,x-ex), shape=1) +
  labs(x="Observed Trips ", y="Error") +
  theme_bw() +
  ylim(c(-2000, 2000)) +
  facet_wrap(~ class) + 
  geom_abline(intercept = 0, slope = 0, linetype="dashed")
g2
ggsave(file=file.path(chart_folder, "all_model_residuals.png"), width = 10, height = 5)
