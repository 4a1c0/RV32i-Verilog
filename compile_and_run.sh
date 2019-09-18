#!/bin/bash

iverilog -o bin/test tb/testbench.v 
bin/test
rm bin/test