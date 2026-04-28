#!/bin/bash

mioTestPath="config/MMIO/"

SingleTest() {
    casePath="$1"
    echo "Running the $casePath test case"
    make see 
    #-DTEST_CASE_PATH="$casePath"
}

MioTest() {
    echo "Mio Test Case called"
    SingleTest "$mioTestPath"
}

AllTests() {
    echo "All called, will run multiple singles"
}

if (( $# < 1 )); then
    echo "Usage: ./test.sh -s <path> | -m | -a"
    exit 1
fi

while getopts "s:ma" opt; do
    case $opt in
        s)
            SingleTest "$OPTARG"
            ;;
        m)
            MioTest
            ;;
        a)
            AllTests
            ;;
        *)
            echo "Invalid option"
            exit 1
            ;;
    esac
done
