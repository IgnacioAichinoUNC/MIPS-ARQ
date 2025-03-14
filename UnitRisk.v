`timescale 1ns / 1ps

module UnitRisk
    #(
        parameter BITS_REGS =   5
       
    )
    (
        input   wire                    i_IDEX_mem_read, //señal que indica si debo leer de la memoria.
        input   wire                    i_EXMEM_mem_read, //señal que indica si debo leer de la memoria. ESTE PUEDE SER IGUAL QUE i_IDEX_mem_read EN EL CASO QUE NO HAYA UN BRANCH.
        input   wire                    i_JALR, //vale 1 en JALR o JR
        input   wire                    i_HALT, //vale 1 en HALT
        input   wire [BITS_REGS-1:0]    i_IDEX_rt, //Rt que pasa a la etapa de EX (que viene del banco de registros)
        input   wire [BITS_REGS-1:0]    i_EXMEM_rt, //Rt que pasa a la etapa de MEM
        input   wire [BITS_REGS-1:0]    i_IFID_rs, //Rs que viene de la etapa IF
        input   wire [BITS_REGS-1:0]    i_IFID_rt, //Rt que viene de la etapa IF
        output  wire                    o_risk_mux,
        output  wire                    o_pc_write,
        output  wire                    o_IFID_write
    );

    reg reg_IFID_write;
    reg reg_risk_mux ;
    reg reg_pc_write;

    initial
    begin
        reg_risk_mux        <=      1'b0;
        reg_pc_write        <=      1'b1;
        reg_IFID_write      <=      1'b1;
    end


    always @(*)
    begin
        //Si tengo que hacer una lectura de memoria (hacer un load) y
        //si el Rt (registro destino del load) que recibe la etapa EX es igual a alguno de los registros fuentes de la instrucción siguiente (Rs o Rt)
        //O
        //Si tengo que hacer una lectura de memoria (hacer un load) y Si el Rt (registro destino del load) que recibe la etapa MEM es igual al registro fuente de la instrucción siguiente (Rs) y es una instrucción JALR
        //Si se da alguno de estos casos significa que tengo riesgo por lo tanto no puedo pasar la próxima instrucción (reg_IFID_write) y no puedo actualizar el PC
        //EL SEGUNDO CASO SERÍA SI YO QUIERO HACER UN SALTO A UN REGISTRO CON UNA CONDICIÓN TODAVÍA NO EVALUADA (YO TODAVÍA NO LEÍ DE MEMORIA EL REGISTRO CON LA DIRECCIÓN A LA QUE QUIERO HACER EL SALTO)
        if((i_IDEX_mem_read && ((i_IDEX_rt == i_IFID_rs) | (i_IDEX_rt == i_IFID_rt))) | ((i_EXMEM_mem_read && (i_EXMEM_rt == i_IFID_rs)) && i_JALR))
        begin
            reg_risk_mux        <= 1'b1; //risk 1
            reg_pc_write        <= 1'b0; //No escribir 0
            reg_IFID_write      <= 1'b0; //No escribir 0
        end
        //Ultima instruccion por lo tanto no actualizo el PC
        else if (i_HALT)
        begin
            reg_risk_mux        <= 1'b0;
            reg_pc_write        <= 1'b0;
            reg_IFID_write      <= 1'b1;
        end
        else
        begin
            reg_risk_mux        <= 1'b0;
            reg_pc_write        <= 1'b1;
            reg_IFID_write      <= 1'b1;
        end
    end

    assign  o_risk_mux      =   reg_risk_mux;
    assign  o_pc_write      =   reg_pc_write;
    assign  o_IFID_write    =   reg_IFID_write;
endmodule