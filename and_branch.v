`timescale 1ns / 1ps
module and_branch
    (
        input   wire    i_branch    ,
        input   wire    i_neq_branch   ,
        input   wire    i_zero      ,
        output  wire    o_pc_source                 
    );
    
    reg reg_result  ;    
    
    initial 
    begin
        reg_result     <=      1'b0;      
    end
    
    always @(*)
    begin
        if((i_branch && i_zero) || (i_neq_branch && !i_zero))
            reg_result   <=     1'b1    ;
        else
            reg_result   <=     1'b0    ;
    end
    
    assign  o_pc_source   =   reg_result  ;       
endmodule
