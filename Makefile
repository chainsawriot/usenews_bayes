render: manuscript.bib
	Rscript -e "rmarkdown::render('manuscript.rmd', output_format = 'papaja::apa6_word')"
	Rscript deanony.R
	Rscript -e "rmarkdown::render('extension.rmd', output_format = 'all')"
manuscript.bib:
	bibcon -b ~/dev/dotfiles/bib.bib manuscript.rmd extension.rmd > manuscript.bib
