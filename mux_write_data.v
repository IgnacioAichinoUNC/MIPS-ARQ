`timescale 1ns / 1ps

module mux_write_data
    #(
        parameter BITS_SIZE = 32
    )
    (
        input   wire                          i_jal,
        input   wire     [BITS_SIZE-1:0]      i_data_write,
        input   wire     [BITS_SIZE-1:0]      i_pc8,
        output  wire     [BITS_SIZE-1:0]      o_data_write                 
    );

    reg [BITS_SIZE-1:0]   reg_data_write;


    always @(*)
    begin
        case(i_jal)
            1'b0:   reg_data_write  <=  i_data_write;   
            1'b1:   reg_data_write  <=  i_pc8;
        endcase
    end

    assign  o_data_write=   reg_data_write;

endmodule