module SliceStack_8bit (
    input   [7:0]   a,
    input   [7:0]   b,
    input           cin,
    input           bin,
    input   [4:0]   sel,
    output  [7:0]   z,
    output          carry,
    output          overflow
);
    // Instantiate wires for cin/cout connection between bit slices
    wire    [7:0] x;
    wire    [7:0] y;

    // Connecting the bit slices together to form a 8-bit slice stack
    Slice_1bit U0 (.a(a[0]), .b(b[0]), .cin(cin), .bin(bin), .sel(sel), .z(z[0]), .cout(y[0]), .bout(x[0]));
    Slice_1bit U1 (.a(a[1]), .b(b[1]), .cin(y[0]), .bin(x[0]), .sel(sel), .z(z[1]), .cout(y[1]), .bout(x[1]));
    Slice_1bit U2 (.a(a[2]), .b(b[2]), .cin(y[1]), .bin(x[1]), .sel(sel), .z(z[2]), .cout(y[2]), .bout(x[2]));
    Slice_1bit U3 (.a(a[3]), .b(b[3]), .cin(y[2]), .bin(x[2]), .sel(sel), .z(z[3]), .cout(y[3]), .bout(x[3]));
    Slice_1bit U4 (.a(a[4]), .b(b[4]), .cin(y[3]), .bin(x[3]), .sel(sel), .z(z[4]), .cout(y[4]), .bout(x[4]));
    Slice_1bit U5 (.a(a[5]), .b(b[5]), .cin(y[4]), .bin(x[4]), .sel(sel), .z(z[5]), .cout(y[5]), .bout(x[5]));
    Slice_1bit U6 (.a(a[6]), .b(b[6]), .cin(y[5]), .bin(x[5]), .sel(sel), .z(z[6]), .cout(y[6]), .bout(x[6]));
    Slice_1bit U7 (.a(a[7]), .b(b[7]), .cin(y[6]), .bin(x[6]), .sel(sel), .z(z[7]), .cout(y[7]), .bout(x[7]));

    // To generate carry flag 
    assign carry = sel[0] ? y[7] : x[7];

    // To generate overflow flag
    assign overflow = sel[0] ? (y[7] ^ y[6]) : (x[7] ^ x[6]);
endmodule

module FullAdder (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));
endmodule


module Slice_1bit (
    input  wire             a,
    input  wire             b,
    input  wire             cin,
    input  wire             bin,
    input  wire     [4:0]   sel,
    output wire              z,
    output wire              cout,
    output wire              bout
);
    // Use tristate buffer instead of tristate inverter as shown in lecture notes because we do not need
    // inverted output

    // Instantiate wires for Tristate Buffers
    wire   [4:0] y;
    wire         add_w;
    wire         sub_w;
    
    // Full Adder operation
    FullAdder U0 (.a(a), .b(b), .cin(cin), .sum(y[0]), .cout(add_w));
    assign z = sel[0] ? y[0] : 1'bz;
    assign cout = sel[0] ? add_w : 1'bz;
    // Full Subtracter sum operation
    FullAdder U1 (.a(a), .b(~b), .cin(bin), .sum(y[1]), .cout(sub_w));
    assign z = sel[1] ? y[1] : 1'bz;
    assign bout = sel[1] ? sub_w : 1'bz;
    // Bitwise AND operation
    assign y[2] = a & b;
    assign z = sel[2] ? y[2] : 1'bz;
    // Bitwise OR operation
    assign y[3] = a | b;
    assign z = sel[3] ? y[3] : 1'bz;
    // Bitwise XOR operation
    assign y[4] = a ^ b;
    assign z = sel[4] ? y[4] : 1'bz;
endmodule
