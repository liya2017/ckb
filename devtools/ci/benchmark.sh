#!/usr/bin/env bash
set -euo pipefail
SCRIPT_PATH="$GITHUB_WORKSPACE/ckb-integration-test/ckb-bench/devtools/ci"
JOB_ID="benchmark-$(date +'%Y-%m-%d')-in-10h"
JOB_DIRECTORY="$SCRIPT_PATH/job/$JOB_ID"
ANSIBLE_DIR="$GITHUB_WORKSPACE/ansible"
mkdir $ANSIBLE_DIR
echo "ANSIBLE_DIR=$ANSIBLE_DIR" >> $GITHUB_ENV
function benchmark() {
    $SCRIPT_PATH/script/benchmark.sh run
    cp $JOB_DIRECTORY/ansible/ckb-bench.log $ANSIBLE_DIR
    # TODO: copy report.yml to $ANSIBLE_DIR
    $SCRIPT_PATH/script/benchmark.sh clean
}

function github_report_error() {
    $SCRIPT_PATH/script/ok.sh add_comment nervosnetwork/ckb 2372 "**Sync-Mainnet Report**:\nSync-Mainnet crashed"

    # double check
    $SCRIPT_PATH/script/benchmark.sh clean
}

function main() {
    benchmark || github_report_error
}
main $*