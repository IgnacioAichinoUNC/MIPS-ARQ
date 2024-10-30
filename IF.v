`timescale 1ns / 1ps

module IF #(
	parameter BITS_SIZE 	    = 32,
	parameter SIZE_TOTAL        = 256 // 64 lugares
)
(
	input 	wire 					i_clk,
	input 	wire 		    		i_step,
    input 	wire 			    	i_reset,
	input   wire                    i_hazard_pc_write,
	input   wire    [BITS_SIZE-1:0] i_instruction_address,
	input   wire    [BITS_SIZE-1:0] i_instruction,
	input   wire                    i_flag_write_intruc,
	input   wire                    i_is_jump,
	input   wire                    i_is_JALR,
	input   wire                    i_pc_source,
	input   wire    [BITS_SIZE-1:0] i_suma_branch,
	input   wire    [BITS_SIZE-1:0] i_suma_jump,
	input   wire    [BITS_SIZE-1:0] i_rs,
	output  wire    [BITS_SIZE-1:0] o_IF_PC4,
	output  wire    [BITS_SIZE-1:0] o_IF_PC,
	output  wire    [BITS_SIZE-1:0] o_instruction,
	output  wire    [BITS_SIZE-1:0] o_IF_PC8                                
	                  
);
    wire [BITS_SIZE-1:0]  wire_IF_PC;
    wire [BITS_SIZE-1:0]  wire_o_IF_PC;
    wire [BITS_SIZE-1:0]  wire_o_IF_PC4;


    assign o_IF_PC  = wire_o_IF_PC;
    assign o_IF_PC4 = wire_o_IF_PC4;


    pc
   #(
        .SIZE_ADDR_PC       (BITS_SIZE)
    )
    program_counter_strike
    (
        .i_clk              (i_clk),
        .i_reset            (i_reset),
        .i_step             (i_step),
        .i_NPC              (wire_IF_PC),
        .i_pc_write         (i_hazard_pc_write),
        .o_pc               (wire_o_IF_PC),
        .o_pc_4             (wire_o_IF_PC4),
        .o_pc_8             (o_IF_PC8)
    );
    
    memory_instruc
    #(
        .SIZE_ADDR_PC       (BITS_SIZE),
        .TOTAL_SIZE         (SIZE_TOTAL)
    )
    memory_instrucciones
    (
        .i_clk                  (i_clk),
        .i_reset                (i_reset),
        .i_step                 (i_step),
        .i_pc                   (wire_o_IF_PC),
        .i_instruction_address  (i_instruction_address),
        .i_instruction          (i_instruction),
        .i_flag_write_intruc    (i_flag_write_intruc),
        .o_instruction          (o_instruction)
    );

    mux_pc
    #(
        .SIZE_ADDR_PC           (BITS_SIZE)
    )
    mux_pc_select
    (
        .i_is_jump          (i_is_jump),
        .i_is_JALR          (i_is_JALR),
        .i_pc_source        (i_pc_source),
        .i_suma_branch      (i_suma_branch),
        .i_suma_pc4         (wire_o_IF_PC4),
        .i_suma_jump        (i_suma_jump),
        .i_rs               (i_rs),
        .o_pc               (wire_IF_PC)
    );

endmodule