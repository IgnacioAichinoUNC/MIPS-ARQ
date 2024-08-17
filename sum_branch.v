`timescale 1ns / 1ps


module sum_branch
    #(
        parameter BITS_SIZE = 32
    )
    (
        input   wire    [BITS_SIZE-1      :0]   i_extension_data,
        input   wire    [BITS_SIZE-1      :0]   i_sum_pc4,
        output  wire    [BITS_SIZE-1      :0]   o_sum_pc_branch                 
    );
    
    reg [BITS_SIZE-1  :0]   mux_sum_branch;    
    
    always @(*)
    begin
        mux_sum_branch   <=  (i_extension_data<<2) + i_sum_pc4  ;
    end  
     
    assign  o_sum_pc_branch   =   mux_sum_branch;


endmodule
