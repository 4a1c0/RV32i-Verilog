This Repository is a work in progress.

# RV32i-Verilog
Simple RiscV core for academic purpose. 

[![Build Status](https://travis-ci.com/4a1c0/RV32i-Verilog.svg?branch=master)](https://travis-ci.com/4a1c0/RV32i-Verilog)

The Repository is organized as follows:
  * [Quartus](Quartus) (FPGA Implementation with Quartus software): this directory contains the projects that implement the core in an FPGA.
  * [Data](data): this directory contains memory initializations for the simulations.
  * [Diagrams](diagrams): this directory contains several diagrams of the architecture.
  * [pulp](pulp) (PULPino RamMux): this directory contains the implemntation for the memory acces of the [PULPino platform](https://github.com/pulp-platform/pulpino).
  * [riscv-gnu-toolchain](riscv-gnu-toolchain): this directory contains the files necessary to complie C programs into RISC-V RV32I code.
  * [src](src): this directory contains the source code of the core in Verilog.
  * [tb](tb): this directory contains the Verilog Testbenchs.
  * [vcd](vcd): this directory contains Vcd dumps to analyze the core internal signals.
  
