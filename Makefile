DC_MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# Output directory
DC_PREFIX ?= $(shell pwd)

# Set to true to disable fancy / colored output
DC_NO_FANCY ?=

# Fancy output if interactive
ifndef DC_NO_FANCY
    NC := \033[0m
    GREEN := \033[1;32m
    ORANGE := \033[1;33m
    BLUE := \033[1;34m
    RED := \033[1;31m
endif

# Helper to put out nice title
define title
	@echo "$(GREEN)------------------------------------------------------------------------------------------------------------------------"
	@printf "$(GREEN)%*s\n" $$(( ( $(shell echo "☆ $(1) ☆" | wc -c ) + 120 ) / 2 )) "☆ $(1) ☆"
	@echo "$(GREEN)------------------------------------------------------------------------------------------------------------------------$(ORANGE)"
endef

# List of dckr platforms to test
DCKR_PLATFORMS ?= ubuntu-lts-old ubuntu-lts-current ubuntu-current ubuntu-next alpine-current alpine-next debian-old debian-current debian-next

#######################################################
# Targets
#######################################################
all: build lint test test-all

# Make happy
.PHONY: build-tooling build-library build-binaries lint-signed lint-code test-unit test-integration test-all build lint test clean

#######################################################
# Base private tasks
#######################################################

# This builds the bootstrapping builder, and never refreshed unless clean is called
$(DC_PREFIX)/bin/bootstrap/builder: $(DC_MAKEFILE_DIR)/bootstrap
	$(call title, $@)
	$(DC_MAKEFILE_DIR)/bootstrap $(DC_PREFIX)

# Then build the cli tools, using the bootstrapper
$(DC_PREFIX)/bin/dc-tooling-%: $(DC_MAKEFILE_DIR)/source/core/*.sh $(DC_MAKEFILE_DIR)/source/cli-tooling/%
	$(call title, $@)
	$(DC_PREFIX)/bin/bootstrap/builder --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT License" --author="dubo-dubon-duponey" --description="another fancy (tooling) piece of shcript" --with-git-info $^

#######################################################
# Base building tasks
#######################################################

# Builds the main library
$(DC_PREFIX)/lib/dc-sh-art: $(DC_MAKEFILE_DIR)/source/core/*.sh
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT License" --author="dubo-dubon-duponey" --description="the library version" --with-git-info $^

# Builds the extensions
$(DC_PREFIX)/lib/dc-sh-art-extensions: $(DC_MAKEFILE_DIR)/source/extensions/**/*.sh
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT License" --author="dubo-dubon-duponey" --description="extensions" $^

# Builds all the CLIs that depend just on the main library
$(DC_PREFIX)/bin/dc-%: $(DC_PREFIX)/lib/dc-sh-art $(DC_MAKEFILE_DIR)/source/cli/%
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT License" --author="dubo-dubon-duponey" --description="another fancy piece of shcript" $^

# Builds all the CLIs that depend on the main library and extensions
$(DC_PREFIX)/bin/dc-%: $(DC_PREFIX)/lib/dc-sh-art $(DC_PREFIX)/lib/dc-sh-art-extensions $(DC_MAKEFILE_DIR)/source/cli-ext/%
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT License" --author="dubo-dubon-duponey" --description="another fancy piece of shcript" $^

#######################################################
# Tasks to be called on
#######################################################

# High-level task for embedders to build just the tooling
build-tooling: $(DC_PREFIX)/bin/bootstrap/builder $(patsubst $(DC_MAKEFILE_DIR)/source/cli-tooling/%/cmd.sh,$(DC_PREFIX)/bin/dc-tooling-%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli-tooling/*/cmd.sh))

# High-level task to build the library, and extensions
build-library: build-tooling $(DC_PREFIX)/lib/dc-sh-art $(DC_PREFIX)/lib/dc-sh-art-extensions

# High-level task to build all non tooling CLIs
build-binaries: build-library $(patsubst $(DC_MAKEFILE_DIR)/source/cli-ext/%/cmd.sh,$(DC_PREFIX)/bin/dc-%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli-ext/*/cmd.sh)) \
				$(patsubst $(DC_MAKEFILE_DIR)/source/cli/%/cmd.sh,$(DC_PREFIX)/bin/dc-%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli/*/cmd.sh))

# Git sanity
lint-signed: build-tooling
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-git $(DC_MAKEFILE_DIR)

# Linter
#	XXX broken for now $(DC_PREFIX)/bin/dc-tooling-lint $(DC_PREFIX)/bin
lint-code: build-tooling build-library build-binaries
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-lint $(DC_MAKEFILE_DIR)/bootstrap
	$(DC_PREFIX)/bin/dc-tooling-lint $(DC_MAKEFILE_DIR)/source
	$(DC_PREFIX)/bin/dc-tooling-lint $(DC_MAKEFILE_DIR)/tests
	$(DC_PREFIX)/bin/dc-tooling-lint $(DC_PREFIX)/lib
	$(DC_PREFIX)/bin/dc-tooling-lint ~/.profile

# Unit tests
unit/%: build-tooling
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-test $(DC_MAKEFILE_DIR)/tests/$@

test-unit: $(patsubst $(DC_MAKEFILE_DIR)/tests/unit/%,unit/%,$(wildcard $(DC_MAKEFILE_DIR)/tests/unit/*.sh))

# Integration tests
integration/%: build-tooling $(DC_PREFIX)/bin/dc-%
	$(call title, $@)
	PATH=$(DC_PREFIX)/bin:${PATH} $(DC_PREFIX)/bin/dc-tooling-test $(DC_MAKEFILE_DIR)/tests/$@/*.sh

test-integration: $(patsubst $(DC_MAKEFILE_DIR)/source/cli/%/cmd.sh,integration/%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli/*/cmd.sh)) \
	$(patsubst $(DC_MAKEFILE_DIR)/source/cli-ext/%/cmd.sh,integration/%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli-ext/*/cmd.sh))

dckr/%:
	$(call title, $@)
	DOCKERFILE=./dckr.Dockerfile TARGET="$(patsubst dckr/%,%,$@)" dckr make test

test-all: $(patsubst %,dckr/%,$(DCKR_PLATFORMS))

build: build-tooling build-library build-binaries
lint: lint-code lint-signed
test: test-unit test-integration

# Simple clean: rm bin & lib
clean:
	$(call title, $@)
	rm -Rf "${DC_PREFIX}/bin"
	rm -Rf "${DC_PREFIX}/lib"
