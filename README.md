# Bayesian

All the information about the paper:

Chan, Chung-hong, and Rauchfleisch, Adrian. (2023) Bayesian multilevel modeling and its application in comparative journalism studies. *International Journal of Communication*

The paper was also presented at the ICA 2022 Conference, Journalism Studies Division. (Paris, France. [slides](https://chainsawriot.github.io/bayes_pres))

Additional information is also available on [OSF](https://osf.io/2h4w8/).

# Overview

| File prefix  | purpose                                                                             |
|--------------|-------------------------------------------------------------------------------------|
| `wjs.R`      | WJS analysis                                                                        |
| `01_`        | Getting the [useNews data](https://osf.io/uzca3/) (Puschmann & Haim, 2020) from OSF |
| `scrape_eui` | Scraping EIU's Democracy indices                                                    |
| `02_`        | Combining data sources                                                              |
| `021_`       | Validating the dictionary of China coverage                                         |
| `030_`       | Preparing the data for regression analysis                                          |
| `031_`       | Article-level Bayesian analysis (take 1 week on a regular computer)                 |
| `032_`       | Benchmark (wall clock)                                                              |
| `04_`        | Outlet-level Bayesian analysis                                                      |
| `05_`        | Preparing the data for 2020 analysis                                                |
| `06_`        | Report `04` but with 2020 data                                                      |

There are two important R Markdown files

1. `manuscript.rmd` - as the name suggested
2. `extension.rmd` - the online appendix

# External requirements

You still need the WJS data from [this website](https://worldsofjournalism.org/data-d79/data-and-key-tables-2012-2016/). The filename is `WJS2 open V4-02 030517.sav`. Please put it in the `data` directory (see `wjs.R`).

The following R packages are required:

```r
install.packages(c("osfr", "quanteda", "here", "rio", "tibble", "tidyverse", "ROCR",  "brms", "lme4", "MASS", "broom", "broom.mixed", "dplyr", "fuzzyjoin",  "parameters", "rmarkdown", "papaja", "cowplot", "knitr", "ggplot2", "bayestestR", "scales", "rvest", "haven", "purrr"))
```

# The draft

The draft in this repository does not contain the edits after the acceptance. Please consider the draft as a preprint. For the final version, please check IJOC.
