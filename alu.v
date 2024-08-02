`timescale 1ns / 1ps

module alu
    #(
    //parameter
    parameter          BITS_SIZE     = 32,
    parameter          BITS_SHAMT    =   5,
    parameter          BITS_OP       =   4    
    )
    (
    //inputs
    input  wire        [BITS_SIZE - 1:0]                      i_data_a,
    input  wire        [BITS_SIZE - 1:0]                      i_data_b,
    input   wire       [BITS_SHAMT-1   :0]                    i_alu_shamt,
    input   wire                                              i_flag_shamt,
    input  wire        [BITS_OP - 3:0]                        i_op,
    
    //outputs
    output  wire                                              o_alu_zero,
    output wire        [BITS_SIZE - 1:0]                      o_result
    );
    
    localparam ADD = 6'b100000;
    localparam SUB = 6'b100010;
    localparam AND = 6'b100100;
    localparam OR  = 6'b100101;
    localparam XOR = 6'b100110;
    localparam SRA = 6'b000011;
    localparam SRL = 6'b000010;
    localparam NOR = 6'b100111;
    localparam SLL = 6'b000000; // A<<B(shamt)
    localparam SLT = 6'b101010; // A es menor que B

    reg [BITS_SIZE : 0] reg_result;
    
         
    always @(*) begin
        case (i_op)
            ADD: reg_result = (i_data_a) + (i_data_b); //ADD
            SUB: reg_result = (i_data_a) - (i_data_b); //SUB
            AND: reg_result = i_data_a & i_data_b; //AND
            OR : reg_result = i_data_a | i_data_b; //OR
            XOR: reg_result = i_data_a ^ i_data_b; //XOR
            SRA: reg_result = (i_flag_shamt) ? ($signed(i_data_b) >>> i_alu_shamt) : ($signed(i_data_b) >>> i_data_a); //SRA
            SRL: reg_result = (i_flag_shamt) ? (i_data_b >> i_alu_shamt) : (i_data_b >> i_data_a); //SRL
            NOR: reg_result = ~(i_data_a | i_data_b); //NOR
            SLL: reg_result = (i_flag_shamt) ? (i_data_b << i_alu_shamt) : (i_data_b << i_data_a);
            SLT: reg_result =   i_data_a   <   i_data_b ? 1:0;
            default: reg_result = {BITS_SIZE{1'b0}};
        endcase
  
    end

    assign o_result = reg_result;
    assign o_alu_zero   =   (reg_result==0);
endmodule