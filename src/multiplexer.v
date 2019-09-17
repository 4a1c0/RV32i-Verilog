`default_nettype none
`timescale 1ns/1ps


`include "src/defines.vh"

module multiplexer2(
        a,
        b,
        out,
        select
    );
    parameter DATA_WITDTH = 32;

    input select;
    input[DATA_WITDTH-1:0] a;
    input[DATA_WITDTH-1:0] b;
    output[DATA_WITDTH-1:0] out;

    assign out = select == 1'b0 ? a : b;  // error because select is not evaluated if is 1'b0
endmodule

`default_nettype wire