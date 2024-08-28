require(brms)
require(brms)
require(lme4)
require(tidyverse)

set.seed(2021)

## require(sjmisc)
## require(sjstats)

outlet_data <- readRDS("small_df.RDS")

### To match the notion in the paper

colnames(outlet_data) <- c("j", "media", "lang", "n", "k", "z", "x_phy", "x_export", "x_import", "x_cult")

media1k <- rio::import("media1k.csv") %>% tibble::as_tibble()

outlet_data$public <- ifelse(media1k$public == 1, "Yes", "No")


import_brms <- readRDS("import_brms.RDS")

fx <- fixef(import_brms) %>% as_tibble
row.names(fixef(import_brms)) -> brms_terms


require(broom)
require(broom.mixed)


import_glmer <- glmer.nb(z~offset(log(n))+(1|k)+log(x_import), data = outlet_data) %>% tidy(conf.int = TRUE)

import_mass <- MASS::glm.nb(z~offset(log(n))+log(x_import), data = outlet_data) %>% tidy(conf.int = TRUE)

import_glmer %>% dplyr::filter(effect == 'fixed') %>% dplyr::select(term, estimate, conf.low, conf.high) %>% mutate(est = paste0(round(estimate, 2), " (", round(conf.low, 2), ", ", round(conf.high, 2), ")")) %>% dplyr::select(term, est) -> mixed_est

import_mass %>% dplyr::select(term, estimate, conf.low, conf.high) %>% mutate(est = paste0(round(estimate, 2), " (", round(conf.low, 2), ", ", round(conf.high, 2), ")")) %>% dplyr::select(term, est) -> de_est

fx %>% mutate(term = brms_terms) %>% dplyr::select(term, Estimate, Q2.5, Q97.5) %>% mutate(est = paste0(round(Estimate, 2), " (", round(Q2.5, 2), ", ", round(Q97.5, 2), ")")) %>% dplyr::select(term, est) -> brms_est

brms_est %>% mutate(mixed_est = mixed_est$est, de_est = de_est$est) %>% saveRDS("import_reg.RDS")

