`timescale 1ns/1ps
module tb_Multipliers_8bit;

reg 	[7:0]	a;
reg 	[7:0]	b;
reg				mul_sel;
wire 	[15:0]	mul_out;

  Multipliers_8bit U0(.a(a), .b(b), .mul_sel(mul_sel), .mul_out(mul_out));

initial begin
    
  $dumpfile("tb_Multipliers_8bit.vcd");
  $dumpvars(0,tb_Multipliers_8bit);
  
  					mul_sel <=1'b0;
					a <= 8'b00001011;		//dec 11 x 23 = 253
					b <= 8'b00010111;		//hex B  x 17 = FD
					#5;
					a <= 8'b01111111;		//dec 127 x 248 = 31496
					b <= 8'b11111000;		//hex 7F  x F8  = 7B08	
					#5;
					a <= 8'b11111010;		//dec 250 x 13  = 3250
					b <= 8'b00001101 ;	//hex FA  X D   = CB2
					#5;
  					a <= 8'b10000001 ;	//dec 129 x 145 = 18705
					b <= 8'b10010001 ;	//hex 81  x 91  = 4911
					#5;
  
  					mul_sel <=1'b1;
					a <= 8'b00001011;		//dec 11   x 23   = 253
					b <= 8'b00010111;		//hex 000B x 0017 = 00FD
					#5;
					a <= 8'b01111111;		//dec 127  x -8   = -1016
					b <= 8'b11111000;		//hex 007F x FFF8 = FC08
					#5;
					a <= 8'b11111010;		//dec -6   x 13   = -78
					b <= 8'b00001101 ;	//hex FFFA x 000D = FFB2
					#5;
  					a <= 8'b10000001 ;	//dec -127 x -111 = 14097
					b <= 8'b10010001 ;	//hex FF81 x FF91 = 3711
  					#5;
  $finish;
 					
end
endmodule
