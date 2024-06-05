`timescale 1ns / 1ps

module TB_mem_instruc();

localparam SIZE_ADDR_PC = 32;
localparam SIZE_MEMORY = 256;

reg i_clk;
reg i_reset;
reg i_step;
reg [SIZE_ADDR_PC-1:0] i_pc;
reg [SIZE_ADDR_PC-1:0] i_instruction_address;
reg [SIZE_ADDR_PC-1:0] i_instruction;
reg i_flag_write_intruc;

wire [SIZE_ADDR_PC-1:0] o_instruction;

memory_instruc#(
    .SIZE_ADDR_PC(SIZE_ADDR_PC),
    .TOTAL_SIZE(SIZE_MEMORY)
)
memory_instrucction
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_step(i_step),
    .i_pc(i_pc),
    .i_instruction_address(i_instruction_address),
    .i_instruction(i_instruction),
    .i_flag_write_intruc(i_flag_write_intruc),
    .o_instruction(o_instruction)
);

initial begin
    i_reset = 1'b1; // Añadido el reset
    #20
    i_reset = 1'b0;
    i_clk = 1'b0;
    #20
    i_step = 1'b0;
    i_flag_write_intruc = 1'b0;
    
    #20
    i_flag_write_intruc = 1'b1;
    i_instruction_address = 32'b0;
    i_instruction  = 32'b1;

    #20
    i_flag_write_intruc = 1'b0;
    i_step = 1'b1;
    i_pc = 32'b0;
    
    #100
    $display("############# Test OK ############");
    $finish();

end
// CLOCK_GENERATION
    always #10 i_clk = ~i_clk;

endmodule