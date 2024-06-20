`timescale 1ns / 1ps
module mux_unit_risk
    (
        //Unidad de Riesgos
        input   wire                           i_Risk,
        //Unidad de Control
        input  wire                            i_RegDst,
        input  wire                            i_Jump,
        input  wire                            i_JAL,
        input  wire                            i_Branch,
        input  wire                            i_NBranch,
        input  wire                            i_MemRead,
        input  wire                            i_MemToReg,
        input  wire    [1:0]                   i_ALUOp,
        input  wire                            i_MemWrite,
        input  wire                            i_ALUSrc,
        input  wire                            i_RegWrite,
        input  wire    [1:0]                   i_extension_mode,
        input  wire    [1:0]                   i_TamanoFiltro,
        input  wire    [1:0]                   i_TamanoFiltroL,
        input  wire                            i_ZeroExtend,
        input  wire                            i_LUI,
        input  wire                            i_JALR,
        input  wire                            i_HALT,

        output  wire                            o_RegDst,
        output  wire                            o_Jump,
        output  wire                            o_JAL,
        output  wire                            o_Branch,
        output  wire                            o_NBranch,
        output  wire                            o_MemRead,
        output  wire                            o_MemToReg,
        output  wire    [1:0]                   o_ALUOp,
        output  wire                            o_MemWrite,
        output  wire                            o_ALUSrc ,
        output  wire                            o_RegWrite,
        output  wire    [1:0]                   o_ExtensionMode,
        output  wire    [1:0]                   o_TamanoFiltro,
        output  wire    [1:0]                   o_TamanoFiltroL,
        output  wire                            o_ZeroExtend,
        output  wire                            o_LUI,
        output  wire                            o_JALR,
        output  wire                            o_HALT
    );

        reg                            Reg_RegDst;
        reg                            Reg_Jump;
        reg                            Reg_JAL;
        reg                            Reg_Branch;
        reg                            Reg_NBranch;
        reg                            Reg_MemRead;
        reg                            Reg_MemToReg;
        reg    [1:0]                   Reg_ALUOp;
        reg                            Reg_MemWrite;
        reg                            Reg_ALUSrc;
        reg                            Reg_RegWrite;
        reg    [1:0]                   Reg_ExtensionMode;
        reg    [1:0]                   Reg_TamanoFiltro;
        reg    [1:0]                   Reg_TamanoFiltroL;
        reg                            Reg_ZeroExtend;
        reg                            Reg_LUI;
        reg                            Reg_JALR;


        always @(*)
        begin
            if(i_Risk)
                begin
                    Reg_RegDst            <=      1'b0    ;
                    Reg_Jump              <=      1'b0    ;
                    Reg_JAL               <=      1'b0    ;
                    Reg_Branch            <=      1'b0    ;
                    Reg_NBranch           <=      1'b0    ;
                    Reg_MemRead           <=      1'b0    ;
                    Reg_MemToReg          <=      1'b0    ;
                    Reg_ALUOp             <=      1'b0    ;
                    Reg_MemWrite          <=      1'b0    ;
                    Reg_ALUSrc            <=      1'b0    ;
                    Reg_RegWrite          <=      1'b0    ;
                    Reg_ExtensionMode     <=      1'b0    ;
                    Reg_TamanoFiltro      <=      1'b0    ;
                    Reg_TamanoFiltroL     <=      1'b0    ;
                    Reg_ZeroExtend        <=      1'b0    ;
                    Reg_LUI               <=      1'b0    ;
                    Reg_JALR              <=      1'b0    ;
                end
            else
                begin
                    Reg_RegDst            <=      i_RegDst          ;
                    Reg_Jump              <=      i_Jump            ;
                    Reg_JAL               <=      i_JAL             ;
                    Reg_Branch            <=      i_Branch          ;
                    Reg_NBranch           <=      i_NBranch         ;
                    Reg_MemRead           <=      i_MemRead         ;
                    Reg_MemToReg          <=      i_MemToReg        ;
                    Reg_ALUOp             <=      i_ALUOp           ;
                    Reg_MemWrite          <=      i_MemWrite        ;
                    Reg_ALUSrc            <=      i_ALUSrc          ;
                    Reg_RegWrite          <=      i_RegWrite        ;
                    Reg_ExtensionMode     <=      i_extension_mode   ;
                    Reg_TamanoFiltro      <=      i_TamanoFiltro    ;
                    Reg_TamanoFiltroL     <=      i_TamanoFiltroL   ;
                    Reg_ZeroExtend        <=      i_ZeroExtend      ;
                    Reg_LUI               <=      i_LUI             ;
                    Reg_JALR              <=      i_JALR            ;
                end
          end
          
        assign o_RegDst         = Reg_RegDst;
        assign o_Jump           = Reg_Jump;
        assign o_JAL            = Reg_JAL;
        assign o_Branch         = Reg_Branch;
        assign o_NBranch        = Reg_NBranch;
        assign o_MemRead        = Reg_MemRead;
        assign o_MemToReg       = Reg_MemToReg;
        assign o_ALUOp          = Reg_ALUOp;
        assign o_MemWrite       = Reg_MemWrite;
        assign o_ALUSrc         = Reg_ALUSrc;
        assign o_RegWrite       = Reg_RegWrite;
        assign o_ExtensionMode  = Reg_ExtensionMode;
        assign o_TamanoFiltro   = Reg_TamanoFiltro;
        assign o_TamanoFiltroL  = Reg_TamanoFiltroL;
        assign o_ZeroExtend     = Reg_ZeroExtend;
        assign o_LUI            = Reg_LUI;
        assign o_JALR           = Reg_JALR;
        assign o_HALT           = i_HALT;
endmodule
