require(rvest)

eiu_raw <- read_html("https://en.wikipedia.org/wiki/Democracy_Index")

eiu <- html_table(eiu_raw)[[6]]

eiu %>% select(3, `2012`, `2013`, `2014`, `2015`, `2016`) %>% rename(country = `Country`, e12 = `2012`, e13 = `2013`, e14 = `2014`, e15 = `2015`, e16 = `2016`) %>% rowwise() %>% mutate(eiu = mean(c(e12, e13, e14, e15, e16))) %>% select(country, eiu) %>% saveRDS(here::here("data/eiu.RDS"))

