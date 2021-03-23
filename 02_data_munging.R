require(quanteda)
require(tidyverse)

mc <- readRDS(here::here("data/usenews.mediacloud.2019.rds"))
wm <- readRDS(here::here("data/usenews.mediacloud.wm.2019.rds"))

dfm_lookup(wm[[1]], dictionary(list(China = c("China"))))
saveRDS(wm[[1]], "NYT_2019.RDS")

gen_overview <- function(i, wm) {
    x <- wm[[i]]
    docvars(x) %>% count(language, sort = TRUE) %>% pull(language) -> langs
    lang <- langs[1]
    media <- unique(docvars(x, 'media_name'))
    n <- nrow(docvars(x))
    tibble(i = i, media = media, lang = lang, n = n)
}

overview <- map_dfr(seq_len(length(wm)), gen_overview, wm = wm)
overview %>% filter(n > 1000) %>% pull(lang) %>% unique

##head(docvars(wm[[1]]))

##overview %>% filter(n > 1000) %>% rio::export("media1k.csv")

media1k <- rio::import("media1k.csv")

china_dict <- dictionary(file = "chinese.yml")

cal_china <- function(media_id, media_lang, wm, china_dict) {
    print(media_id)
    ## weird bug of read_yaml treating "no" as FALSE
    dict_id <- which(media_lang == c("en", "no", "es", "ro", "de", "nl", "ko", "pt"))
    dfm_lookup(wm[[media_id]], china_dict[dict_id], levels = 1) %>% convert(to = "data.frame") %>% pull(2) -> res
    return(sum(res != 0))
}

res <- map2_int(media1k$i, media1k$lang, cal_china, wm = wm, china_dict = china_dict)

cbind(media1k, res) %>% group_by(country) %>% summarise(mr = sum(res) / sum(n)) %>% arrange(mr) -> country_summary

countries <- rio::import("countries.xlsx") %>% tibble::as_tibble()

country_summary %>% left_join(countries, by = "country") %>% pivot_longer(cols = phy_dist:cult_dist, names_to = "dist", values_to = "value", names_repair = "minimal") %>% ggplot(aes(x = mr, y = value, label = country)) + geom_text() + facet_grid(dist ~ . , scales = "free") + scale_y_continuous(trans='log2') + geom_smooth(method = "lm", se = FALSE)

country_summary %>% left_join(countries, by = "country") %>% select(-country) %>% cor(use = "pair", method = "kendall")

cbind(media1k, res) %>% left_join(countries, by = "country") -> media_summary

cal_china2 <- function(media_id, media_lang, wm, china_dict) {
    print(media_id)
    ## weird bug of read_yaml treating "no" as FALSE
    dict_id <- which(media_lang == c("en", "no", "es", "ro", "de", "nl", "ko", "pt"))
    dfm_lookup(wm[[media_id]], china_dict[dict_id], levels = 1) %>% convert(to = "data.frame") -> res
    colnames(res)[2] <- "china"
    res$i <- media_id    
    return(res)
}

res_df <- map2_dfr(media1k$i, media1k$lang, cal_china2, wm = wm, china_dict = china_dict)

res_df %>% left_join(media1k, by = "i") %>% left_join(countries, by = "country") %>% as_tibble %>% mutate(china = ifelse(china == 0, 0, 1)) -> article_level_data

saveRDS(res_df, "large_df.RDS")

saveRDS(media_summary, "small_df.RDS")
