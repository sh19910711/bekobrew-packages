#!/bin/bash

source ./lib/utils.sh

test_is_feature_branch() {
  TRAVIS_BRANCH="feature/branch" is_feature_branch
  local ret=$?
  assertEquals ${SHUNIT_TRUE} ${ret}

  TRAVIS_BRANCH="afeature/branch" is_feature_branch
  local ret=$?
  assertNotEquals ${SHUNIT_TRUE} ${ret}
}

test_is_master_or_develop_branch() {
  TRAVIS_BRANCH="master" is_master_or_develop_branch
  local ret=$?
  assertEquals ${SHUNIT_TRUE} ${ret}

  TRAVIS_BRANCH="develop" is_master_or_develop_branch
  local ret=$?
  assertEquals ${SHUNIT_TRUE} ${ret}

  TRAVIS_BRANCH="feature/branch" is_master_or_develop_branch
  local ret=$?
  assertNotEquals ${SHUNIT_TRUE} ${ret}
}

source ./test/lib/shunit2-2.1.6/src/shunit2
