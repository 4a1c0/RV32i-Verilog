FROM buildpack-deps:bionic as builder

RUN apt-get update && apt-get install -y git autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

RUN git clone https://github.com/riscv/riscv-gnu-toolchain /root/source && cd /root/source && git submodule update --init --recursive

RUN mkdir -p /root/riscv

RUN cd /root/source && git rev-parse HEAD > /root/REVISION
RUN cd /root/source && ./configure --prefix=/root/riscv --with-arch=rv32i && make

FROM buildpack-deps:bionic
COPY --from=builder /root/riscv /riscv
COPY --from=builder /root/REVISION /riscv/REVISION
RUN apt-get update && apt-get install -y autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ruby-full cmake srecord && apt-get clean
ENV RISCV /riscv
ENV PATH "${PATH}:${RISCV}/bin"
CMD ["riscv32-unknown-elf-gcc", "--version"]