`timescale 1ns / 1ps

module PC_Jump
    #(
        parameter BITS_SIZE =  32,
        parameter BITS_JUMP =  26
    )
    (
        input   wire    [BITS_JUMP-1:0]      i_IFID_JUMP, //los bits 0 a 26 de la instrucción que entrega el IF (dirección a la que voy a saltar)
        input   wire    [BITS_SIZE-1:0]      i_IDEX_PC4, //PC+4 que entrega la etapa IF
        output  wire    [BITS_SIZE-1:0]      o_ID_JUMP   //Entrega el salto que debe realizar    
    );
    
    reg [BITS_SIZE-1:0]   ID_JUMP_reg   ;    
    
    always @(*)
    begin
        ID_JUMP_reg   <=  {i_IDEX_PC4[BITS_SIZE-1:27], (i_IFID_JUMP<<2)}  ; //se obtienen los bits 31 a 27 y se concatenan con i_IFID_JUMP
                                                             //i_IFID_JUMP se desplazo 2 lugares a la izq, lo que equivale a multiplicar por 4
                                                             //calculo el salto
    end   
    
   assign  o_ID_JUMP   = ID_JUMP_reg   ;
endmodule
