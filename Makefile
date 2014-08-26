all: check test docs

BINS=$(wildcard bin/app-*)
LIBS=$(wildcard lib/appmgr/*)

OUT=out
BATS=$(sort $(patsubst test/%,%,$(filter-out test/X-%,$(wildcard test/*.bats))))
TESTS=$(addprefix test-,$(BATS))
CHECKS=$(addsuffix .check,$(addprefix $(OUT)/,$(BINS)))
GIT_VERSION=$(shell git describe --dirty --always)
VERSION=${VERSION:-${GIT_VERSION}}
M=make -j8 -s VERSION=${VERSION}

install: docs
	@if [ "$(DESTDIR)" = "" ]; then echo "You have to set DESTDIR"; exit 1; fi
	@$(M) -C docs DESTDIR=$(DESTDIR) install
	mkdir -p $(DESTDIR)/lib/appmgr
	cp -r app bin/ lib/ share/ $(DESTDIR)/lib/appmgr
	mkdir -p $(DESTDIR)/bin
	ln -sf ../lib/appmgr/app $(DESTDIR)/bin

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
	@count=`wc -l $(2)|cut -f 1 -d ' '` && \
	cat $(2) > x && \
	echo "# HEADER END" >> x && \
	sed '1,/HEADER END/d' $(1) >> x && \
	if [ `md5sum $(1)|cut -f 1 -d ' '` != `md5sum x|cut -f 1 -d ' '` ]; then echo Updated: $(1); cp x $(1); fi; \
	rm x
endef

$(foreach f,$(BINS),$(eval $(call set_header,$(f),share/appmgr/bin-header)))
$(foreach f,$(LIBS),$(eval $(call set_header,$(f),share/appmgr/lib-header)))
set-headers: $(addprefix set_header-,$(BINS)) $(addprefix set_header-,$(LIBS))

.PHONY: set-headers

# If you want to add your own goals or utilities, put them in Makefile.local
-include Makefile.local
