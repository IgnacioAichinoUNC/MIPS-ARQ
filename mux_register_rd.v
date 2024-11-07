`timescale 1ns / 1ps

module mux_register_rd
    #(
        parameter BITS_REGS = 5
    )
    (
        input   wire                         i_jal,
        input   wire     [BITS_REGS-1:0]     i_register_dst,
        output  wire     [BITS_REGS-1:0]     o_register_addr                 
    );

    reg [BITS_REGS-1  :0]   reg_register_addr;


    always @(*)
    begin
        case(i_jal)
            1'b0:   reg_register_addr  <=  i_register_dst;   
            1'b1:   reg_register_addr  <=  5'b11111; //En JAL se debe guardar el PC+8 en el registro 31
        endcase
    end

    assign  o_register_addr   =   reg_register_addr;

endmodule