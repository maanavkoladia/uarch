#!/bin/bash

srcPath="/home/maanav/projects/school_projects/uarch/uarch_project/design/sim/sim_func/src"

stages=(
  CISC_FETCH
  CISC_DECODE
  UOP_FIFO
  RISC_FETCH
  RISC_DECODE
  RISC_AGEX
  RISC_MEM
  RISC_WRITE_BACK
)

for file in "${stages[@]}"; do
    touch "${srcPath}/${file}.c" "${srcPath}/${file}.h"
done
