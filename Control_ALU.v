`timescale 1ns / 1ps

module Control_ALU
    #(
        parameter   BITS_ALU        = 6,
        parameter   BITS_ALU_CTL    = 2,
        parameter   ALU_OP          = 4   
    )
    (
        input   wire    [BITS_ALU-1:0]      i_funct,
        input   wire    [BITS_ALU-1:0]      i_opcode,
        input   wire    [BITS_ALU_CTL-1:0]  i_unit_alu_op,    
        output  wire    [ALU_OP-1:0]        o_alu_op,
        output  wire                        o_shamt            
    );

localparam	ADD_C	=  6'b100000;	//Suma
localparam	SUB_C	=  6'b100010;	//Resta
localparam	SUBU_C  =  6'b100011;	//Resta Unsigned
localparam	AND_C	=  6'b100100;	//And
localparam	ANDI_C  =  6'b001100;	//And Immediate
localparam	OR_C	=  6'b100101;	//Or
localparam	ORI_C	=  6'b001101;	//Or Immediate
localparam  NOR_C   =  6'b100111;   //Nor
localparam  XOR_C   =  6'b100110;   //Xor
localparam  XORI_C  =  6'b001110;   //Xor Immediate
localparam	SLT_C	=  6'b101010;	//Set on Less than
localparam  SLTI_C  =  6'b001010;   //Set on Less than Immediate
localparam	ADDU_C  =  6'b100001;   //Add Unsigned Word
localparam	SLL_C   =  6'b000000;   //Shift Word Left Logical
localparam  SLLV_C  =  6'b000100;   //Shift Word Left Logical Variable
localparam	SRL_C   =  6'b000010;   //Shift Word Right Logical
localparam	SRLV_C  =  6'b000110;   //Shift Word Right Logical Variable
localparam	SRA_C   =  6'b000011;   //Shift Word Right Arithmetic
localparam	SRAV_C  =  6'b000111;   //Shift Word Right Arithmetic Variable

reg [ALU_OP-1:0] reg_alu_op;
   
    
    always @(*)
    begin : ALUOp
            case(i_unit_alu_op)
                2'b00:       
                        reg_alu_op   <=   4'b0000;
                2'b01:        
                        reg_alu_op   <=   4'b0001;
                2'b10:
                    case(i_funct)
                        ADD_C   :   reg_alu_op   <=   4'b0000;
                        SUB_C   :   reg_alu_op   <=   4'b0001;
                        SUBU_C  :   reg_alu_op   <=   4'b0001;
                        AND_C   :   reg_alu_op   <=   4'b0010;
                        OR_C    :   reg_alu_op   <=   4'b0011;
                        NOR_C   :   reg_alu_op   <=   4'b0100;
                        XOR_C   :   reg_alu_op   <=   4'b0101;
                        SLT_C   :   reg_alu_op   <=   4'b0111;
                        ADDU_C  :   reg_alu_op   <=   4'b0000;
                        SLL_C   :   reg_alu_op   <=   4'b1000;
                        SRL_C   :   reg_alu_op   <=   4'b1001; 
                        SLLV_C  :   reg_alu_op   <=   4'b1000;
                        SRLV_C  :   reg_alu_op   <=   4'b1001; 
                        SRA_C   :   reg_alu_op   <=   4'b1011;
                        SRAV_C  :   reg_alu_op   <=   4'b1011;                        
                        default :   reg_alu_op   <=   -2;
                    endcase       
                2'b11:
                    case(i_opcode)
                        SLTI_C   :   reg_alu_op   <=   4'b0111;
                        ANDI_C   :   reg_alu_op   <=   4'b0010;
                        ORI_C    :   reg_alu_op   <=   4'b0011;   
                        XORI_C   :   reg_alu_op   <=   4'b0101;                          
                        default :    reg_alu_op   <=   -3;
                    endcase       
                
                default:    reg_alu_op   <=   -1;
            endcase
    end
    
    assign o_alu_op    =   reg_alu_op;
    assign o_shamt     =   (i_funct == SRA_C | i_funct == SRL_C | i_funct == SLL_C) ? 1 : 0 ;
endmodule