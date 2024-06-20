`timescale 1ns / 1ps

module UnitRisk
    #(
        parameter BITS_REGS    =   5
        //parameter MUXBITS   =   3
    )
    (
        input   wire                i_EXMEM_Flush, //es el mismo que se utiliza en IF para seleccionar suma_branch en el mux de PC
        input   wire                i_IDEX_MemRead, //señal que indica si debo leer de la memoria.
        input   wire                i_EXMEM_MemRead, //señal que indica si debo leer de la memoria. ESTE PUEDE SER IGUAL QUE i_IDEX_MemRead EN EL CASO QUE NO HAYA UN BRANCH.
        input   wire                i_JALR, //vale 1 en caso de que sea una instrucción JALR o JR
        input   wire                i_HALT, //vale 1 en caso de que sea una instrucción HALT
        input   wire [BITS_REGS-1:0]   i_IDEX_Rt, //Rt que pasa a la etapa de EX (que viene del banco de registros)
        input   wire [BITS_REGS-1:0]   i_EXMEM_Rt , //Rt que pasa a la etapa de MEM
        input   wire [BITS_REGS-1:0]   i_IFID_Rs , //Rs que viene de la etapa IF
        input   wire [BITS_REGS-1:0]   i_IFID_Rt, //Rt que viene de la etapa IF
        output  wire                o_Mux_Risk,
        output  wire                o_pc_Write,
        output  wire                o_IFID_Write,
        output  wire                o_Latch_Flush
    );

    reg Reg_IFID_Write;
    reg Reg_Latch_Flush;
    reg Reg_IFID_Flush;
    reg Reg_Mux_Risk ;
    reg Reg_PC_Write;

    initial
    begin
        Reg_Mux_Risk       <=      1'b0;
        Reg_PC_Write       <=      1'b1;
        Reg_IFID_Write    <=      1'b1;
        Reg_Latch_Flush    <=      1'b0;
        Reg_IFID_Flush    <=      1'b0;
    end

    always @(*)
    begin
        if(i_EXMEM_Flush) //En el caso que sea un branch tiene que volver a la etapa IF para buscar la nueva instrucción
        begin
            Reg_Latch_Flush      <= 1'b1;
        end
        else
        begin
            Reg_Latch_Flush      <= 1'b0;
        end
    end

    always @(*)
    begin
        //Si tengo que hacer una lectura de memoria (hacer un load) y
        //si el Rt (registro destino del load) que recibe la etapa EX es igual a alguno de los registros fuentes de la instrucción siguiente (Rs o Rt)
        //O
        //Si tengo que hacer una lectura de memoria (hacer un load) y Si el Rt (registro destino del load) que recibe la etapa MEM es igual al registro fuente de la instrucción siguiente (Rs) y
        //Si es una instrucción JALR
        //Si se da alguno de estos casos significa que tengo riesgo por lo tanto no puedo pasar la próxima instrucción (Reg_IFID_Write) y no puedo actualizar el PC
        //EL SEGUNDO CASO SERÍA SI YO QUIERO HACER UN SALTO A UN REGISTRO CON UNA CONDICIÓN TODAVÍA NO EVALUADA (YO TODAVÍA NO LEÍ DE MEMORIA EL REGISTRO CON LA DIRECCIÓN A LA QUE QUIERO HACER EL SALTO)
        if((i_IDEX_MemRead && ((i_IDEX_Rt == i_IFID_Rs) | (i_IDEX_Rt == i_IFID_Rt))) | ((i_EXMEM_MemRead && (i_EXMEM_Rt == i_IFID_Rs)) && i_JALR))
        begin
            Reg_Mux_Risk        <= 1'b1; //risk 1
            Reg_PC_Write        <= 1'b0; //No escribir 0
            Reg_IFID_Write      <= 1'b0; //No escribir 0
        end
        //Si es una instrucción de HALT, entonces no tengo riesgo. Puedo pasar la próxima instrucción pero es la última por lo tanto no actualizo el PC
        else if (i_HALT)
        begin
            Reg_Mux_Risk        <= 1'b0;
            Reg_PC_Write        <= 1'b0;
            Reg_IFID_Write      <= 1'b1;
        end
        //Acá no tengo riesgo, y no es la última instrucción, por lo tanto continua con el funcionamiento normal.
        else
        begin
            Reg_Mux_Risk        <= 1'b0;
            Reg_PC_Write        <= 1'b1;
            Reg_IFID_Write      <= 1'b1;
        end
    end
    
    assign  o_Mux_Risk      =   Reg_Mux_Risk;
    assign  o_pc_Write      =   Reg_PC_Write;
    assign  o_IFID_Write   =   Reg_IFID_Write;
    assign  o_Latch_Flush   =   Reg_Latch_Flush;
endmodule
