require(osfr)
require(quanteda)

dir.create("data")

osf_retrieve_node("uzca3") %>% osf_ls_files(n_max = 100, pattern = "rds") %>% osf_download(path = "data", progress = TRUE)
