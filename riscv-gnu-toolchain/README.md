# How to

```bash
docker run --mount src=/Volumes/Share/RV32i-Verilog/riscv-gnu-toolchain,target=/test,type=bind -it 4a1c0/rv32i-gnu-toolchain /bin/bash

#docker run --mount src=$PWD,target=/test,type=bind -it 4a1c0/rv32i-gnu-toolchain /bin/bash

cd test
riscv32-unknown-elf-gcc test.c -Ttext=0x0000 -o test

riscv32-unknown-elf-gcc -Ttext=0 -nostdlib test.c -o test

riscv32-unknown-elf-objdump -d test > test.dump
riscv32-unknown-elf-objcopy -O ihex test test.hex
srec_cat test.bin -binary -o test.mif -mif
```
And change the WIDTH = 8; to WIDTH = 32;
