require(brms)

x <- readRDS("ppa_qmod.RDS")
qmod_condit <- plot(conditional_effects(x, effects = "eiu", ask = FALSE, plot = FALSE))

saveRDS(qmod_condit, "qmod_condit.RDS")
