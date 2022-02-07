require(brms)

x <- readRDS("ppa_qmod.RDS")
qmod_condit <- plot(conditional_effects(x, effects = "eiu", ask = FALSE, plot = FALSE))

saveRDS(qmod_condit, "qmod_condit.RDS")

## LOO

ppa_mod <- readRDS("ppa_mod.RDS")
ppa_qmod <- readRDS("ppa_qmod.RDS")

saveRDS(loo(ppa_qmod, ppa_mod), "ppa_loo.RDS")

