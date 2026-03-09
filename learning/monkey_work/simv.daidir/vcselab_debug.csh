#!/bin/csh -f

cd /misc/scratch/he3837/UARCH/uarch/learning/monkey_work

#This ENV is used to avoid overriding current script in next vcselab run 
setenv SNPS_VCSELAB_SCRIPT_NO_OVERRIDE  1

/usr/local/packages/synopsys_2020/vcs/R-2020.12/linux64/bin/vcselab $* \
    -o \
    simv \
    -nobanner \

cd -

