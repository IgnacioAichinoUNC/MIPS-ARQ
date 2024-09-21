`timescale 1ns / 1ps

module mux_lui
    #(
        parameter BITS_SIZE = 32
    )
    (
        input   wire                                i_lui,
        input   wire     [BITS_SIZE-1      :0]      i_extension,
        input   wire     [BITS_SIZE-1      :0]      i_filterL,
        output  wire     [BITS_SIZE-1      :0]      o_mux_memory                 
    );
    
    reg [BITS_SIZE-1  :0]   reg_mux_memory;

    
    always @(*)
    begin
        case(i_lui)
            1'b0:   reg_mux_memory   <=  i_filterL; // entrada proveniente del filtro load   
            1'b1:   reg_mux_memory   <=  i_extension;   // entrada proveniente del extensor de signo
        endcase
    end
    

    assign  o_mux_memory   =   reg_mux_memory ; //salida hacia mux_memory


endmodule
