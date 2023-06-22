# 8-Bit_Bit_Sliced_ALU

The 8-bit Bit Sliced ALU is constructed to perform arithmetic operations of signed and unsigned addition, subtraction, multiplication, and logical operations of bitwise AND, OR, and XOR. The architecture is shown below.

![image](https://github.com/claven06/8-Bit_Bit_Sliced_ALU/assets/105958751/c29149f1-ceab-4aac-a34e-97fede6d2b5f)

The Multiplier block is made up of 2 individual blocks, one for signed multiplication and the other for unsigned multiplication. An enable input utilizes select bits input to determine whether signed or unsigned operation is executed. 

The 8-bit Slice Stack is made up of 1-bit Slices joined together, with each slices containing a full adder, full subtractor, and, or and xor gates for the arithmetic and logical operations mentioned above. 

The top level testbench found in tb/BitSlicedALU_8bit_testbench.sv written and tested in accordance to SystemVerilog Unit Test (SVUT) framework, allowing for each function to be tested individually. 
