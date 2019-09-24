#!/bin/bash
mkdir -p bin
#iverilog -o bin/test tb/testbench.v 
iverilog -o bin/load_store tb/load_store.v
#bin/test
bin/load_store
#rm bin/test
rm bin/load_store