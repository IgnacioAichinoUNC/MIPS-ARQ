`timescale 1ns / 1ps

module RegisterFile
    #(
        //parameter   REGS        =   5,
        parameter   BITS_REGS    =   5,
        parameter   BITS_SIZE   =   32,
        //parameter   TAM         =   32  
        parameter   REG_SIZE    =   32
    )
    (
        input   wire                        i_clk,
        input   wire                        i_reset,
        input   wire                        i_RegWrite,
        input   wire                        i_step,
        input   wire    [BITS_REGS-1:0]      i_dir_rs, //Leer registro 1
        input   wire    [BITS_REGS-1:0]      i_dir_rt, //Leer registro 2
        input   wire    [BITS_REGS-1:0]      i_RD, //Escribir registro
        input   wire    [BITS_REGS-1:0]      i_RegDebug, //Leer registro debug
        input   wire    [BITS_SIZE-1:0]         i_DatoEscritura, //Escribir dato
        output  reg     [BITS_SIZE-1:0]         o_data_rs, // Dato leido 1
        output  reg     [BITS_SIZE-1:0]         o_data_rt, // Dato leido 2
        output  reg     [BITS_SIZE-1:0]         o_RegDebug
    );
    
    reg     [BITS_SIZE-1:0]         memory[REG_SIZE-1:0]; //banco de registros
    integer                     i;
    
    initial
    begin
        for (i = 0; i < REG_SIZE; i = i + 1) begin //inicializa el banco de registros
                memory[i] = i;
        end
    end
    

    always @(*)
    begin
        o_data_rs       <=  memory[i_dir_rs];
        o_data_rt       <=  memory[i_dir_rt];
        o_RegDebug      <=  memory[i_RegDebug];
    end

    always @(negedge i_clk )
    begin
        if(i_reset) begin
            for (i = 0; i < REG_SIZE; i = i + 1) begin //vuelve a inicializar el banco de registros en caso de reset
                memory[i] <= i;
            end
        end else if(i_RegWrite & i_step) //si tengo que escribir en el banco de registros
        begin
            memory[i_RD] <= i_DatoEscritura ; //i_RD es la dirección de memoria donde debo escribir el dato
        end
    end
endmodule

