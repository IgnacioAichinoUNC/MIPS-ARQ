`timescale 1ns / 1ps

module pc_jump
    #(
        parameter BITS_SIZE     =  32,
        parameter BITS_JUMP     =  26
    )
    (
        input   wire    [BITS_JUMP-1 :0]    i_ifid_jump, //[25:0] address en Instrucction IF
        input   wire    [BITS_SIZE-1:0]     i_ifid_pc4,
        output  wire    [BITS_SIZE-1:0]     o_ID_JUMP                 
    );
    
    reg [BITS_SIZE-1:0] reg_jump;    
    
    always @(*)
    begin
        reg_jump   <=  {i_ifid_pc4[BITS_SIZE-1:27], (i_ifid_jump<<2)}  ; //se obtienen los bits 31 a 27 y se concatenan con i_ifid_jump
                                                             //i_ifid_jump se desplazo 2 lugares a la izq, lo que equivale a multiplicar por 4
                                                             //calculo el salto
    end   
    
   assign  o_ID_JUMP  = reg_jump;
endmodule