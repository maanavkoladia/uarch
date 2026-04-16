#!/bin/bash

cd ../../../rtl/core/Decode/cs_roms/
./parse.sh
cd -
cd ../../../
make gen
cd -
echo "must run this in Stages dir\n"