#!/usr/bin/env bash

TEST_NULL=""
TEST_NOT_NULL="foo"
TEST_EQUAL="bar"
TEST_EQUAL_TOO="bar baz foo"

dc-tools::assert::null TEST_NULL
# tests::null TEST_NOT_NULL
dc-tools::assert::notnull TEST_NOT_NULL
# tests::notnull TEST_NULL
dc-tools::assert::equal TEST_EQUAL bar
# tests::equal TEST_EQUAL foo
dc-tools::assert::notequal TEST_EQUAL baz
# tests::notequal TEST_EQUAL bar
dc-tools::assert::equal TEST_EQUAL_TOO "bar baz foo"
