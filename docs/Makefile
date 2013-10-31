TXT=$(wildcard *.txt)
# Expand target section from heading of each page
MAN=$(shell ls *.txt|xargs -n 1 head -n 1|sed "s,\(.*\)(\([0-9]\)),\1.\2,")
HTML=$(patsubst %.txt,%.html,$(TXT))
ASPELL=aspell

all: html man

html: $(HTML)
man: $(MAN)
.PHONY: html man

%.html: %.txt
	@echo asciidoc $<
	@asciidoc -f asciidoc.conf --backend=xhtml11 -aappsh_version=0.2-dev $<

%.1: %.txt
	$(call man,$<)

%.7: %.txt
	$(call man,$<)

define man
	@echo a2x $(1)
	@a2x --format manpage $(1)
endef

spell: $(patsubst %,spell-%,$(TXT))
.PHONY: spell
spell-%:
	$(ASPELL) check -p appsh.dict -l en --encoding utf-8 $(patsubst spell-%,%,$@)

clean:
	rm -rf $(wildcard *.html) $(wildcard *.1) $(wildcard *.7)
