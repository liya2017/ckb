#!/bin/bash
set -u
# Usage statement
usage() {
    echo "Usage: $0 [OPTIONS]...[ARGS]"
    echo
    echo "   -n  --name <string>"
    echo "                   Required. Function name to call, such as integration_test"
}


set +e
func_ci() {
 name=${1}
 if [ $name == "ci_unit_tests" ];then
    echo "ci_unit_tests"
    make test
    EXIT_CODE=$?
 fi
 if [ $name == "ci_benchmarks_test" ];then
    echo "ci_benchmarks_test"
    make bench-test
    EXIT_CODE=$?
 fi
#  if [ $name == "ci_integration_test" ];then
#     echo "ci_integration_test"
#     if [ $OS_NAME == "Windows" ];then
#        "${workspace}/devtools/windows/make" CKB_TEST_SEC_COEFFICIENT=5 CKB_TEST_ARGS="-c 4 --no-report" integration
#     fi
#    if [ $OS_NAME == "Linux" ] || [ $OS_NAME == "macOS" ];then
#        make CKB_TEST_SEC_COEFFICIENT=5 CKB_TEST_ARGS="-c 4 --no-report" integration
#     fi
#  fi
 if [ $name == "ci_quick_check" ];then
    echo "ci_quick_check"
    make check-cargotoml
    make check-whitespaces
    make check-dirty-rpc-doc
    make check-dirty-hashes-toml
    devtools/ci/check-cyclic-dependencies.py
    EXIT_CODE=$?
 fi
 if [ $name == "ci_linters" ];then
    echo "ci_linters"
    cargo fmt --version ||  rustup component add rustfmt
    cargo clippy --version ||  rustup component add clippy
    make fmt
    make clippy
    git diff --exit-code Cargo.lock
    EXIT_CODE=$?
 fi
 if [ $name == "ci_security_audit_licenses" ];then
    echo "ci_security_audit_licenses"
    cargo deny --version || cargo install cargo-deny --locked
    make security-audit
    make check-crates
    make check-licenses
    EXIT_CODE=$?
 fi
 if [ $name == "ci_WASM_build" ];then
    echo "ci_WASM_build"
    rustup target add wasm32-unknown-unknown
    make wasm-build-test
    EXIT_CODE=$?
 fi
 EXIT_CODE=$EXIT_CODE
}

name="$1"
func_ci $name
EXIT_STATUS=$EXIT_CODE
echo "EXIT_STATUS:"$EXIT_STATUS
set -e
if [ "$EXIT_STATUS" = 0 ]; then
    echo "Check whether the ci succeeds"
else
    echo "Fail the ci"
fi
exit $EXIT_STATUS