TXT=$(wildcard *.txt)
HTML=$(patsubst %.txt,%.html,$(TXT))
MAN=$(patsubst %.txt,%.1,$(TXT))
all: $(HTML) $(MAN)

%.html: %.txt
	@echo asciidoc $<
	@asciidoc -f asciidoc.conf --backend=html5 $<

%.1: %.txt
	@echo a2x $<
	@a2x --format manpage $<

clean:
	rm -rf $(wildcard *.html) $(wildcard *.1)
