`timescale 1ns / 1ps

module mux_memory
    #(
        parameter BITS_SIZE = 32
    )
    (
        input   wire                          i_mem_to_reg    ,
        input   wire     [BITS_SIZE-1:0]      i_data_to_reg    , //Memoria de Datos -> Dato del Filtro -> Dato de LUI 
        input   wire     [BITS_SIZE-1:0]      i_alu  , //Dato de la ALU
        output  wire     [BITS_SIZE-1:0]      o_to_mux_write_data                 
    );
    
    reg [BITS_SIZE-1:0]   reg_to_mux_write_data;
    
    always @(*)
    begin
        case(i_mem_to_reg)
            1'b0:   reg_to_mux_write_data  <=  i_alu;   
            1'b1:   reg_to_mux_write_data  <=  i_data_to_reg;
        endcase
    end

    assign  o_to_mux_write_data=   reg_to_mux_write_data;

endmodule
