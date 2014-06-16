#!/bin/bash

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

# テスト対象となるパッケージ名のリストを取得
function get_tested_package_names() {
  local refname=`get_oldref`
  for dirname in `git diff-tree --name-only --no-commit-id HEAD..${refname}`; do
    if [ -f "${dirname}/BEKOBUILD" ]; then
      echo ${dirname}
    fi
  done
}

# テスト対象となるパッケージのリストを取得（バージョン文字列を含むこと）
function get_tested_package_fullnames() {
  for package_name in `get_tested_package_names`; do
    source "${package_name}/BEKOBUILD"
    echo ${package_name}-${package_version}-${package_release}
  done
}

# テストを実行する
function run_test() {
  local package_name=$1
  pushd ${package_name}
  bekobrew makepkg
  local ret=$?
  if [ ${ret} -eq 0 ]; then
    # TODO: テストを通ったパッケージの一覧に追加する
    echo test
  fi
  popd
}

