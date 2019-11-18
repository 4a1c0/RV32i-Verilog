#How to


```
docker run --mount src=/Volumes/Shared/RV32i-Verilog/riscv-gnu-toolchain,target=/test,type=bind -it 4a1c0/rv32i-gnu-toolchain /bin/bash
cd test
riscv32-unknown-elf-gcc test.c -o test
riscv32-unknown-elf-objdump -d test > test.dump
```