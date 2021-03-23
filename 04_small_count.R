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

## media_summary %>% mutate(prob = res / n, logexport = log(export)) %>% select(prob, logexport, country) %>% ggplot(aes(x = logexport, y = prob, color = country)) + geom_point()

import_formula <- brmsformula(z~offset(log(n))+(1|k)+log(x_import))

get_prior(import_formula, data = outlet_data, family = negbinomial())

## IMPORT
weaklyinformative_prior <- c(prior_string("normal(0, 1)", class = "b"), prior_string("normal(0, 1)", class = "Intercept"))

## import_brms_prior <-  brm(z~offset(n)+(1|k)+log(x_import), data = outlet_data, family = negbinomial(), control = list(adapt_delta = 0.99), sample_prior = "only", prior = weaklyinformative_prior)

## condit <- data.frame(x_import = unique(outlet_data$x_import), n = 10)
## y_prep <- posterior_predict(import_brms_prior, nsamples = 4000)
## prior_checks <- conditional_effects(import_brms_prior, conditions = condit, method = "predict")
## prior_checks_plot <- plot(prior_checks, ncol = 6, plot = FALSE)
## prior_checks_plot[[1]] + ggtitle("Prior predictive distributions")

import_brms <- brm(z~offset(log(n))+(1|k)+log(x_import), data = outlet_data, family = negbinomial(), control = list(adapt_delta = 0.99), prior = weaklyinformative_prior, sample_prior = TRUE)
saveRDS(import_brms, "import_brms.RDS")


## svg("fig1.svg")
## plot(import_brms)
## dev.off()

conditional_effects(import_brms)

summary(import_brms)

pp_check(import_brms)

prior_summary(import_brms)

plot(import_brms)

import_brms4000 <- brm(z~offset(log(n))+(1|k)+log(x_import), data = outlet_data, family = negbinomial(), control = list(adapt_delta = 0.99), prior = weaklyinformative_prior, iter = 4000)

weaklyinformative_prior2 <- c(prior_string("student_t(1, 0, 0.25)", class = "b"), prior_string("student_t(1, 0, 0.25)", class = "Intercept"))

import_brms2 <- brm(z~offset(log(n))+(1|k)+log(x_import), data = outlet_data, family = negbinomial(), control = list(adapt_delta = 0.99), prior = weaklyinformative_prior2)

b_sample <- posterior_samples(import_brms, "b")

set.seed(2021)

import_brms_public <- brm(z~offset(log(n))+(1 + public|k)+log(x_import)*public, data = outlet_data, family = negbinomial(), control = list(adapt_delta = 0.99), prior = weaklyinformative_prior, iter = 2000)

## marginal_effects(import_brms_public)
condit_plots <- plot(conditional_effects(import_brms_public, conditions = data.frame(n = 10000)), ask = FALSE, plot = FALSE)
saveRDS(condit_plots, "condit_plots.RDS")



import_glmer <- glmer.nb(z~offset(log(n))+(1|k)+log(x_import), data = outlet_data)

summary(import_glmer)
confint(import_glmer)

import_mass <- MASS::glm.nb(z~offset(log(n))+log(x_import), data = outlet_data)
confint(import_mass)





## EXPORT
export_brms <- brm(z~offset(log(n))+(1|k)+log(x_export), data = outlet_data, family = negbinomial(), control = list(adapt_delta = 0.99), prior = weaklyinformative_prior, sample_prior = TRUE)

export_brms

export_glmer <- glmer.nb(z~offset(log(n))+(1|k)+log(x_export), data = outlet_data)

summary(export_glmer)
confint(export_glmer)

export_mass <- MASS::glm.nb(z~offset(log(n))+log(x_export), data = outlet_data)
summary(export_mass)
confint(export_mass)

## phy_dist
phy_dist_brms <- brm(z~offset(log(n))+(1|k)+log(x_phy), data = outlet_data, family = negbinomial(), control = list(adapt_delta = 0.99), prior = weaklyinformative_prior, sample_prior = TRUE)


phy_dist_glmer <- glmer.nb(z~offset(log(n))+(1|k)+log(x_phy), data = outlet_data)

summary(phy_dist_glmer)
confint(phy_dist_glmer)

phy_dist_mass <- MASS::glm.nb(z~offset(log(n))+log(x_phy), data = outlet_data)
summary(phy_dist_mass)
confint(phy_dist_mass)

## cult_dist
cult_dist_brms <- brm(z~offset(log(n))+(1|k)+log(x_cult), data = outlet_data, family = negbinomial(), control = list(adapt_delta = 0.99), prior = weaklyinformative_prior, sample_prior = TRUE)

summary(cult_dist_brms)

cult_dist_glmer <- glmer.nb(z~offset(log(n))+(1|k)+log(x_cult), data = outlet_data)

summary(cult_dist_glmer)
confint(cult_dist_glmer)

cult_dist_mass <- MASS::glm.nb(z~offset(log(n))+log(x_cult), data = outlet_data)
summary(cult_dist_mass)
confint(cult_dist_mass)
