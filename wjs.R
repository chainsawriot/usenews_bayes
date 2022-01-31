require(rio)
require(tidyverse)
require(brms)

wjs_raw <- haven::read_sav("data/WJS2 open V4-02 030517.sav", encoding = "latin1") %>% tibble::as_tibble()

## wjs_raw %>% count(COUNTRY) %>% mutate(COUNTRY_NAME = as_factor(COUNTRY)) %>% rio::export("wjs_countries.csv")

pts <- rio::import("data/PTS-2021.xlsx") %>% tibble::as_tibble() %>% filter(Year == 2017) %>% select(Country, PTS_A, PTS_H, PTS_S) %>% mutate(PTS_A = as.numeric(PTS_A), PTS_H = as.numeric(PTS_H), PTS_S = as.numeric(PTS_S)) %>% rowwise() %>% mutate(PTS = median(c(PTS_A, PTS_H, PTS_S), na.rm = TRUE)) %>% ungroup %>% filter(!is.na(PTS)) %>% select(Country, PTS) %>% mutate(Country = recode(Country, `Korea, Republic of` = "South Korea", `Tanzania, United Republic of` = "Tanzania", `United Arab Emirates` = "UAE", `United Kingdom` = "UK", `United States` = "USA", `Russian Federation` = "Russia", `Moldova, Republic of` = "Moldova"))

eiu <- readRDS(here::here("data/eiu.RDS")) %>% ungroup %>% mutate(country = recode(country, `United Arab Emirates` = "UAE", `United Kingdom` = "UK", `United States` = "USA"))

gdp <- rio::import("data/API_NY.GDP.PCAP.CD_DS2_en_csv_v2_3469501.csv", skip = 5) %>% tibble::as_tibble()

gdp_r1 <- rio::import("data/API_NY.GDP.PCAP.CD_DS2_en_csv_v2_3469501.csv", skip = 4)[1,] %>% unlist %>% as.vector

colnames(gdp) <- gdp_r1

gdp %>% select(`Country Name`, `2012`:`2016`) %>% rowwise() %>% mutate(gdppc = mean(c(`2012`, `2013`, `2014`, `2015`, `2016`), na.rm = TRUE)) %>% ungroup %>% select(`Country Name`, gdppc) %>% rename(country = `Country Name`) %>% mutate(country = recode(country, `United Arab Emirates` = "UAE", `United Kingdom` = "UK", `United States` = "USA", `Korea, Rep.` = "South Korea", `Russian Federation` = "Russia", `Egypt, Arab Rep.` = "Egypt", `Hong Kong SAR, China` = "Hong Kong"))  -> gdp_tab

wjs_raw %>% count(COUNTRY) %>% mutate(COUNTRY_NAME = as_factor(COUNTRY)) -> country_tab

## country_tab %>% left_join(eiu, by = c("COUNTRY_NAME" = "country")) %>% print(n = 100)

## country_tab %>% left_join(gdp_tab, by = c("COUNTRY_NAME" = "country")) %>% print(n = 100)


country_tab %>% left_join(pts, by = c("COUNTRY_NAME" = "Country")) %>% left_join(eiu, by = c("COUNTRY_NAME" = "country")) %>% left_join(gdp_tab, by = c("COUNTRY_NAME" = "country")) %>% select(COUNTRY, PTS, eiu, gdppc) -> pts_tab

saveRDS(pts_tab, "pts_tab.RDS")

wjs_raw$COUNTRY <- haven::zap_labels(wjs_raw$COUNTRY)
##wjs_raw$C12L <- haven::zap_labels(wjs_raw$C12L)

wjs_raw %>% left_join(pts_tab) %>% mutate(ppa = (C9 + C10) / 2) -> wjs

saveRDS(wjs, "wjs.RDS")

set.seed(12121)

##informative_prior <- c(prior_string("normal(0.14, 0.045)", class = "b", coef = "EXPRNCE"), prior_string("normal(0.07, 0.027)", class = "b", coef = "RANK"), prior_string("normal(0.08, 0.04)", class = "b", coef = "eiu"))


informative_prior <- c(prior_string("normal(0, 1)", class = "b"), prior_string("normal(0, 1)", class = "Intercept"), prior_string("normal(0.14, 0.045)", class = "b", coef = "EXPRNCE"), prior_string("normal(0.07, 0.027)", class = "b", coef = "RANK"))

std <- function(x){
  (x - mean(x, na.rm = TRUE))/sd(x, na.rm = TRUE)
}


wjs %>% select(ppa, EXPRNCE, RANK, GENDER, UNI_EDU, UNI_EDU, eiu, gdppc, COUNTRY) %>% mutate(gdppc = log(gdppc), COUNTRY = as.factor(COUNTRY)) %>% mutate_at(vars(ppa:gdppc), std) %>% brm(ppa ~ EXPRNCE + RANK + GENDER + UNI_EDU + eiu + gdppc + (1|COUNTRY), data = ., cores = 4, iter = 3000, prior = informative_prior, sample_prior = TRUE) -> ppa_mod
saveRDS(ppa_mod, "ppa_mod.RDS")
## saveRDS(pts_mod, "pts_mod.RDS")

set.seed(12121)
wjs %>% select(ppa, EXPRNCE, RANK, GENDER, UNI_EDU, UNI_EDU, eiu, gdppc, COUNTRY) %>% mutate(gdppc = log(gdppc), COUNTRY = as.factor(COUNTRY)) %>% mutate_at(vars(ppa:gdppc), std) %>% brm(ppa ~ EXPRNCE + RANK + GENDER + UNI_EDU + I(eiu^3) + gdppc + (1|COUNTRY), data = ., cores = 4, iter = 4000, prior = informative_prior, sample_prior = TRUE) -> ppa_qmod

saveRDS(ppa_qmod, "ppa_qmod.RDS")
