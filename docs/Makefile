TXT=$(wildcard *.txt)
HTML=$(patsubst %.txt,%.html,$(TXT))
all: $(HTML)

%.html: %.txt
	asciidoc -a data-uri -a icons -a toc -a max-width=55em $<

clean:
	rm -rf $(wildcard *.html)
