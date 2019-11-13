#!/bin/bash
mkdir -p bin

iverilog -grelative-include -o bin/load_store tb/load_store.v
bin/load_store
rm bin/load_store

read -p "press [Enter] for next test"

iverilog -grelative-include -o bin/al tb/arithmeticologic.v
bin/al
rm bin/al

read -p "press [Enter] for next test"

iverilog -grelative-include -o bin/br tb/branch.v
bin/br
rm bin/br

read -p "press [Enter] for next test"

iverilog -grelative-include -o bin/br tb/csr.v
bin/br
rm bin/br