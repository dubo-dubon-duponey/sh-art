DC_PREFIX ?= $(shell pwd)
DC_MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
DC_MAKEFILE_DIR := $(patsubst %/,%,$(dir $(DC_MAKEFILE_PATH)))

#    $@ evaluates to target name
#    $< evaluates to first dependency
#    $^ evaluates to all dependencies

all: build lint test

# Make happy
.PHONY: build-tooling build-library build-binaries lint-signed lint-code test-unit test-integration build lint test clean

#######################################################
# Base private tasks
#######################################################

# This builds the bootstrapping builder, and never refreshed unless clean is called
$(DC_MAKEFILE_DIR)/bin/bootstrap/builder: $(DC_MAKEFILE_DIR)/bootstrap
	$(DC_MAKEFILE_DIR)/bootstrap

# Then build the cli tools, using the bootstrapper
$(DC_PREFIX)/bin/dc-tooling-%: $(DC_MAKEFILE_DIR)/source/core/*.sh $(DC_MAKEFILE_DIR)/source/cli-tooling/%
	$(DC_MAKEFILE_DIR)/bin/bootstrap/builder --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT license" --author="dubo-dubon-duponey" --description="another fancy (tooling) piece of shcript" --with-git-info $^

#######################################################
# Base building tasks
#######################################################

# Builds the main library
$(DC_PREFIX)/lib/dc-sh-art: $(DC_MAKEFILE_DIR)/source/core/*.sh
	$(DC_PREFIX)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT license" --author="dubo-dubon-duponey" --description="the library version" --with-git-info $^

# Builds the extensions
$(DC_PREFIX)/lib/dc-sh-art-extensions: $(DC_MAKEFILE_DIR)/source/extensions/**/*.sh
	$(DC_PREFIX)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT license" --author="dubo-dubon-duponey" --description="extensions" $^

# Builds all the CLIs that depend just on the main library
$(DC_PREFIX)/bin/dc-%: $(DC_PREFIX)/lib/dc-sh-art $(DC_MAKEFILE_DIR)/source/cli/%
	$(DC_PREFIX)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT license" --author="dubo-dubon-duponey" --description="another fancy piece of shcript" $^

# Builds all the CLIs that depend on the main library and extensions
$(DC_PREFIX)/bin/dc-%: $(DC_PREFIX)/lib/dc-sh-art $(DC_PREFIX)/lib/dc-sh-art-extensions $(DC_MAKEFILE_DIR)/source/cli-ext/%
	$(DC_PREFIX)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT license" --author="dubo-dubon-duponey" --description="another fancy piece of shcript" $^

#######################################################
# Tasks to be called on
#######################################################

# High-level task for embedders to build just the tooling
build-tooling: $(DC_MAKEFILE_DIR)/bin/bootstrap/builder $(patsubst $(DC_MAKEFILE_DIR)/source/cli-tooling/%/cmd.sh,$(DC_PREFIX)/bin/dc-tooling-%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli-tooling/*/cmd.sh))

# High-level task to build the library, and extensions
build-library: $(DC_MAKEFILE_DIR)/bin/bootstrap/builder $(DC_PREFIX)/bin/dc-tooling-build $(DC_PREFIX)/lib/dc-sh-art $(DC_PREFIX)/lib/dc-sh-art-extensions

# High-level task to build all non tooling CLIs
build-binaries: build-library $(patsubst $(DC_MAKEFILE_DIR)/source/cli-ext/%/cmd.sh,$(DC_PREFIX)/bin/dc-%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli-ext/*/cmd.sh)) \
				$(patsubst $(DC_MAKEFILE_DIR)/source/cli/%/cmd.sh,$(DC_PREFIX)/bin/dc-%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli/*/cmd.sh))

# Git sanity
lint-signed: $(DC_MAKEFILE_DIR)/bin/bootstrap/builder $(DC_PREFIX)/bin/dc-tooling-git
	$(DC_PREFIX)/bin/dc-tooling-git $(DC_MAKEFILE_DIR)

# Linter
lint-code: $(DC_MAKEFILE_DIR)/bin/bootstrap/builder $(DC_PREFIX)/bin/dc-tooling-lint
	$(DC_PREFIX)/bin/dc-tooling-lint .
	$(DC_PREFIX)/bin/dc-tooling-lint ~/.profile

# Unit tests
test-unit: $(DC_MAKEFILE_DIR)/bin/bootstrap/builder $(DC_PREFIX)/bin/dc-tooling-test
	$(DC_PREFIX)/bin/dc-tooling-test --type=unit --tests=$(DC_MAKEFILE_DIR)/tests/unit

# Integration tests
integration/%: $(DC_MAKEFILE_DIR)/bin/bootstrap/builder $(DC_PREFIX)/bin/dc-tooling-test
	$(DC_PREFIX)/bin/dc-tooling-test --type=integration --tests=$(DC_MAKEFILE_DIR)/tests/$@

test-integration: $(patsubst $(DC_MAKEFILE_DIR)/source/cli/%/cmd.sh,integration/%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli/*/cmd.sh))

build: build-library build-binaries
lint: lint-code lint-signed
test: test-unit test-integration

# Simple clean: rm bin & lib
clean:
	rm -Rf "${DC_PREFIX}/bin"
	rm -Rf "${DC_PREFIX}/lib"
