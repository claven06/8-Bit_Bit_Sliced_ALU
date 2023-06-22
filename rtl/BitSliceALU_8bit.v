module BitSliceALU_8bit (
    input   [7:0]   a,
    input   [7:0]   b,
    input           cin,
    input           bin,
    input   [4:0]   sel,
    output  [15:0]  z,
    output          carry,
    output          overflow,
    output          negative,
    output          zero
);
    // Instantiate wires for system connection
    wire [7:0]  stack_out;
    wire [15:0] mult_out;
    wire        enable;
    wire [15:0] zero_wire;

    // Instantiate modules slice stack and multiplier
    SliceStack_8bit U0 (.a(a), .b(b), .cin(cin), .bin(bin), .sel(sel), .carry(carry), .overflow(overflow), .z(stack_out));
    Multipliers_8bit U1  (.a(a), .b(b), .mul_out(mult_out), .mul_sel(sel[0]));
    
    // Enable = 1'b0 : choose Multiplier Array Block
    // Enable = 1'b1 : choose Slice Stack Block
    assign enable = ((sel[0] | sel[1]) ^ sel[2] ^ (sel[3] ^ sel[4]));
    
    // Determine output from sources
    assign z[7:0] = enable ? stack_out : mult_out[7:0];
    assign z[15:8] = enable ? 8'h00 : mult_out[15:8];

    // Determine negative flag from z output
    assign negative = enable ? z[7] : z[15];
    
    // Determine zero flag from sources
    assign zero_wire[7:0] = enable ? stack_out : mult_out[7:0];
    assign zero_wire[15:8] = enable ? 8'h00 : mult_out[15:8];
    assign zero = ~(zero_wire[0] | zero_wire[1] | zero_wire[2] | zero_wire[3] | zero_wire[4] | 
                    zero_wire[5] | zero_wire[6] | zero_wire[7] | zero_wire[8] | zero_wire[9] | 
                    zero_wire[10] | zero_wire[11] | zero_wire[12] | zero_wire[13] | 
                    zero_wire[14] | zero_wire[15]);
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
    assign carry = sel[0] ? y[7] : ~x[7];

    // To generate overflow flag
    assign overflow = sel[0] ? (y[7] ^ y[6]) : (x[7] ^ x[6]);
endmodule
		
module HADD(a, b, sum, carry);

	input a, b;
	output sum, carry;

	assign sum = a ^ b;
	assign carry = a & b;

endmodule

module FADD(a, b, cin, sum, cout);

    input a, b, cin;
    output sum, cout;
    
    wire sum1, cout_1, cout_2;

    HADD U0(.a(a), .b(b), .sum(sum1), .carry(cout_1));
    HADD U1(.a(cin), .b(sum1), .sum(sum), .carry(cout_2));
    assign cout = cout_1 | cout_2;

endmodule

module unsigned_mul_8(a, b, c);
    input [7:0]a;
    input [7:0]b;
    output [15:0]c;

    wire [7:0]cout_a;
    wire [6:0]sum_a;

    wire [7:0]cout_b;
    wire [6:0]sum_b;

    wire [7:0]cout_c;
    wire [6:0]sum_c;

    wire [7:0]cout_d;
    wire [6:0]sum_d;

    wire [7:0]cout_e;
    wire [6:0]sum_e;

    wire [7:0]cout_f;
    wire [6:0]sum_f;

    wire [6:0]cout_g;

    // layer A
    assign c[0] = a[0] & b[0];
    HADD A0(a[1] & b[0], a[0] & b[1], c[1], cout_a[0]);
    FADD A1(a[2] & b[0], a[1] & b[1], cout_a[0], sum_a[0], cout_a[1]);
    FADD A2(a[3] & b[0], a[2] & b[1], cout_a[1], sum_a[1], cout_a[2]);
    FADD A3(a[4] & b[0], a[3] & b[1], cout_a[2], sum_a[2], cout_a[3]);
    FADD A4(a[5] & b[0], a[4] & b[1], cout_a[3], sum_a[3], cout_a[4]);
    FADD A5(a[6] & b[0], a[5] & b[1], cout_a[4], sum_a[4], cout_a[5]);
    FADD A6(a[7] & b[0], a[6] & b[1], cout_a[5], sum_a[5], cout_a[6]);
    HADD A7(cout_a[6], a[7] & b[1], sum_a[6], cout_a[7]);
    
    // layer B
    HADD B0(sum_a[0], a[0] & b[2], c[2], cout_b[0]);
    FADD B1(sum_a[1], a[1] & b[2], cout_b[0], sum_b[0], cout_b[1]);
    FADD B2(sum_a[2], a[2] & b[2], cout_b[1], sum_b[1], cout_b[2]);
    FADD B3(sum_a[3], a[3] & b[2], cout_b[2], sum_b[2], cout_b[3]);
    FADD B4(sum_a[4], a[4] & b[2], cout_b[3], sum_b[3], cout_b[4]);
    FADD B5(sum_a[5], a[5] & b[2], cout_b[4], sum_b[4], cout_b[5]);
    FADD B6(sum_a[6], a[6] & b[2], cout_b[5], sum_b[5], cout_b[6]);
    FADD B7(cout_a[7], a[7] & b[2], cout_b[6], sum_b[6], cout_b[7]);

    // layer C
    HADD C0(sum_b[0], a[0] & b[3], c[3], cout_c[0]);
    FADD C1(sum_b[1], a[1] & b[3], cout_c[0], sum_c[0], cout_c[1]);
    FADD C2(sum_b[2], a[2] & b[3], cout_c[1], sum_c[1], cout_c[2]);
    FADD C3(sum_b[3], a[3] & b[3], cout_c[2], sum_c[2], cout_c[3]);
    FADD C4(sum_b[4], a[4] & b[3], cout_c[3], sum_c[3], cout_c[4]);
    FADD C5(sum_b[5], a[5] & b[3], cout_c[4], sum_c[4], cout_c[5]);
    FADD C6(sum_b[6], a[6] & b[3], cout_c[5], sum_c[5], cout_c[6]);
    FADD C7(cout_b[7], a[7] & b[3], cout_c[6], sum_c[6], cout_c[7]);

    // layer D
    HADD D0(sum_c[0], a[0] & b[4], c[4], cout_d[0]);
    FADD D1(sum_c[1], a[1] & b[4], cout_d[0], sum_d[0], cout_d[1]);
    FADD D2(sum_c[2], a[2] & b[4], cout_d[1], sum_d[1], cout_d[2]);
    FADD D3(sum_c[3], a[3] & b[4], cout_d[2], sum_d[2], cout_d[3]);
    FADD D4(sum_c[4], a[4] & b[4], cout_d[3], sum_d[3], cout_d[4]);
    FADD D5(sum_c[5], a[5] & b[4], cout_d[4], sum_d[4], cout_d[5]);
    FADD D6(sum_c[6], a[6] & b[4], cout_d[5], sum_d[5], cout_d[6]);
    FADD D7(cout_c[7], a[7] & b[4], cout_d[6], sum_d[6], cout_d[7]);

    // layer E
    HADD E0(sum_d[0], a[0] & b[5], c[5], cout_e[0]);
    FADD E1(sum_d[1], a[1] & b[5], cout_e[0], sum_e[0], cout_e[1]);
    FADD E2(sum_d[2], a[2] & b[5], cout_e[1], sum_e[1], cout_e[2]);
    FADD E3(sum_d[3], a[3] & b[5], cout_e[2], sum_e[2], cout_e[3]);
    FADD E4(sum_d[4], a[4] & b[5], cout_e[3], sum_e[3], cout_e[4]);
    FADD E5(sum_d[5], a[5] & b[5], cout_e[4], sum_e[4], cout_e[5]);
    FADD E6(sum_d[6], a[6] & b[5], cout_e[5], sum_e[5], cout_e[6]);
    FADD E7(cout_d[7], a[7] & b[5], cout_e[6], sum_e[6], cout_e[7]);

    // layer F
    HADD F0(sum_e[0], a[0] & b[6], c[6], cout_f[0]);
    FADD F1(sum_e[1], a[1] & b[6], cout_f[0], sum_f[0], cout_f[1]);
    FADD F2(sum_e[2], a[2] & b[6], cout_f[1], sum_f[1], cout_f[2]);
    FADD F3(sum_e[3], a[3] & b[6], cout_f[2], sum_f[2], cout_f[3]);
    FADD F4(sum_e[4], a[4] & b[6], cout_f[3], sum_f[3], cout_f[4]);
    FADD F5(sum_e[5], a[5] & b[6], cout_f[4], sum_f[4], cout_f[5]);
    FADD F6(sum_e[6], a[6] & b[6], cout_f[5], sum_f[5], cout_f[6]);
    FADD F7(cout_e[7], a[7] & b[6], cout_f[6], sum_f[6], cout_f[7]);

    // layer G
    HADD G0(sum_f[0], a[0] & b[7], c[7], cout_g[0]);
    FADD G1(sum_f[1], a[1] & b[7], cout_g[0], c[8], cout_g[1]);
    FADD G2(sum_f[2], a[2] & b[7], cout_g[1], c[9], cout_g[2]);
    FADD G3(sum_f[3], a[3] & b[7], cout_g[2], c[10], cout_g[3]);
    FADD G4(sum_f[4], a[4] & b[7], cout_g[3], c[11], cout_g[4]);
    FADD G5(sum_f[5], a[5] & b[7], cout_g[4], c[12], cout_g[5]);
    FADD G6(sum_f[6], a[6] & b[7], cout_g[5], c[13], cout_g[6]);
    FADD G7(cout_f[7], a[7] & b[7], cout_g[6], c[14], c[15]);
endmodule

module signed_mul_8(a, b, c);
    input [7:0]a;
    input [7:0]b;
    output [15:0]c;

    wire [7:0]cout_a;
    wire [6:0]sum_a;

    wire [7:0]cout_b;
    wire [6:0]sum_b;

    wire [7:0]cout_c;
    wire [6:0]sum_c;

    wire [7:0]cout_d;
    wire [6:0]sum_d;

    wire [7:0]cout_e;
    wire [6:0]sum_e;

    wire [7:0]cout_f;
    wire [6:0]sum_f;

    wire [7:0]cout_g;

    // layer A
    assign c[0] = a[0] & b[0];
    HADD A0(a[1] & b[0], a[0] & b[1], c[1], cout_a[0]);
    FADD A1(a[2] & b[0], a[1] & b[1], cout_a[0], sum_a[0], cout_a[1]);
    FADD A2(a[3] & b[0], a[2] & b[1], cout_a[1], sum_a[1], cout_a[2]);
    FADD A3(a[4] & b[0], a[3] & b[1], cout_a[2], sum_a[2], cout_a[3]);
    FADD A4(a[5] & b[0], a[4] & b[1], cout_a[3], sum_a[3], cout_a[4]);
    FADD A5(a[6] & b[0], a[5] & b[1], cout_a[4], sum_a[4], cout_a[5]);
    FADD A6(~(a[7] & b[0]), a[6] & b[1], cout_a[5], sum_a[5], cout_a[6]);
    FADD A7(1, ~(a[7] & b[1]), cout_a[6], sum_a[6], cout_a[7]);
    
    // layer B
    HADD B0(sum_a[0], a[0] & b[2], c[2], cout_b[0]);
    FADD B1(sum_a[1], a[1] & b[2], cout_b[0], sum_b[0], cout_b[1]);
    FADD B2(sum_a[2], a[2] & b[2], cout_b[1], sum_b[1], cout_b[2]);
    FADD B3(sum_a[3], a[3] & b[2], cout_b[2], sum_b[2], cout_b[3]);
    FADD B4(sum_a[4], a[4] & b[2], cout_b[3], sum_b[3], cout_b[4]);
    FADD B5(sum_a[5], a[5] & b[2], cout_b[4], sum_b[4], cout_b[5]);
    FADD B6(sum_a[6], a[6] & b[2], cout_b[5], sum_b[5], cout_b[6]);
    FADD B7(cout_a[7], ~(a[7] & b[2]), cout_b[6], sum_b[6], cout_b[7]);

    // layer C
    HADD C0(sum_b[0], a[0] & b[3], c[3], cout_c[0]);
    FADD C1(sum_b[1], a[1] & b[3], cout_c[0], sum_c[0], cout_c[1]);
    FADD C2(sum_b[2], a[2] & b[3], cout_c[1], sum_c[1], cout_c[2]);
    FADD C3(sum_b[3], a[3] & b[3], cout_c[2], sum_c[2], cout_c[3]);
    FADD C4(sum_b[4], a[4] & b[3], cout_c[3], sum_c[3], cout_c[4]);
    FADD C5(sum_b[5], a[5] & b[3], cout_c[4], sum_c[4], cout_c[5]);
    FADD C6(sum_b[6], a[6] & b[3], cout_c[5], sum_c[5], cout_c[6]);
    FADD C7(cout_b[7], ~(a[7] & b[3]), cout_c[6], sum_c[6], cout_c[7]);

    // layer D
    HADD D0(sum_c[0], a[0] & b[4], c[4], cout_d[0]);
    FADD D1(sum_c[1], a[1] & b[4], cout_d[0], sum_d[0], cout_d[1]);
    FADD D2(sum_c[2], a[2] & b[4], cout_d[1], sum_d[1], cout_d[2]);
    FADD D3(sum_c[3], a[3] & b[4], cout_d[2], sum_d[2], cout_d[3]);
    FADD D4(sum_c[4], a[4] & b[4], cout_d[3], sum_d[3], cout_d[4]);
    FADD D5(sum_c[5], a[5] & b[4], cout_d[4], sum_d[4], cout_d[5]);
    FADD D6(sum_c[6], a[6] & b[4], cout_d[5], sum_d[5], cout_d[6]);
    FADD D7(cout_c[7], ~(a[7] & b[4]), cout_d[6], sum_d[6], cout_d[7]);

    // layer E
    HADD E0(sum_d[0], a[0] & b[5], c[5], cout_e[0]);
    FADD E1(sum_d[1], a[1] & b[5], cout_e[0], sum_e[0], cout_e[1]);
    FADD E2(sum_d[2], a[2] & b[5], cout_e[1], sum_e[1], cout_e[2]);
    FADD E3(sum_d[3], a[3] & b[5], cout_e[2], sum_e[2], cout_e[3]);
    FADD E4(sum_d[4], a[4] & b[5], cout_e[3], sum_e[3], cout_e[4]);
    FADD E5(sum_d[5], a[5] & b[5], cout_e[4], sum_e[4], cout_e[5]);
    FADD E6(sum_d[6], a[6] & b[5], cout_e[5], sum_e[5], cout_e[6]);
    FADD E7(cout_d[7], ~(a[7] & b[5]), cout_e[6], sum_e[6], cout_e[7]);

    // layer F
    HADD F0(sum_e[0], a[0] & b[6], c[6], cout_f[0]);
    FADD F1(sum_e[1], a[1] & b[6], cout_f[0], sum_f[0], cout_f[1]);
    FADD F2(sum_e[2], a[2] & b[6], cout_f[1], sum_f[1], cout_f[2]);
    FADD F3(sum_e[3], a[3] & b[6], cout_f[2], sum_f[2], cout_f[3]);
    FADD F4(sum_e[4], a[4] & b[6], cout_f[3], sum_f[3], cout_f[4]);
    FADD F5(sum_e[5], a[5] & b[6], cout_f[4], sum_f[4], cout_f[5]);
    FADD F6(sum_e[6], a[6] & b[6], cout_f[5], sum_f[5], cout_f[6]);
    FADD F7(cout_e[7], ~(a[7] & b[6]), cout_f[6], sum_f[6], cout_f[7]);

    // layer G
    HADD G0(sum_f[0], ~(a[0] & b[7]), c[7], cout_g[0]);
    FADD G1(sum_f[1], ~(a[1] & b[7]), cout_g[0], c[8], cout_g[1]);
    FADD G2(sum_f[2], ~(a[2] & b[7]), cout_g[1], c[9], cout_g[2]);
    FADD G3(sum_f[3], ~(a[3] & b[7]), cout_g[2], c[10], cout_g[3]);
    FADD G4(sum_f[4], ~(a[4] & b[7]), cout_g[3], c[11], cout_g[4]);
    FADD G5(sum_f[5], ~(a[5] & b[7]), cout_g[4], c[12], cout_g[5]);
    FADD G6(sum_f[6], ~(a[6] & b[7]), cout_g[5], c[13], cout_g[6]);
    FADD G7(cout_f[7], a[7] & b[7], cout_g[6], c[14], cout_g[7]);
	 assign c[15] = ~cout_g[7];
endmodule

module Multipliers_8bit(
		input   [7:0] 	a,
		input   [7:0] 	b,
		input 			mul_sel, //0=unsigned 1=signed
		output  [15:0] mul_out
);

		wire 		[15:0] 	unsigned_mul_w;
		wire 		[15:0] 	signed_mul_w;
	 
		unsigned_mul_8 M0(.a(a), .b(b), .c(unsigned_mul_w));
		signed_mul_8 	M1(.a(a), .b(b), .c(signed_mul_w));
		assign mul_out = mul_sel ? signed_mul_w : unsigned_mul_w;				
endmodule
