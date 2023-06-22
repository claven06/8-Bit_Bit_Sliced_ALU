// Mandatory file to be able to launch SVUT flow
`include "svut_h.sv"
// Specify the module to load or on files.f
`include "BitSliceALU_8bit.v"
`timescale 1 ns / 100 ps

module BitSliceALU_8bit_testbench();

    `SVUT_SETUP

    reg [7:0]   a;
    reg [7:0]   b;
    reg cin;
    reg bin;
    reg [4:0]   sel;
    wire [15:0]  z;
    wire carry;
    wire overflow;
    wire negative;
    wire zero;

    BitSliceALU_8bit 
    dut 
    (
    .a        (a),
    .b        (b),
    .cin      (cin),
    .bin      (bin),
    .sel      (sel),
    .z        (z),
    .carry    (carry),
    .overflow (overflow),
    .negative (negative),
    .zero     (zero)
    );


    // To create a clock:
    // initial aclk = 0;
    // always #2 aclk = ~aclk;

    // To dump data for visualization:
    // initial begin
    //     $dumpfile("BitSliceALU_8bit_testbench.vcd");
    //     $dumpvars(0, BitSliceALU_8bit_testbench);
    // end

    // Setup time format when printing with $realtime()
    initial $timeformat(-9, 1, "ns", 8);

    initial
    begin
	$dumpfile("BitSliceALU_8bit_testbench.vcd");
	$dumpvars(0,BitSliceALU_8bit_testbench);
    end 

    task setup(msg="Setup testcase");
    begin
        // setup() runs when a test begins
        a = 8'h00;
	b = 8'h00;
	bin = 1'b1;
	cin = 1'b0;
	sel = 5'b00001;
    end
    endtask

    task teardown(msg="Tearing down");
    begin
        // teardown() runs when a test ends
	#10;
    end
    endtask

    `TEST_SUITE("BitSliceALU_8bit")

    //  Available macros:"
    //
    //    - `MSG("message"):       Print a raw white message
    //    - `INFO("message"):      Print a blue message with INFO: prefix
    //    - `SUCCESS("message"):   Print a green message if SUCCESS: prefix
    //    - `WARNING("message"):   Print an orange message with WARNING: prefix and increment warning counter
    //    - `CRITICAL("message"):  Print a purple message with CRITICAL: prefix and increment critical counter
    //    - `ERROR("message"):     Print a red message with ERROR: prefix and increment error counter
    //
    //    - `FAIL_IF(aSignal):                 Increment error counter if evaluaton is true
    //    - `FAIL_IF_NOT(aSignal):             Increment error coutner if evaluation is false
    //    - `FAIL_IF_EQUAL(aSignal, 23):       Increment error counter if evaluation is equal
    //    - `FAIL_IF_NOT_EQUAL(aSignal, 45):   Increment error counter if evaluation is not equal
    //    - `ASSERT(aSignal):                  Increment error counter if evaluation is not true
    //    - `ASSERT((aSignal == 0)):           Increment error counter if evaluation is not true
    //
    //  Available flag:
    //
    //    - `LAST_STATUS: tied to 1 is last macro did experience a failure, else tied to 0

    `UNIT_TEST("ADDITION TEST")
	a = 8'hf0;
	b = 8'h0f;
	sel = 5'b00001;
	
	#10;
	`FAIL_IF_NOT_EQUAL(z, 16'h00ff);
    `UNIT_TEST_END

    `UNIT_TEST("SUBTRACTION TEST")
	a = 8'h0f;
	b = 8'h0f;
	sel = 5'b00010;
		
	#10;
	`FAIL_IF_NOT_EQUAL(z, 16'h0000);
    `UNIT_TEST_END

    `UNIT_TEST("BITWISE AND TEST")
	a = 8'hf0;
	b = 8'h0f;
	sel = 5'b00100;
		
	#10;
	`FAIL_IF_NOT_EQUAL(z, 16'h0000);
    `UNIT_TEST_END

    `UNIT_TEST("BITWISE OR TEST")
	a = 8'hf0;
	b = 8'h0f;
	sel = 5'b01000;
		
	#10;
	`FAIL_IF_NOT_EQUAL(z, 16'h00ff);
    `UNIT_TEST_END

    `UNIT_TEST("BITWISE XOR TEST")
	a = 8'b01010110;
	b = 8'b01100101;
	sel = 5'b10000;
		
	#10;
	`FAIL_IF_NOT_EQUAL(z, 16'b0000000000110011);
    `UNIT_TEST_END

    `UNIT_TEST("CARRY FLAG TEST - ADDITION")
	a = 8'hff;
	b = 8'h01;
	sel = 5'b00001;
	
	#10;
	// Fail if carry not triggered
	`FAIL_IF_NOT(carry);
    `UNIT_TEST_END

    `UNIT_TEST("CARRY FLAG TEST - SUBTRACTION")
	a = 8'h00;
	b = 8'h01;
	sel = 5'b00010;
	
	#10;
	// Fail if carry not triggered
	`FAIL_IF_NOT(carry);
    `UNIT_TEST_END

    `UNIT_TEST("NEGATIVE FLAG TEST")
	a = 8'hf0;
	b = 8'h00;
	sel = 5'b00001;
		
	#10;
	// Fail if negative flag not triggered
	`FAIL_IF_NOT(negative);
    `UNIT_TEST_END

    `UNIT_TEST("ZERO FLAG TEST")
	a = 8'hf0;
	b = 8'hf0;
	sel = 5'b00010;
	
	#10;
	// Fail if zero flag not triggered
	`FAIL_IF_NOT(zero);
    `UNIT_TEST_END

    `UNIT_TEST("OVERFLOW FLAG TEST")
	a = 8'h7f;
	b = 8'h7f;
	sel = 5'b00001;
	
	#10;
	// Fail if overflow flag not triggered
	`FAIL_IF_NOT(overflow);
    `UNIT_TEST_END

    `UNIT_TEST("MULTIPLICATION TEST")
	a = 8'h40; // 64
	b = 8'hff; // 255
	sel = 5'b00000;
	
	#10;
	`FAIL_IF_NOT_EQUAL(z, 16'h3fc0); //16320
    `UNIT_TEST_END

    `UNIT_TEST("SIGNED MULTIPLICATION ++ TEST")
	a = 8'h40; // 64
	b = 8'h40; // 64
	sel = 5'b11111;
	
	#10;
	`FAIL_IF_NOT_EQUAL(z, 16'h1000); //4096
	`FAIL_IF(negative);
    `UNIT_TEST_END

    `UNIT_TEST("SIGNED MULTIPLICATION +- TEST")
	a = 8'h40; // 64
	b = 8'hb2; // -78
	sel = 5'b11111;
	
	#10;
	`FAIL_IF_NOT_EQUAL(z, 16'hec80); //-4992
	`FAIL_IF_NOT(negative);
    `UNIT_TEST_END

    `UNIT_TEST("SIGNED MULTIPLICATION -- TEST")
	a = 8'hb2; // -78
	b = 8'hb2; // -78
	sel = 5'b11111;
	
	#10;
	`FAIL_IF_NOT_EQUAL(z, 16'h17c4); //6084
	`FAIL_IF(negative);
    `UNIT_TEST_END

    `TEST_SUITE_END

endmodule
