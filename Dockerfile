FROM ubuntu:latest
WORKDIR /RiscV/
COPY . /RiscV/
RUN RUN mkdir -p bin
RUN apt-get update && apt-get install -y iverilog


#RUN iverilog -o bin/test tb/testbench.v 
#CMD [ "bin/test" ]
