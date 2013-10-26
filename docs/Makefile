TXT=$(wildcard *.txt)
# Expand target section from heading of each page
MAN=$(shell ls *.txt|xargs -n 1 head -n 1|sed "s,\(.*\)(\([0-9]\)),\1.\2,")
HTML=$(patsubst %.txt,%.html,$(TXT))

all: $(HTML) $(MAN)

%.html: %.txt
	@echo asciidoc $<
	@asciidoc -f asciidoc.conf --backend=html5 $<

%.1: %.txt
	$(call man,$<)

%.7: %.txt
	$(call man,$<)

define man
	@echo a2x $(1)
	@a2x --format manpage $(1)
endef

clean:
	rm -rf $(wildcard *.html) $(wildcard *.1) $(wildcard *.7)
