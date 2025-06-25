MIPS Single-Cycle and Pipeline Processors

This repo contains my implementation of MIPS Single-Cycle and Pipeline processors, developed during my Computer Architecture class.

    Single-Cycle: Executes each instruction in one clock cycle. Tested on a Digilent Nexys A7-100T board.
    Pipeline: Uses a 5-stage pipeline to improve performance. Simulated in Vivado 2024 using a testbench.

Both designs are implemented in VHDL using Vivado 2024.
Supported Instructions

    R-type: add, sub
    I-type: addi, subi, beq, bneq, bgez, lw, sw
    J-type: j

Files

    project_1/: Single-Cycle processor project
    project_2/: Pipeline processor project

Inside each project, source files are located at:
project_<number>/project_<number>.srcs/sources_<number>/new/

Testbench source file is also included there.
