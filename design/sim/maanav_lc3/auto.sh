#!/bin/bash

dumppath=asmtestfiles/dumps
outputfile=out.txt
testfile=tester.exp
#comparefile=
#diff_file=${dumppath}/diff_$1.txt

#if [ -z "$1" ]; then
#    echo "Usage: $0 <testcase>"
#    exit 1
#fi

./compile.sh

./masterMaker.sh

echo "running expect script"
./${testfile} $1 >${outputfile}
echo "done running expect script"

# Fix Windows line endings
dos2unix ${outputfile}

# Remove first 11 lines and last 2 lines
tail -n +11 "${outputfile}" | head -n -2 >"${outputfile}.tmp" && mv "${outputfile}.tmp" "${outputfile}"

# Now diff
#diff ${comparefile} ${outputfile} >${diff_file}
