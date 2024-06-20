`timescale 1ns / 1ps

module SignExtend #(
        parameter BITS_INMEDIATE    = 16,
        parameter BITS_EXTEND       = 16,
        parameter BITS_OUT          = 32
    )
    (
        input   wire    [BITS_INMEDIATE-1:0]        i_id_inmediate, //16 bits de la instrucción recibida por etapa IF
        input   wire    [1:0]                       i_extension_mode,
        output  wire    [BITS_OUT-1:0]              o_extensionresult //resultado de la extensión de signo
    );
    
    reg     [BITS_OUT-1:0] result_extension;

    always @(*)
    begin
        case(i_extension_mode) //Dependiendo el tipo de instrucción recibida tengo que extender la instrucción de una forma u otra
            2'b00:      result_extension  <=  {{BITS_EXTEND{i_id_inmediate[BITS_INMEDIATE-1]}}, i_id_inmediate}  ; //coloca los 16 bits inmediatos en la parte baja y la parte alta la completa repitiendo el bit más significativo del inmediato
            //1000 0000 0000 0000 -> 1111 1111 1111 1111 1000 0000 0000 0000
            2'b01:      result_extension  <=  {{BITS_EXTEND{1'b0}}, i_id_inmediate}; //coloca los 16 bits inmediatos en la parte baja y la parte alta la completa con 0
            //1000 0000 0000 0000 -> 0000 0000 0000 0000 1000 0000 0000 0000
            2'b10:      result_extension  <=  {i_id_inmediate,{BITS_EXTEND{1'b0}}}; //coloca 0 en la parte baja  y en la parte alta coloca los 16 bits inmediatos
            //1000 0000 0000 0000 -> 1000 0000 0000 0000 0000 0000 0000 0000   
            default:    result_extension  <= -1;
        endcase
    end

    assign o_extensionresult = result_extension;
    
endmodule
