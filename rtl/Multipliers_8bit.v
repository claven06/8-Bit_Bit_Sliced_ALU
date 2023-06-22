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

