#!/bin/bash

outCSV="cs_parsed.csv"

python3 cs_csv_parse.py cs.csv parsing.rules.json $outCSV
