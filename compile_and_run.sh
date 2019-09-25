#!/bin/bash
mkdir -p bin
#iverilog -o bin/test tb/testbench.v 
iverilog -o bin/load_store tb/load_store.v

#bin/test
bin/load_store
rm bin/load_store
read -p "press [Enter] for next test"
iverilog -o bin/al tb/arithmeticologic.v
bin/al
#rm bin/test

rm bin/al