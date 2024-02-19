DC_MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# Output directory
DC_PREFIX ?= $(shell pwd)

# Set to true to disable fancy / colored output
DC_NO_FANCY ?=

# List of dckr platforms to test
DCKR_PLATFORMS ?= alpine-316 alpine-317 alpine-318 alpine-319 alpine-next ubuntu-1404 ubuntu-1604 ubuntu-1804 ubuntu-2004 ubuntu-2204 ubuntu-current ubuntu-next debian-10 debian-11 debian-12 debian-current debian-next

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
	@printf "$(GREEN)----------------------------------------------------------------------------------------------------\n"
	@printf "$(GREEN)%*s\n" $$(( ( $(shell echo "☆ $(1) ☆" | wc -c ) + 100 ) / 2 )) "☆ $(1) ☆"
	@printf "$(GREEN)----------------------------------------------------------------------------------------------------\n$(ORANGE)"
endef

define footer
	@printf "$(GREEN)> %s: done!\n" "$(1)"
	@printf "$(GREEN)____________________________________________________________________________________________________\n$(NC)"
endef

DC_AUTHOR := Dubo Dubon Duponey
DC_LICENSE := MIT License

#######################################################
# Targets
#######################################################
all: build lint test test-all

# Make happy
.PHONY: build-builder build-tooling build-library build-binaries lint-signed lint-code test-unit test-integration test-all build lint test clean

#######################################################
# Base private tasks
#######################################################

# This builds the bootstrapping builder
$(DC_PREFIX)/bin/bootstrap/builder: $(DC_MAKEFILE_DIR)/bootstrap $(DC_MAKEFILE_DIR)/source/cli-tooling/build/base-build.sh
	$(call title, $@)
	$(DC_MAKEFILE_DIR)/bootstrap $(DC_PREFIX)
	$(call footer, $@)

# This builds the builder
$(DC_PREFIX)/bin/dc-tooling-build: $(sort $(wildcard $(DC_MAKEFILE_DIR)/source/core/*.sh)) $(DC_MAKEFILE_DIR)/source/cli-tooling/build
	$(call title, $@)
	$(DC_PREFIX)/bin/bootstrap/builder --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="$(DC_LICENSE)" --author="$(DC_AUTHOR)" --description="a script builder, part of the dc-tooling set of utilities" --with-git-info $^
	$(call footer, $@)

# Depend on this to get the builder built
build-builder: $(DC_PREFIX)/bin/bootstrap/builder $(DC_PREFIX)/bin/dc-tooling-build

#######################################################
# Base building tasks
#######################################################
# Builds the main library
$(DC_PREFIX)/lib/lib-dc-mini: $(sort $(wildcard $(DC_MAKEFILE_DIR)/source/core/*.sh))
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="$(DC_LICENSE)" --author="$(DC_AUTHOR)" --description="the library version" --with-git-info=DC_LIB $(sort $^)
	$(call footer, $@)

# Builds the main library
$(DC_PREFIX)/lib/lib-dc-sh-art: $(sort $(wildcard $(DC_MAKEFILE_DIR)/source/core/*.sh)) $(sort $(wildcard $(DC_MAKEFILE_DIR)/source/headers/*.sh)) $(sort $(wildcard $(DC_MAKEFILE_DIR)/source/lib/*.sh))
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="$(DC_LICENSE)" --author="$(DC_AUTHOR)" --description="the library version" --with-git-info=DC_LIB $(sort $^)
	$(call footer, $@)

# Builds the extensions
$(DC_PREFIX)/lib/lib-dc-sh-art-extensions: $(sort $(wildcard $(DC_MAKEFILE_DIR)/source/extensions/**/*.sh))
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="$(DC_LICENSE)" --author="$(DC_AUTHOR)" --description="extensions" $(sort $^)
	$(call footer, $@)

# Test is special (embeds shunit2 which requires some shellcheck disabling
#$(DC_PREFIX)/bin/dc-tooling-test: $(DC_PREFIX)/lib/lib-dc-mini $(DC_MAKEFILE_DIR)/source/cli-tooling/test
#	$(call title, $@)
#	$(DC_PREFIX)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="$(DC_LICENSE)" --author="$(DC_AUTHOR)" --description="a script tester, part of the dc-tooling set of utilities" --shellcheck-disable=SC2006,SC2003,SC2001,SC2166 --with-git-info $^
#	$(call footer, $@)

# All other dev tools
$(DC_PREFIX)/bin/dc-tooling-%: $(DC_PREFIX)/lib/lib-dc-mini $(DC_MAKEFILE_DIR)/source/cli-tooling/%
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="$(DC_LICENSE)" --author="$(DC_AUTHOR)" --description="part of the dc-tooling set of utilities" --with-git-info $^
	$(call footer, $@)


# Builds all the CLIs that depend just on the main library
$(DC_PREFIX)/bin/dc-%: $(DC_PREFIX)/lib/lib-dc-sh-art $(DC_MAKEFILE_DIR)/source/cli/%
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="$(DC_LICENSE)" --author="$(DC_AUTHOR)" --description="another fancy piece of shcript" --with-git-info $^
	$(call footer, $@)

# Builds all the CLIs that depend on the main library and extensions
$(DC_PREFIX)/bin/dc-%: $(DC_PREFIX)/lib/lib-dc-sh-art $(DC_PREFIX)/lib/lib-dc-sh-art-extensions $(DC_MAKEFILE_DIR)/source/cli-ext/%
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="$(DC_LICENSE)" --author="$(DC_AUTHOR)" --description="another fancy piece of shcript" --with-git-info $^
	$(call footer, $@)

#######################################################
# Tasks to be called on
#######################################################

# High-level task for embedders to build just the tooling
build-tooling: build-builder $(patsubst $(DC_MAKEFILE_DIR)/source/cli-tooling/%/cmd.sh,$(DC_PREFIX)/bin/dc-tooling-%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli-tooling/*/cmd.sh))

# High-level task to build the library, and extensions
build-library: build-builder $(DC_PREFIX)/lib/lib-dc-sh-art $(DC_PREFIX)/lib/lib-dc-sh-art-extensions

# High-level task to build all non tooling CLIs
build-binaries: build-library $(patsubst $(DC_MAKEFILE_DIR)/source/cli-ext/%/cmd.sh,$(DC_PREFIX)/bin/dc-%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli-ext/*/cmd.sh)) \
				$(patsubst $(DC_MAKEFILE_DIR)/source/cli/%/cmd.sh,$(DC_PREFIX)/bin/dc-%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli/*/cmd.sh))

# Git sanity
lint-signed: build-builder $(DC_PREFIX)/bin/dc-tooling-git
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-git $(DC_MAKEFILE_DIR)
	$(call footer, $@)

# Linter
lint-code: build-binaries $(DC_PREFIX)/bin/dc-tooling-lint
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-lint $(DC_MAKEFILE_DIR)/bootstrap
	$(DC_PREFIX)/bin/dc-tooling-lint $(DC_MAKEFILE_DIR)/source
	$(DC_PREFIX)/bin/dc-tooling-lint $(DC_MAKEFILE_DIR)/tests
	$(DC_PREFIX)/bin/dc-tooling-lint $(DC_PREFIX)/lib
	$(DC_PREFIX)/bin/dc-tooling-lint $(DC_PREFIX)/bin
	$(DC_PREFIX)/bin/dc-tooling-lint ~/.profile
	$(call footer, $@)

# Unit tests
unit/%: build-builder $(DC_PREFIX)/bin/dc-tooling-test
	$(call title, $@)
	$(DC_PREFIX)/bin/dc-tooling-test $(DC_MAKEFILE_DIR)/tests/$@
	$(call footer, $@)

test-unit: $(patsubst $(DC_MAKEFILE_DIR)/tests/unit/%,unit/%,$(wildcard $(DC_MAKEFILE_DIR)/tests/unit/*.sh))

# Integration tests
integration/%: build-builder $(DC_PREFIX)/bin/dc-tooling-test $(DC_PREFIX)/bin/dc-%
	$(call title, $@)
	PATH="$(DC_PREFIX)/bin:${PATH}" $(DC_PREFIX)/bin/dc-tooling-test $(DC_MAKEFILE_DIR)/tests/$@/*.sh
	$(call footer, $@)

test-integration: $(patsubst $(DC_MAKEFILE_DIR)/source/cli/%/cmd.sh,integration/%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli/*/cmd.sh)) \
	$(patsubst $(DC_MAKEFILE_DIR)/source/cli-ext/%/cmd.sh,integration/%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli-ext/*/cmd.sh))

dckr/%:
	$(call title, $@)
	DOCKERFILE=$(DC_MAKEFILE_DIR)/dckr.Dockerfile TARGET="$(patsubst dckr/%,%,$@)" dckr make test
	$(call footer, $@)

test-all: $(patsubst %,dckr/%,$(DCKR_PLATFORMS))

build: build-tooling build-library build-binaries
lint: lint-code lint-signed
test: test-unit test-integration

# Simple clean: rm bin & lib
clean:
	$(call title, $@)
	rm -Rf "${DC_PREFIX}/bin"
	rm -Rf "${DC_PREFIX}/lib"
	$(call footer, $@)
