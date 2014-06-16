#!/bin/bash

GOOD_PACKAGE_LIST_FILENAME=good_packages

# HEADに最大で3つの~を付けて出力する
function get_oldref() {
  local refname="HEAD"
  for i in `seq 1 3`; do
    local next_refname="${refname}~"
    git rev-parse ${next_refname} >/dev/null 2>&1
    local ret=$?
    if [ ${ret} -eq 0 ]; then
      refname=${next_refname}
    fi
  done
  echo ${refname}
}

# すべてのパッケージの名前を取得する
function get_all_package_names() {
  for dirname in `ls -1`; do
    if [ -f "${dirname}/BEKOBUILD" ]; then
      echo ${dirname}
    fi
  done
}

# すべてのパッケージの名前を取得する（バージョン文字列を含む）
function get_all_package_fullnames() {
  for package_name in `get_all_package_names`; do
    source "${package_name}/BEKOBUILD"
    echo ${package_name}-${package_version}-${package_release}
  done
}

function get_tested_package_names_func() {
  local refname="HEAD"
  for i in `seq 1 3`; do
    for dirname in `git diff-tree --name-only --no-commit-id ${refname}`; do
      if [ -f "${dirname}/BEKOBUILD" ]; then
        echo ${dirname}
      fi
    done

    local next_refname="${refname}~"
    git rev-parse ${next_refname} >/dev/null 2>&1
    local ret=$?
    if [ ${ret} -eq 0 ]; then
      refname=${next_refname}
    else
      break
    fi
  done
}

# テスト対象となるパッケージ名のリストを取得
function get_tested_package_names() {
  get_tested_package_names_func | sort | uniq
}


# テスト対象となるパッケージのリストを取得（バージョン文字列を含むこと）
function get_tested_package_fullnames() {
  for package_name in `get_tested_package_names`; do
    source "${package_name}/BEKOBUILD"
    echo ${package_name}-${package_version}-${package_release}
  done
}

function is_feature_branch() {
  [[ "${TRAVIS_BRANCH}" =~ ^feature\/ ]]
}

function is_master_or_develop_branch() {
  [[ "${TRAVIS_BRANCH}" == "master" ]] || [[ "${TRAVIS_BRANCH}" == "develop" ]]
}

# テストを実行する
function run_test() {
  local package_name=$1
  pushd ${package_name}
  bekobrew makepkg
  local ret=$?
  if [ ${ret} -eq 0 ]; then
    local repo_dir=tmp/bekobrew-packages
    git clone --single-branch -b misc git://github.com/sh19910711/bekobrew-packages.git ${repo_dir}
    cd ${repo_dir}
    echo ${package_name} >> ${GOOD_PACKAGE_LIST_FILENAME}
    git add ${GOOD_PACKAGE_LIST_FILENAME}
    git commit --allow-empty -m "update ${GOOD_PACKAGE_LIST_FILENAME}"
    git push --quiet https://${GITHUB_TOKEN}@github.com/sh19910711/bekobrew-packages.git misc 2> /dev/null
  fi
  popd
}

