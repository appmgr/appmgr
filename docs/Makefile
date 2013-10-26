TXT=$(wildcard *.txt)
HTML=$(patsubst %.txt,%.html,$(TXT))
MAN=$(patsubst %.txt,%.1,$(TXT))
all: $(HTML) $(MAN)

%.html: %.txt
	asciidoc -a data-uri -a icons -a toc -a max-width=55em $<

%.1: %.txt
	a2x --doctype manpage --format manpage $<

clean:
	rm -rf $(wildcard *.html) $(wildcard *.1)
