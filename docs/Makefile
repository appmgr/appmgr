TXT=$(wildcard *.txt)
OUT=out
# Expand target section from heading of each page
MAN=$(shell ls *.txt|xargs -n 1 head -n 1|sed "s,\(.*\)(\([0-9]\)),$(OUT)/\1.\2,")
HTML=$(patsubst %.txt,$(OUT)/%.html,$(TXT))
ASPELL=aspell

all: _pre _post

_post: html man

_pre:
	@echo Version: $(VERSION)

html: $(HTML)
man: $(MAN)
.PHONY: html man

$(OUT)/%.html: %.txt
	@echo asciidoc $<
	@mkdir -p $(OUT)
	@asciidoc -o $@ -f asciidoc.conf --backend=xhtml11 -aappmgr_version=$(VERSION) $<

$(OUT)/%.1: %.txt
	$(call man,$<)

$(OUT)/%.7: %.txt
	$(call man,$<)

define man
	@mkdir -p $(OUT)
	@echo a2x $(1)
	@a2x -L --format manpage $(1)
	@f=`ls $(basename $1).1 $(basename $1).7 2>/dev/null`; \
	   if [ -r "$$f" ]; then mv $$f $(OUT); fi
endef

spell: $(patsubst %,spell-%,$(TXT))
.PHONY: spell
spell-%:
	$(ASPELL) check -p appmgr.dict -l en --encoding utf-8 $(patsubst spell-%,%,$@)

clean:
	rm -rf $(OUT)
