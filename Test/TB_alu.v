// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module TB_alu();

    localparam   BITS_SIZE   =   32;
    localparam   BITS_SHAMT  =   5;
    localparam   BITS_OP     =   4; 

    reg                             i_clk;
    reg    [BITS_SIZE-1    :0]      i_data_a;
    reg    [BITS_SIZE-1    :0]      i_data_b;
    reg    [BITS_SHAMT-1   :0]      i_alu_shamt;
    reg                             i_flag_shamt;
    reg    [BITS_OP-1    :0]        i_op;
    wire                            o_alu_zero;
    wire   [BITS_SIZE-1    :0]      o_result;


alu u_alu(
    .i_data_a(i_data_a),
    .i_data_b(i_data_b),
    .i_alu_shamt(i_alu_shamt),
    .i_flag_shamt(i_flag_shamt),
    .i_op(i_op),
    .o_alu_zero(o_alu_zero),
    .o_result(o_result)
);

    initial begin

        #20
        i_clk = 1'b0;
        #20
        i_data_a = 32'b10;
        i_data_b = 32'b01;
        #20
        i_op = 4'b0000;//ADD
        #20
        i_op = 4'b0001;//SUB
        #20 
        i_op =4'b0010;//AND
        #20
        i_op  =4'b0011;//OR
        #20
        i_op = 4'b0101;//XOR
        i_flag_shamt= 1'b1;
        i_alu_shamt= 5'b11111;
        #20
        i_op =4'b1001;//SRL A>>B(shamt)
        i_flag_shamt= 1'b0;
        #20
        i_op =4'b1001;//SRL A>>B(shamt)
        #20
        i_op =4'b0100;//NOR
        #20
        i_op =  4'b0111;//SLT A es menor que B
        
        #100
        $display("############# Test OK ############");
        $finish();
    end
  
      // CLOCK_GENERATION
    always #10 i_clk = ~i_clk;

endmodule