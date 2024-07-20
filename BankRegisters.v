`timescale 1ns / 1ps

module BankRegisters
    #(
        parameter   BITS_REGS    =   5,
        parameter   BITS_SIZE   =   32,
        parameter   REG_SIZE    =   32
    )
    (
        input   wire                        i_clk,
        input   wire                        i_reset,
        input   wire                        i_step,        
        input   wire                        i_flag_regWrite,
        input   wire    [BITS_REGS-1:0]     i_addr_rs, 
        input   wire    [BITS_REGS-1:0]     i_addr_rt, 
        input   wire    [BITS_REGS-1:0]     i_addr_rd, 
        input   wire    [BITS_REGS-1:0]     i_adrr_unitdebug, 
        input   wire    [BITS_SIZE-1:0]     i_data_write, 
        output  reg     [BITS_SIZE-1:0]     o_rs, 
        output  reg     [BITS_SIZE-1:0]     o_rt, 
        output  reg     [BITS_SIZE-1:0]     o_reg_unitdebug
    );

    reg  [BITS_SIZE-1:0]    memory_registers[REG_SIZE-1:0]; //banco de registros
    integer i;

    initial
    begin
        for (i = 0; i < REG_SIZE; i = i + 1) begin //inicializa el banco de registros
                memory_registers[i] = i;
        end
    end


    always @(*)
    begin
        o_rs                <=  memory_registers[i_addr_rs];
        o_rt                <=  memory_registers[i_addr_rt];
        o_reg_unitdebug     <=  memory_registers[i_adrr_unitdebug];  //Para enviar info a la unitDebug y poder ver en patalla el dato
    end

    always @(negedge i_clk )
    begin
        if(i_reset) begin
            for (i = 0; i < REG_SIZE; i = i + 1) begin //vuelve a inicializar el banco de registros en caso de reset
                memory_registers[i] <= i;
            end
        end 
        else if(i_flag_regWrite & i_step) begin //si tengo que escribir en el banco de registros
            memory_registers[i_addr_rd] <= i_data_write ; //i_RD es la dirección de memoria donde debo escribir el dato
        end
    end
endmodule