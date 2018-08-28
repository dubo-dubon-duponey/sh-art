#!/usr/bin/env bash

# Test the tester
dc-tools::assert::notequal " " $'\n'
dc-tools::assert::notequal " " $'\t'
dc-tools::assert::notequal " " $'\r'
dc-tools::assert::notequal $'\r' $'\n'

dc-tools::assert::equal 1 "1"

dc-tools::assert::notnull 0
dc-tools::assert::null ""
dc-tools::assert::null
