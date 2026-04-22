#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 -m | -a | -u"
    exit 1
fi

./compile.sh
./masterMaker.sh

case $1 in
-m)
    build/exe.elf \
        ucode6 \
        objtestfiles/srcMaster.obj \
        objtestfiles/srcMasterInit.obj
    ;;

-a)
    build/exe.elf \
        ucode6 \
        objtestfiles/asrc.obj \
        objtestfiles/asrc_init.obj
    ;;

-u)
    build/exe.elf \
        ucode6 \
        objtestfiles/add.obj \
        objtestfiles/data.obj
    ;;
-i)
    build/exe.elf \
        ucode6 \
        objtestfiles/add_instr.obj
    ;;
-s)
    build/exe.elf \
        ucode6 \
        objtestfiles/stb.obj
    ;;
-ex0)
    build/exe.elf \
        ucode6 \
        objtestfiles/ex0.obj
    ;;
-ex1)
    build/exe.elf \
        ucode6 \
        objtestfiles/ex1.obj
    ;;
-ex2)
    build/exe.elf \
        ucode6 \
        objtestfiles/ex2.obj
    ;;

*)
    echo "Invalid option. Use -m, -a, -ai, -u, -c, or -all."
    exit 1
    ;;
esac
