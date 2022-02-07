require(quanteda)
require(tidyverse)

mc <- readRDS(here::here("data/usenews.mediacloud.2019.rds"))
wm <- readRDS(here::here("data/usenews.mediacloud.wm.2019.rds"))

## dfm_lookup(wm[[1]], dictionary(list(China = c("China"))))
## saveRDS(wm[[1]], "NYT_2019.RDS")

gen_overview <- function(i, wm) {
    x <- wm[[i]]
    docvars(x) %>% count(language, sort = TRUE) %>% pull(language) -> langs
    lang <- langs[1]
    media <- unique(docvars(x, 'media_name'))
    n <- nrow(docvars(x))
    tibble(i = i, media = media, lang = lang, n = n)
}


media1k <- rio::import("media1k.csv")

china_dict <- dictionary(file = "chinese.yml")

cal_china <- function(media_id, media_lang, wm, china_dict) {
    print(media_id)
    ## weird bug of read_yaml treating "no" as FALSE
    dict_id <- which(media_lang == c("en", "no", "es", "ro", "de", "nl", "ko", "pt"))
    dfm_lookup(wm[[media_id]], china_dict[dict_id], levels = 1) %>% convert(to = "data.frame") %>% pull(2) -> res
    tibble(url = docvars(wm[[media_id]])$url, title = docvars(wm[[media_id]])$title, media_id = media_id, media_lang = media_lang, china = (res != 0))
}

res <- map2_dfr(media1k$i, media1k$lang, cal_china, wm = wm, china_dict = china_dict)

set.seed(121212)
res %>% group_by(media_lang, china) %>% sample_n(10) %>% mutate(id = row_number(), ran = rnorm(n = 10)) %>% ungroup %>% arrange(media_lang, ran) -> content_to_be_coded

saveRDS(content_to_be_coded, "content_to_be_coded.RDS")

content_to_be_coded %>% select(-china, -ran) %>% rio::export("content_to_be_coded.xlsx")

gh <- readRDS("content_to_be_coded.RDS")
x <- rio::import("WOS - China Dictionary Validation.csv") %>% tibble::as_tibble()


table(gt = gh$china, coded = x$coded_china)
require(ROCR)

tibble(media_lang = x$media_lang, pred = x$coded_china, label = gh$china) %>% filter(!is.na(pred))  %>% (function(x) prediction(x$pred, x$label))() %>% performance("prec", "rec")  %>% str

tibble(media_lang = x$media_lang, pred = x$coded_china, label = gh$china) %>% filter(label & pred == 0)
