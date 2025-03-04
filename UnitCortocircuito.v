`timescale 1ns / 1ps

module UnitCortocircuito
    #(
        parameter BITS_REGS             = 5,
        parameter BITS_CORTOCIRCUITO    = 3
    )
    (
        input   wire                            i_EXMEM_register_write,
        input   wire [BITS_REGS-1  :0]          i_EXMEM_rdrt,
        input   wire                            i_MEMWB_reg_write,
        input   wire [BITS_REGS-1  :0]          i_MEMWB_rdrt, 
        input   wire [BITS_REGS-1  :0]          i_rs,
        input   wire [BITS_REGS-1  :0]          i_rt,
        
        output  wire [BITS_CORTOCIRCUITO-1 :0]  o_mux_A,
        output  wire [BITS_CORTOCIRCUITO-1 :0]  o_mux_B
    );
    
    reg [BITS_CORTOCIRCUITO-1 :0]  reg_mux_A;
    reg [BITS_CORTOCIRCUITO-1 :0]  reg_mux_B;
    
    always @(*)
    begin
        if(i_EXMEM_register_write && (i_rs == i_EXMEM_rdrt))begin
            reg_mux_A = 3'b001;
        end
        else if (i_MEMWB_reg_write && (i_rs == i_MEMWB_rdrt))begin
            reg_mux_A = 3'b010;
        end
        else begin
            reg_mux_A = 3'b000;
        end
    end
      
    always @(*)
    begin
        if (i_EXMEM_register_write && (i_rt == i_EXMEM_rdrt)) begin
            reg_mux_B = 3'b001;
        end
        else if (i_MEMWB_reg_write && (i_rt == i_MEMWB_rdrt)) begin
            reg_mux_B = 3'b010;
        end
        else begin
            reg_mux_B = 3'b000;
        end
    end


    assign  o_mux_A =   reg_mux_A;
    assign  o_mux_B =   reg_mux_B;

endmodule