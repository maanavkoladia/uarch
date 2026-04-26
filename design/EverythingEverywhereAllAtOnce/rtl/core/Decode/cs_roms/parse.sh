#!/bin/bash

outCSV="cs_parsed.csv"
logfile="cs_parse.log"

exec > "$logfile" 2>&1   # redirect stdout + stderr

sed -i 's/\t/,/g' cs.csv
python3.11 cs_csv_parse.py cs.csv parsing.rules.json $outCSV
