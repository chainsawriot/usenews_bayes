require(bibliometrix)
require(tibble)
require(purrr)
require(tidyverse)

res <- map_dfr(list.files(here::here("data/wos"), pattern = "bib$", full.names = TRUE), ~as_tibble(convert2df(here::here(.), format = "bibtex")))

res %>% arrange(DT) %>% mutate(UID = row_number()) %>% relocate(UID) %>% rio::export("wos.xlsx")
