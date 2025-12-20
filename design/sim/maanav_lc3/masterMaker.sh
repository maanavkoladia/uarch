#!/bin/bash

# Assemble source files into object files using `assembler.linux`

# Assemble `srcMaster.asm` into `srcMaster.obj`
./assembler.linux asmtestfiles/srcMaster.asm objtestfiles/srcMaster.obj
./assembler.linux asmtestfiles/srcMasterInit.asm objtestfiles/srcMasterInit.obj

# Assemble `asrc.asm` into `asrc.obj`
./assembler.linux asmtestfiles/asrc.asm objtestfiles/asrc.obj
./assembler.linux asmtestfiles/asrc_init.asm objtestfiles/asrc_init.obj

# Assemble `add.asm` into `add.obj`
./assembler.linux asm_files/add.asm objtestfiles/add.obj

# Assemble `data.asm` into `data.obj`
./assembler.linux asm_files/data.asm objtestfiles/data.obj

# assmeble 'add_instru'
./assembler.linux asmtestfiles/add_instr.asm objtestfiles/add_instr.obj

./assembler.linux asmtestfiles/ex0.asm objtestfiles/ex0.obj

./assembler.linux asmtestfiles/ex1.asm objtestfiles/ex1.obj

./assembler.linux asmtestfiles/ex2.asm objtestfiles/ex2.obj

./assembler.linux asmtestfiles/stb.asm objtestfiles/stb.obj
