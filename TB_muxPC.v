// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module TB_muxPC();

    localparam  SIZE_ADDR_PC       =   32; 

    reg                             i_clk;
    reg                             i_is_jump;
    reg                             i_is_JALR;
    reg    [SIZE_ADDR_PC-1      :0] i_rs;
    reg                             i_pc_source;
    reg    [SIZE_ADDR_PC-1      :0] i_suma_branch;
    reg    [SIZE_ADDR_PC-1      :0] i_suma_pc4;
    reg    [SIZE_ADDR_PC-1      :0] i_suma_jump;
    wire   [SIZE_ADDR_PC-1      :0] o_pc;

mux_pc mux_pc(
    .i_is_jump(i_is_jump),
    .i_is_JALR(i_is_JALR),
    .i_rs(i_rs),
    .i_pc_source(i_pc_source),
    .i_suma_branch(i_suma_branch),
    .i_suma_pc4(i_suma_pc4),        
    .i_suma_jump(i_suma_jump),
    .o_pc(o_pc) 
);

    initial begin

        #20
        i_clk   = 1'b0;
        i_is_jump  = 1'b0;
        i_is_JALR  = 1'b0;
        i_pc_source = 1'b0;  

        #20
        i_is_jump = 1'b1;
        #20
        i_suma_jump  = 32'b1;
        #20
        i_is_jump = 1'b0;

        #20
        i_is_JALR = 1'b1;
        #20
        i_rs  = 32'b10;
        #20
        i_is_JALR = 1'b0;

        #20
        i_pc_source = 1'b1;
        #20
        i_suma_branch  = 32'b11;
        #20
        i_pc_source = 1'b0;


        #100
        $display("############# Test OK ############");
        $finish();
    end
  
      // CLOCK_GENERATION
    always #10 i_clk = ~i_clk;

endmodule