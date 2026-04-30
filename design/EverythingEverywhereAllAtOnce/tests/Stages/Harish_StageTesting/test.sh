#!/bin/bash

mioTestPath="config/MMIO/"

scriptDir=$(pwd);

allTestCasePaths=(
    "config/TheBigOne/"
    "config/dcache_public/"
    "config/MovHeavy/"
    "config/simpleFarTest/"
    "config/exception_public/"
    "config/BranchHeavy/"
    "config/EdgeCase/"
    "config/DecodeStress/"
    "config/MemHeavy/")

outDir="Test_Results/"

SingleTest() {
    casePath="${scriptDir}/$1"
    base=$(basename "$casePath") 
    testCaseOutDir="$scriptDir/$outDir/$base/"

    echo "Running the $casePath test case, results are in $testCaseOutDir"
    #make clean
    #make gen TEST_CASE_PATH="${casePath}" LOG_DIR="${testCaseOutDir}"
    #make sim-run TEST_CASE_PATH="${casePath}" LOG_DIR="${testCaseOutDir}"
    make full TEST_CASE_PATH="${casePath}" LOG_DIR="${testCaseOutDir}"

    #-DTEST_CASE_PATH="$casePath"
}

MioTest() {
    echo "Mio Test Case called"
    SingleTest "$mioTestPath"
}

AllTests() {
    echo "Running All"

    for caseDir in "${allTestCasePaths[@]}"; do
        SingleTest "$caseDir"
    done
}

if (( $# < 1 )); then
    echo "Usage: ./test.sh -s <path> | -m | -a"
    exit 1
fi

mkdir -p ${outDir}/

source venv/bin/activate

while getopts "s:mac" opt; do
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
        c)
            rm -rf $outDir
            ;;

        *)
            echo "Invalid option"
            exit 1
            ;;
    esac
done


