#!/bin/bash

cd ../../../rtl/core/Decode/cs_roms/
./parse.sh
cd -
cd ../../../
make gen
cd -
cat ../../../rtl/core/Decode/cs_roms/cs_parse.log
echo "must run this in Harish_Stages dir\n"