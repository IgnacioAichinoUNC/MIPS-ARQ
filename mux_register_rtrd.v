`timescale 1ns / 1ps

module mux_register_rtrd
    #(
        parameter BITS_REGS = 5
    )
    (
        input   wire                                i_reg_dst_rd,
        input   wire     [BITS_REGS-1      :0]      i_rd,
        input   wire     [BITS_REGS-1      :0]      i_rt,
        output  wire     [BITS_REGS-1      :0]      o_mux_register_rd                 
    );
    
    reg [BITS_REGS-1  :0]   reg_register_result;

    
    always @(*)
    begin
        case(i_reg_dst_rd)
            1'b0:   reg_register_result  <=  i_rt    ;   
            1'b1:   reg_register_result  <=  i_rd    ;
        endcase
    end

    assign  o_mux_register_rd   =   reg_register_result;

endmodule
