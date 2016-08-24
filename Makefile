
all:
	echo "Warning:1st compil"; pdflatex rapport.tex; echo "Warning:bibtex"; bibtex rapport;echo "Warning:2nd compil"; pdflatex rapport.tex;
clean: 
	rm *.aux *.lof *.log *.lot *.out *.toc rapport.pdf
