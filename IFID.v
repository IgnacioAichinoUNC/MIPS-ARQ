`timescale 1ns / 1ps

module IFID
    #(
        parameter BITS_SIZE = 32
    )
    (
        input   wire                        i_clk,
        input   wire                        i_reset,
        input   wire                        i_step,
        input   wire                        i_IFID_unit_risk_write,
        input   wire    [BITS_SIZE-1:0]     i_pc4,
        input   wire    [BITS_SIZE-1:0]     i_pc8,
        input   wire    [BITS_SIZE-1:0]     i_instruction,

        output  wire    [BITS_SIZE-1:0]     o_pc4,
        output  wire    [BITS_SIZE-1:0]     o_pc8,
        output  wire    [BITS_SIZE-1:0]     o_instruction
    );


    reg     [BITS_SIZE-1:0] reg_instruction;
    reg     [BITS_SIZE-1:0] reg_pc_4;
    reg     [BITS_SIZE-1:0] reg_pc_8;
       
    always @(posedge i_clk)begin
        if( i_reset)begin
            reg_instruction  <=   {BITS_SIZE{1'b0}};
            reg_pc_4         <=   {BITS_SIZE{1'b0}};
            reg_pc_8         <=   {BITS_SIZE{1'b0}};

        end
        else if(i_IFID_unit_risk_write & i_step) begin
            reg_instruction  <=   i_instruction;
            reg_pc_4         <=   i_pc4;
            reg_pc_8         <=   i_pc8;
        end
    end


    assign o_instruction    =   reg_instruction;
    assign o_pc4            =   reg_pc_4;
    assign o_pc8            =   reg_pc_8;



endmodule