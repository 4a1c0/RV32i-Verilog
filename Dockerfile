FROM ubuntu:latest
WORKDIR /RiscV/
COPY . /RiscV/
RUN mkdir -p bin
RUN apt-get update && apt-get install -y iverilog
#RUN apk --update add iverilog #alpine

#RUN iverilog -o bin/test tb/testbench.v 
#CMD [ "bin/test" ]
