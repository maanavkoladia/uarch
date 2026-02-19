#!/bin/bash
builddr=build
case $1 in
-c)
    make clean
    bear -- make
    mv compile_commands.json ${builddr}
    ;;

*)
    make clean
    bear -- make DEBUG=DEBUG
    mv compile_commands.json ${builddr}
    ;;
esac
