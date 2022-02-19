x <- readLines("manuscript.rmd")
x[x == "mask              : yes"] <- "mask              : no"
writeLines(x, "manuscript_name.rmd")
rmarkdown::render('manuscript_name.rmd', output_format = 'all')
