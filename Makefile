all: test

BATS=$(patsubst test/%,%,$(wildcard test/*.bats))
TESTS=$(addprefix bats-,$(BATS))

bats-%:
	@echo === test/$(patsubst bats-%,%,$@)
	@bats test/$(patsubst bats-%,%,$@)

test: $(TESTS)
	@echo BATS=$(BATS)
	@echo TESTS=$(TESTS)

.PHONY: test
