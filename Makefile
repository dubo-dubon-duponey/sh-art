DC_PREFIX ?= $(shell pwd)
DC_MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
DC_MAKEFILE_DIR := $(patsubst %/,%,$(dir $(DC_MAKEFILE_PATH)))

#all: library.cpp main.cpp
#    $@ evaluates to all
#    $< evaluates to library.cpp
#    $^ evaluates to library.cpp main.cpp

all: binaries lint test

#######################################################
# Base private tasks
#######################################################

# Make happy
.PHONY: init library binaries lint unit integration test clean

# This builds the bootstrapping builder, and never refreshed unless clean is called
$(DC_MAKEFILE_DIR)/bin/bootstrap/dc-tooling-build: $(DC_MAKEFILE_DIR)/bootstrap
	$(DC_MAKEFILE_DIR)/bootstrap

# Builds the main library
$(DC_PREFIX)/lib/dc-sh-art: $(DC_MAKEFILE_DIR)/source/core/*.sh
	$(DC_MAKEFILE_DIR)/bin/bootstrap/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT license" --author="dubo-dubon-duponey" --with-git-info --description="the library version" $^

# Builds the extensions
$(DC_PREFIX)/lib/dc-sh-art-extensions: $(DC_MAKEFILE_DIR)/source/extensions/**/*.sh
	$(DC_MAKEFILE_DIR)/bin/bootstrap/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT license" --author="dubo-dubon-duponey" --description="extensions" $^

# Builds all the CLIs that depend just on the main library
$(DC_PREFIX)/bin/dc-%: $(DC_PREFIX)/lib/dc-sh-art $(DC_MAKEFILE_DIR)/source/cli/%
	$(DC_MAKEFILE_DIR)/bin/bootstrap/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT license" --author="dubo-dubon-duponey" --description="another fancy piece of shcript" $^

# Builds all the tooling CLIs
$(DC_PREFIX)/bin/dc-tooling-%: $(DC_PREFIX)/lib/dc-sh-art $(DC_MAKEFILE_DIR)/source/cli-tooling/%
	$(DC_MAKEFILE_DIR)/bin/bootstrap/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT license" --author="dubo-dubon-duponey" --description="another fancy piece of shcript" $^

# Builds all the CLIs that depend on the main library and extensions
$(DC_PREFIX)/bin/dc-%: $(DC_PREFIX)/lib/dc-sh-art $(DC_PREFIX)/lib/dc-sh-art-extensions $(DC_MAKEFILE_DIR)/source/cli-ext/%
	$(DC_MAKEFILE_DIR)/bin/bootstrap/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT license" --author="dubo-dubon-duponey" --description="another fancy piece of shcript" $^

#######################################################
# Tasks to be called on
#######################################################

# High-level task to build the boostrapper
init: $(DC_MAKEFILE_DIR)/bin/bootstrap/dc-tooling-build

# High-level task to build the library, and extensions
library: init $(DC_PREFIX)/lib/dc-sh-art $(DC_PREFIX)/lib/dc-sh-art-extensions

# High-level task for embedders to build just the library and tooling
embed: library $(patsubst source/cli-tooling/%/cmd.sh,$(DC_PREFIX)/bin/dc-tooling-%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli-tooling/*/cmd.sh))

# High-level task to build all
binaries: library $(patsubst source/cli-ext/%/cmd.sh,$(DC_PREFIX)/bin/dc-%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli-ext/*/cmd.sh)) \
				$(patsubst source/cli/%/cmd.sh,$(DC_PREFIX)/bin/dc-%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli/*/cmd.sh))

# Linter
lint: init $(DC_PREFIX)/bin/dc-tooling-lint
	$(DC_PREFIX)/bin/dc-tooling-lint .
	$(DC_PREFIX)/bin/dc-tooling-lint ~/.profile

unit: $(DC_PREFIX)/bin/dc-tooling-test
	$(DC_PREFIX)/bin/dc-tooling-test --type=unit --tests=$(DC_MAKEFILE_DIR)/tests/unit

integration/%: $(DC_PREFIX)/bin/dc-tooling-test
	$(DC_PREFIX)/bin/dc-tooling-test --type=integration --tests=$(DC_MAKEFILE_DIR)/tests/$@

integration: $(patsubst $(DC_MAKEFILE_DIR)/source/cli/%/cmd.sh,integration/%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli/*/cmd.sh))

test: unit integration

# Simple clean: rm bin & lib
clean:
	rm -Rf "${DC_PREFIX}/bin"
	rm -Rf "${DC_PREFIX}/lib"
