`timescale 1ns/1ps
module tb_SliceStack_8bit;

reg [7:0]a;
reg [7:0]b;
reg [4:0]sel;
reg cin;
reg bin;
wire [7:0]z;
wire carry;
wire overflow;

SliceStack_8bit bitsliced (.a(a), .b(b), .sel(sel), .cin(cin), .bin(bin), .carry(carry), .overflow(overflow), .z(z));

initial begin
					a <= 8'b00000010;
					b <= 8'b10001011;
					cin<= 1'b0;
					bin <= 1'b0;
					sel <= 5'b00001; // Addition

			#5	a <= 8'b10000010;
					b <= 8'b00001011;
					cin<= 1'b0;
					bin <= 1'b1;
					sel <= 5'b00010 ;// Subtraction
					
				#5	a <= 8'b00000010;
					b <= 8'b00001011;
			
					sel <= 5'b00100; // bitwise and
					
				#5	a <= 8'b10000010;
					b <= 8'b10001011;
					
					sel <= 5'b01000; // bitwise or
					
					#5	a <= 8'b10000010;
					b <= 8'b10001011;
				
					sel <= 5'b10000; // bitwise xor
					
					#5;
					$finish;
					
end
endmodule
