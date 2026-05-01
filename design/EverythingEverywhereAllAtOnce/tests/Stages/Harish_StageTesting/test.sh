#!/bin/bash

mioTestPath="config/MMIO/"
regTestLog="regTest.log"


scriptDir=$(pwd);

allTestCasePaths=(
    "BranchHeavy"
    "dcache_public"
    "DecodeStress"
    "EdgeCase"
    "exception_public"
    "MemHeavy"
    "MovHeavy"
    "simpleFarTest"
    "TheBigOne"
)


outDir="Test_Results/"

SingleTestFull() {
    casePath="${scriptDir}/$1"
    base=$(basename "$casePath") 
    testCaseOutDir="$scriptDir/$outDir/$base/"

    echo -e "\n\n\nRunning the $casePath test case, results are in $testCaseOutDir"

    make full TEST_CASE_PATH="${casePath}" LOG_DIR="${testCaseOutDir}"

    tail ${testCaseOutDir}/compare_report.txt

    #-DTEST_CASE_PATH="$casePath"
}

MioTest() {
    echo "Mio Test Case called"
    SingleTestFull "$mioTestPath"
}

SingleTestReg(){
    casePath="${scriptDir}/$1"
    base=$(basename "$casePath") 
    testCaseOutDir="$scriptDir/$outDir/$base/"

    echo -e "\n\n\nRunning the $casePath test case, results are in $testCaseOutDir" >> $regTestLog
    #echo -e "\n\n\nRunning the $casePath test case, results are in $testCaseOutDir" 
    mkdir -p $testCaseOutDir
    make full TEST_CASE_PATH="${casePath}" LOG_DIR="${testCaseOutDir}"
    
    tail ${testCaseOutDir}/compare_report.txt >> $regTestLog 

}

AllTests() {
    echo "Starting Reg Testing"
    rm -rf $outDir
    rm $regTestLog

    for caseDir in "${allTestCasePaths[@]}"; do
        SingleTestReg "$caseDir"
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
            SingleTestFull "$OPTARG"
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


