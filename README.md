This Repository is a work in progress.

# RV32i-Verilog
Simple RiscV core for academic purpose. 

[![Build Status](https://travis-ci.com/4a1c0/RV32i-Verilog.svg?branch=master)](https://travis-ci.com/4a1c0/RV32i-Verilog)

The Repository is organized as follows:
  * [Documentation](Documentation) (Documentation About this project): this directory contains the [Bachelor's Thesis](Documentation/TFG_GEI_Informe.pdf) and [Poster](Documentation/Poster_RISCV.pdf).
  * [Quartus](Quartus) (FPGA Implementation with Quartus software): this directory contains the projects that implement the core in an FPGA.
  * [Data](data): this directory contains memory initializations for the simulations.
  * [Diagrams](diagrams): this directory contains several diagrams of the architecture.
  * [pulp](pulp) (PULPino RamMux): this directory contains the implemntation for the memory acces of the [PULPino platform](https://github.com/pulp-platform/pulpino).
  * [riscv-gnu-toolchain](riscv-gnu-toolchain): this directory contains the files necessary to complie C programs into RISC-V RV32I code.
  * [src](src): this directory contains the source code of the core in Verilog.
  * [tb](tb): this directory contains the Verilog Testbenchs.
  * [vcd](vcd): this directory contains Vcd dumps to analyze the core internal signals.
  
 En aquest directori trobem:
   * [.vscode](.vscode): configuracions del Visual Studio Code generats automàticament.
   * [.travis.yml](.travis.yml): especifica quin fluxe ha de segir el sistema d'integració contínua per a aixecar un entorn on poder passar els tests i indcar en el build stattus si s'han passat correctament els tests. 
   * [Dockerfile](Dockerfile): defineix una imatge que inclou el disseny del nucli i l'entorn amb icarus verilog per a poder executar els tests.
   * [compile_and_run.sh](compile_and_run.sh): script escrit en bash que permet passar els tests en local o en un entorn on icarus verilog estigui disponible.
