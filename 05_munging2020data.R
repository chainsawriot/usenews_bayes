require(quanteda)
require(tidyverse)

mc <- readRDS(here::here("data/usenews.mediacloud.2020.rds"))
wm <- readRDS(here::here("data/usenews.mediacloud.wm.2020.rds"))

gen_overview <- function(i, wm) {
    x <- wm[[i]]
    docvars(x) %>% count(language, sort = TRUE) %>% pull(language) -> langs
    lang <- langs[1]
    media <- unique(docvars(x, 'media_name'))
    n <- nrow(docvars(x))
    tibble(i = i, media = media, lang = lang, n = n)
}

overview <- map_dfr(seq_len(length(wm)), gen_overview, wm = wm)

outlet_data <- readRDS("small_df.RDS")

### To match the notion in the paper

colnames(outlet_data) <- c("j", "media", "lang", "n", "k", "z", "x_phy", "x_export", "x_import", "x_cult")

media1k <- rio::import("media1k.csv") %>% tibble::as_tibble()

outlet_data$public <- ifelse(media1k$public == 1, "Yes", "No")

require(fuzzyjoin)

overview %>% mutate(media = recode(media, `Sydney Morning Herald` = "The Sydney Morning Herald", `HuffPost` = "Huffington Post", `Spiegel` = "spiegel.de")) %>% stringdist_left_join(outlet_data, by = "media") %>% filter(n.x >= 1000 & !is.na(j)) -> overview1920

overview1920

china_dict <- dictionary(file = "chinese.yml")

cal_china <- function(media_id, media_lang, wm, china_dict) {
    print(media_id)
    ## weird bug of read_yaml treating "no" as FALSE
    dict_id <- which(media_lang == c("en", "no", "es", "ro", "de", "nl", "ko", "pt"))
    dfm_lookup(wm[[media_id]], china_dict[dict_id], levels = 1) %>% convert(to = "data.frame") %>% pull(2) -> res
    return(sum(res != 0))
}

res <- map2_int(overview1920$i, overview1920$lang.x, cal_china, wm = wm, china_dict = china_dict)
overview1920$z_2020 <- res

names(overview1920) <- c("i", "media", "lang", "n_2020", "j", "media.y", "lang.y", "n_2019", "k", "z_2019", "x_phy", "x_export", "x_import", "x_cult", "public", "z_2020")

overview1920 %>% select(-media.y, -lang.y) -> overview1920

saveRDS(overview1920, "overview1920.RDS")
