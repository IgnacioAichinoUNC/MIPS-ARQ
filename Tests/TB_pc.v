

`timescale 1ns / 1ps

module TB_pc();

    localparam     SIZE_ADDR_PC    = 32;

    reg                            i_clk;
    reg                            i_reset; 
    reg                            i_step;
    reg                            i_pc_write;
    reg    [SIZE_ADDR_PC-1    :0]  i_NPC;
    wire   [SIZE_ADDR_PC-1    :0]  o_pc;
    wire   [SIZE_ADDR_PC-1    :0]  o_pc_4;
    wire   [SIZE_ADDR_PC-1    :0]  o_pc_8;


pc program_counter(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_step(i_step),
    .i_pc_write(i_pc_write),
    .i_NPC(i_NPC),
    .o_pc(o_pc),
    .o_pc_4(o_pc_4),
    .o_pc_8(o_pc_8)  
);

    initial begin
      
        $dumpfile("dump.vcd"); $dumpvars;

        #20
        i_clk = 1'b0;
        i_reset = 1'b1;
        #20
        i_reset = 1'b0;
        #20
        i_step = 1'b1;
        i_pc_write = 1'b1;
        #20
        i_NPC = 32'b1;
        #100
        $display("############# Test OK ############");
        $finish();
    end
  
      // CLOCK_GENERATION
    always #10 i_clk = ~i_clk;

endmodule
