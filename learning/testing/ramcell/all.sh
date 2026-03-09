#!/bin/bash
vcs -full64 -debug_all -sverilog -f master
./simv
dve -full64

