all: test docs

BINS=$(wildcard bin/app-*) $(wildcard libexec/app-*)

BATS=$(sort $(patsubst test/%,%,$(filter-out test/X-%,$(wildcard test/*.bats))))
TESTS=$(addprefix test-,$(BATS))

test-%:
	@echo === $@
	@bats $(patsubst test-%,test/%,$@)

show-tests:
	@echo BATS=$(BATS)
	@echo TESTS=$(TESTS)
	@echo $(addprefix set_header-,$(BINS))

test: $(TESTS)
.PHONY: test

clean:
	@make -s -C docs clean
.PHONY: clean

docs:
	@make -s -C docs
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
