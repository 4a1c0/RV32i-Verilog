#!/bin/bash
mkdir -p bin

iverilog -o bin/load_store tb/load_store.v
bin/load_store
rm bin/load_store

read -p "press [Enter] for next test"

iverilog -o bin/al tb/arithmeticologic.v
bin/al
rm bin/al

read -p "press [Enter] for next test"

iverilog -o bin/br tb/branch.v
bin/br
rm bin/br

read -p "press [Enter] for next test"

iverilog -o bin/br tb/csr.v
bin/br
rm bin/br