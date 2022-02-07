render:
	Rscript -e "condensebib::reduce_bib(c('manuscript.rmd', 'extension.rmd'), master_bib = '/home/chainsawriot/dev/dotfiles/bib.bib', out_bib = 'manuscript.bib')"
	Rscript -e "rmarkdown::render('manuscript.rmd', output_format = 'all')"
	Rscript -e "rmarkdown::render('extension.rmd', output_format = 'all')"
