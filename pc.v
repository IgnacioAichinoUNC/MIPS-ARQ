`timescale 1ns / 1ps

module pc#
    (
        parameter SIZE_ADDR_PC = 32
    )
    (
        input   wire                            i_clk,
        input   wire                            i_reset,
        input   wire                            i_step,
        input   wire                            i_pc_write,
        input   wire    [SIZE_ADDR_PC-1    :0]     i_NPC,
        output  wire    [SIZE_ADDR_PC-1    :0]     o_pc,
        output  wire    [SIZE_ADDR_PC-1    :0]     o_pc_4,
        output  wire    [SIZE_ADDR_PC-1    :0]     o_pc_8          
    );
    
    reg [SIZE_ADDR_PC-1  :0] reg_pc;

    always @(negedge i_clk)
    begin
        if(i_reset) begin
            reg_pc <= {SIZE_ADDR_PC{1'b0}};
        end 
        else if(i_pc_write & i_step) begin
            reg_pc <= i_NPC;
        end 
    end


    assign  o_pc     =   reg_pc; // La salida normal para una burbuja       
    assign  o_pc_4   =   reg_pc + 4; // incremento normal de PC+4 para siguiente instruccion
    assign  o_pc_8   =   reg_pc + 8; // JAL instruccion


endmodule