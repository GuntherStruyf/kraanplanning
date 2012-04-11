TEXINPUTS := ${PWD}:${PWD}/styles
JOBNAME := flowchart_square_NE

pdf:
	@echo ${TEXINPUTS}
	pdflatex -shell-escape ${JOBNAME}.tex
	#bibtex ${JOBNAME}
	#bibtex fig
	pdflatex -shell-escape ${JOBNAME}.tex
	#bibtex ${JOBNAME}
	#bibtex fig
	#pdflatex -shell-escape ${JOBNAME}.tex

simple:
	pdflatex -shell-escape ${JOBNAME}.tex

clean:
	rm -f *.aux
	rm -f fig.bbl
	rm -f fig.blg
	rm -f ${JOBNAME}.bbl
	rm -f ${JOBNAME}.blg
	rm -f ${JOBNAME}.dvi
	rm -f ${JOBNAME}.idx
	rm -f ${JOBNAME}.lof
	rm -f ${JOBNAME}.log
	rm -f ${JOBNAME}.lot
	rm -f ${JOBNAME}.out
	rm -f ${JOBNAME}.thm
	rm -f ${JOBNAME}.toc
	rm -f appendix/*.aux

	
	rm -f images/eps/*-pstool.*
	rm -f images/eps/*.aux
	rm -f images/eps/*.log
	rm -f images/eps/*.pdf
	
	rm -f images/matlab/*.aux
	rm -f images/matlab/*-pstool.*
	rm -f images/matlab/*.pdf


