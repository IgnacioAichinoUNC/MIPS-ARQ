
`timescale 1ns / 1ps

module TB_sum_branch();

    localparam      BITS_SIZE     =   32; 

    reg                            i_clk;

    reg    [BITS_SIZE-1      :0]   i_extension_data;
    reg    [BITS_SIZE-1      :0]   i_sum_pc4;
    wire   [BITS_SIZE-1      :0]   o_sum_pc_branch;


sum_branch u_sum_branch(
    .i_extension_data(i_extension_data),
    .i_sum_pc4(i_sum_pc4),
    .o_sum_pc_branch(o_sum_pc_branch)  
);

    initial begin

        #20
        i_clk = 1'b0;
        #20
        i_extension_data = 32'b01;
        i_sum_pc4        = 32'b01;
        #20

        #100
        $display("############# Test OK ############");
        $finish();
    end
  
      // CLOCK_GENERATION
    always #10 i_clk = ~i_clk;

endmodule