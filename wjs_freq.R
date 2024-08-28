require(tidyverse)

set.seed(12121)

wjs <- readRDS("wjs.RDS")
std <- function(x){
  (x - mean(x, na.rm = TRUE))/sd(x, na.rm = TRUE)
}

wjs %>% select(ppa, EXPRNCE, RANK, GENDER, UNI_EDU, UNI_EDU, eiu, gdppc, COUNTRY) %>% mutate(gdppc = log(gdppc), COUNTRY = as.factor(COUNTRY)) %>% mutate_at(vars(ppa:gdppc), std) -> wjs

require(lme4)
require(brms)
require(broom)

require(broom.mixed)


lmer(ppa ~ EXPRNCE + RANK + GENDER + UNI_EDU + eiu + gdppc + (1|COUNTRY), data = wjs) %>% tidy(conf.int = TRUE) -> mixed_lm

glm(ppa ~ EXPRNCE + RANK + GENDER + UNI_EDU + eiu + gdppc, data = wjs) %>% tidy(conf.int = TRUE) -> de_lm

ppa_mod <- readRDS("ppa_mod.RDS")
fixef(ppa_mod) %>% as_tibble -> brms_mode
row.names(fixef(ppa_mod)) -> brms_terms

require(tidyverse)

mixed_lm %>% dplyr::filter(effect == 'fixed') %>% dplyr::select(term, estimate, conf.low, conf.high) %>% mutate(est = paste0(round(estimate, 2), " (", round(conf.low, 2), ", ", round(conf.high, 2), ")")) %>% dplyr::select(term, est) -> mixed_est

de_lm %>% dplyr::select(term, estimate, conf.low, conf.high) %>% mutate(est = paste0(round(estimate, 2), " (", round(conf.low, 2), ", ", round(conf.high, 2), ")")) %>% dplyr::select(term, est) -> de_est

brms_mode %>% mutate(term = brms_terms) %>% dplyr::select(term, Estimate, Q2.5, Q97.5) %>% mutate(est = paste0(round(Estimate, 2), " (", round(Q2.5, 2), ", ", round(Q97.5, 2), ")")) %>% dplyr::select(term, est) -> brms_est

brms_est %>% mutate(mixed_est = mixed_est$est, de_est = de_est$est) %>% saveRDS("wjs_reg.RDS")
