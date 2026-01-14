#!/bin/bash

gcc -std=c99 -o lc3bsim6 lc3bsim6.c

./lc3bsim6 ucode6.txt example0.hex < sim_commands.txt
