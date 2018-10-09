#!/usr/bin/env bash
## Builder
readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License (includes shunit2, released under the Apache License)"
readonly CLI_DESC="basic unit and integration testing (part of the dc-tooling suite)"
readonly CLI_USAGE="[-s] [--type=unit|integration] --test=test_dirs_or_files source_files_or_directories"

dc::commander::init
