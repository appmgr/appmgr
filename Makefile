all: test

BINS=$(wildcard bin/app-*) $(wildcard libexec/app-*)

BATS=$(sort $(patsubst test/%,%,$(filter-out test/X-%,$(wildcard test/*.bats))))
TESTS=$(addprefix bats-,$(BATS))

bats-%:
	@echo === test/$(patsubst bats-%,%,$@)
	@bats test/$(patsubst bats-%,%,$@)

show-tests:
	@echo BATS=$(BATS)
	@echo TESTS=$(TESTS)
	@echo $(addprefix set_header-,$(BINS))

test: show-tests $(TESTS)
.PHONY: test

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
