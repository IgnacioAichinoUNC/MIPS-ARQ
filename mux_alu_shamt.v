`timescale 1ns / 1ps

module mux_alu_shamt
    #(
        parameter BITS_SIZE             = 32,
        parameter BITS_CORTOCIRCUITO    = 3
    )
    (
        input   wire  [BITS_CORTOCIRCUITO-1:0]  i_corto_register_A,
        input   wire  [BITS_SIZE-1:0]           i_idex_register1,
        input   wire  [BITS_SIZE-1:0]           i_exmem_register,
        input   wire  [BITS_SIZE-1:0]           i_memwb_register,
        output  wire  [BITS_SIZE-1:0]           o_mux_alu_a                 
    );
    
    reg [BITS_SIZE-1  :0]   reg_register_alu_a;
    
    assign o_mux_alu_a =    reg_register_alu_a;
    
    always @(*)
    begin
        case(i_corto_register_A)
            3'b001:      reg_register_alu_a  <=  i_exmem_register;
            3'b010:      reg_register_alu_a  <=  i_memwb_register; 
            default :    reg_register_alu_a  <=  i_idex_register1;
        endcase
       end
          
endmodule
