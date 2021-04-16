require(quanteda)
require(tidyverse)

require(brms)

set.seed(4521314)


article_level_data <- readRDS("article_level_data.RDS")

sample(article_level_data, 100)

res100 <- microbenchmark(brm(china~(1|country/media)+log(import), data = sample_n(article_level_data, 100), family = bernoulli(), control = list(adapt_delta = 0.9), core = 6), times = 10)

res1000 <- microbenchmark(brm(china~(1|country/media)+log(import), data = sample_n(article_level_data, 1000), family = bernoulli(), control = list(adapt_delta = 0.9), core = 6), times = 10)

res10000 <- microbenchmark(brm(china~(1|country/media)+log(import), data = sample_n(article_level_data, 10000), family = bernoulli(), control = list(adapt_delta = 0.9), core = 6), times = 10)

res30000 <- microbenchmark(brm(china~(1|country/media)+log(import), data = sample_n(article_level_data, 30000), family = bernoulli(), control = list(adapt_delta = 0.9), core = 6), times = 10)

saveRDS(list(res100, res1000, res10000, res30000), "benchmark.RDS")

benchmark <- readRDS("benchmark.RDS")
plot(c(100, 1000, 10000, 30000), map_dbl(benchmark, ~mean(.$time)/1000000000))
