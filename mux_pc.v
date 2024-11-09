`timescale 1ns / 1ps

module mux_pc
    #(
        parameter SIZE_ADDR_PC  =  32
    )
    (
        input   wire                        i_is_jump,
        input   wire                        i_is_JALR,
        input   wire    [SIZE_ADDR_PC-1:0]  i_rs,
        input   wire                        i_pc_source,
        input   wire    [SIZE_ADDR_PC-1:0]  i_suma_branch,
        input   wire    [SIZE_ADDR_PC-1:0]  i_suma_pc4,        
        input   wire    [SIZE_ADDR_PC-1:0]  i_suma_jump,
        output  wire    [SIZE_ADDR_PC-1:0]  o_pc          
    );
    
    reg [SIZE_ADDR_PC-1:0]  reg_pc;
   
    always @(*)
    begin
        if(i_is_jump)
            reg_pc <=  i_suma_jump;
        else if (i_is_JALR)
            reg_pc <=  i_rs;
        else if(i_pc_source)
            reg_pc <=  i_suma_branch;
        else
            reg_pc <=  i_suma_pc4;  
    end

    assign o_pc = reg_pc;

endmodule
