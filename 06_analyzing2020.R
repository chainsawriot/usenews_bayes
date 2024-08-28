require(brms)

import2019 <- readRDS("import_brms.RDS")

outlet_data2020 <- readRDS("overview1920.RDS")

import2019

## gamma01 0.25, se 0.05
## gamma00 -6.69, se 0.66
## sd 0.08 se 0.07

##parameters::parameters(import2019, dispersion = TRUE, centrality = "mean")

informative_prior <- c(prior_string("normal(0.25, 0.05)", class = "b",, coef = "logx_import"), prior_string("normal(-6.69, 0.66)", class = "Intercept"))


set.seed(2021)
import_2020 <- brm(z_2020~offset(log(n_2020))+(1|k)+log(x_import), data = outlet_data2020, family = negbinomial(), control = list(adapt_delta = 0.99), prior = informative_prior, sample_prior = TRUE)
summary(import_2020)

require(tidyverse)

outlet_data2020 %>% select(i, k, n_2020, n_2019, k) %>% pivot_longer(starts_with("n"), names_to = "yr", values_to = "n") -> n_long

outlet_data2020 %>% select(i, z_2020, z_2019) %>% pivot_longer(-i, names_to = "yr", values_to = "z") -> z_long

n_long$z <- z_long$z

n_long %>% mutate(yr = ifelse(yr == "n_2020", TRUE, FALSE)) -> outlet_long

weaklyinformative_prior <- c(prior_string("normal(0, 1)", class = "b"), prior_string("normal(0, 1)", class = "Intercept"))

set.seed(2021)
import_long <- brm(z~offset(log(n))+(1|k/i)+yr, data = outlet_long, family = negbinomial(), control = list(adapt_delta = 0.99), prior = weaklyinformative_prior, sample_prior = TRUE)
