all: check test docs

BINS=$(wildcard bin/app-*) $(wildcard libexec/app-*)

OUT=out
BATS=$(sort $(patsubst test/%,%,$(filter-out test/X-%,$(wildcard test/*.bats))))
TESTS=$(addprefix test-,$(BATS))
CHECKS=$(addsuffix .check,$(addprefix $(OUT)/,$(BINS)))
GIT_VERSION:=$(shell git describe --dirty --always)
M=make -j8 -s VERSION=$(GIT_VERSION)

install: docs
	@if [ "$(DESTDIR)" = "" ]; then echo "You have to set DESTDIR"; exit 1; fi; fi
	mkdir -p $(DESTDIR)/usr
	cp -r bin/ lib/ libexec/ $(DESTDIR)/usr/
	mkdir -p $(DESTDIR)/usr/share/man/man1
	cp docs/$(OUT)/*.1 $(DESTDIR)/usr/share/man/man1/
	mkdir -p $(DESTDIR)/usr/share/man/man7
	cp docs/$(OUT)/*.7 $(DESTDIR)/usr/share/man/man7/
	mkdir -p $(DESTDIR)/usr/share/doc/appmgr
	cp docs/$(OUT)/*.html $(DESTDIR)/usr/share/doc/appmgr/

check: $(CHECKS)
.PHONY: check

$(OUT)/%.check: %
	@mkdir -p $(shell dirname $@)
	shellcheck $(patsubst check-%,check/%,$<)
	@touch $@

test-%:
	@echo === $@
	@PATH=test/bats/bin:$(PATH) bats $(patsubst test-%,test/%,$@)

show-tests:
	@echo BATS=$(BATS)
	@echo TESTS=$(TESTS)
	@echo $(addprefix set_header-,$(BINS))

test: test/bats $(TESTS)
.PHONY: test

test/bats:
	cd test && git clone git://github.com/sstephenson/bats.git

clean:
	@rm -rf $(OUT)
	@$(M) -C docs clean
.PHONY: clean

docs:
	@$(M) -C docs
.PHONY: docs

define set_header
set_header-$(1):
	@count=`wc -l lib/header|cut -f 1 -d ' '`; \
	cat lib/header > x; \
	echo "# HEADER END" >> x; \
	sed '1,/HEADER END/d' $(1) >> x; \
	if [ `md5sum $(1)|cut -f 1 -d ' '` != `md5sum x|cut -f 1 -d ' '` ]; then echo Updated: $(1); cp x $(1); fi; \
	rm x
endef

$(foreach f,$(BINS),$(eval $(call set_header,$(f))))
set-headers: $(addprefix set_header-,$(BINS))

.PHONY: set-headers

# If you want to add your own goals or utilities, put them in Makefile.local
-include Makefile.local
