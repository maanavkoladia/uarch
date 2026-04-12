#!/bin/bash

outCSV="cs_parsed.csv"

sed -i 's/\t/,/g' cs.csv
python3.11 cs_csv_parse.py cs.csv parsing.rules.json $outCSV
