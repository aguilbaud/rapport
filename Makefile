
all:
	pdflatex rapport.tex; bibtex rapport; pdflatex rapport.tex;
clean: 
	rm *.aux *.lof *.log *.lot *.out *.toc rapport.pdf
