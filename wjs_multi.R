require(brms)
require(tidyverse)

readRDS("wjs.RDS") %>% select(ppa, EXPRNCE, RANK, GENDER, UNI_EDU, UNI_EDU, eiu, gdppc, COUNTRY, C9, C10) %>% mutate(gdppc = log(gdppc), COUNTRY = as.factor(COUNTRY)) %>% mutate(C9 = as.numeric(C9), C10 = as.numeric(C10)) -> wjs

get_prior(mvbind(C9, C10) ~ EXPRNCE + RANK + GENDER + UNI_EDU + eiu + gdppc + (1|COUNTRY), data = wjs)

informative_prior <- c(prior_string("normal(0, 1)", class = "b", resp = "C9"), prior_string("normal(0, 1)", class = "b", resp = "C10"), prior_string("normal(0, 1)", class = "Intercept", resp = "C9"), prior_string("normal(0, 1)", class = "Intercept", resp = "C10"), prior_string("normal(0.14, 0.045)", class = "b", coef = "EXPRNCE", resp = "C9"), prior_string("normal(0.07, 0.027)", class = "b", coef = "RANK", resp = "C9"), prior_string("normal(0.14, 0.045)", class = "b", coef = "EXPRNCE", resp = "C10"), prior_string("normal(0.07, 0.027)", class = "b", coef = "RANK", resp = "C10"))

set.seed(1212121)
brm(mvbind(C9, C10) ~ EXPRNCE + RANK + GENDER + UNI_EDU + eiu + gdppc + (1|COUNTRY), family=cumulative("logit"), cores = 4, iter = 3000, sample_prior = TRUE, data = wjs, control = list(adapt_delta = 0.99), prior = informative_prior) -> ppa_clmod

saveRDS(ppa_clmod, "ppa_clmod.RDS")

c9ppc <- pp_check(ppa_clmod, ndraws = 100, resp = "C9")
c10ppc <- pp_check(ppa_clmod, ndraws = 100, resp = "C10")
saveRDS(list(c9ppc, c10ppc), "ppa_clmod_ppc.RDS")

require(cowplot)
c9c10ppc <- readRDS("ppa_clmod_ppc.RDS")
c9c10ppc[[1]] + ggtitle("How much freedom do you personally have in selecting news stories you work on?") -> c9gg
c9c10ppc[[2]] + ggtitle("How much freedom do you personally have in deciding which aspects of a story should be emphasized?") -> c10gg

plot_grid(c9gg, c10gg)

ppa_mod <- readRDS("ppa_mod.RDS")
ppa_mod_ppc <- pp_check(ppa_mod, ndraws = 100)
saveRDS(ppa_mod_ppc, "ppa_mod_ppc.RDS")


## bf1 <- bf(C9 ~ 0 + mi(Y))
## bf2 <- bf(C10 ~ 0 + mi(Y))
## bf3 <- bf(Y | mi() ~ 0)

## bf4 <- bf(Y ~ EXPRNCE + RANK + GENDER + UNI_EDU + eiu + gdppc + (1|COUNTRY))

## fit <- brm(bf1 + bf2 + bf3 + bf4, data = wjs, iter = 3000, chains = 2, cores = 2, sample_prior = TRUE)
