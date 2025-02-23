`timescale 1ns / 1ps

module IDEX
    #(
        parameter BITS_SIZE     =   32,
        parameter BITS_REGS     =   5
    )
    (
        //GeneralInputs
        input   wire                        i_clk,
        input   wire                        i_reset,
        input   wire                        i_step,
        input   wire    [BITS_SIZE-1:0]     i_pc4,
        input   wire    [BITS_SIZE-1:0]     i_pc8,
        input   wire    [BITS_SIZE-1:0]     i_instruction,

        input   wire    [BITS_SIZE-1:0]     i_data_rs,          // dato leido 1
        input   wire    [BITS_SIZE-1:0]     i_register_data_2, // dato leido 2
        input   wire    [BITS_SIZE-1:0]     i_extension,
        input   wire    [BITS_REGS-1:0]     i_rt,
        input   wire    [BITS_REGS-1:0]     i_rd,
        input   wire    [BITS_REGS-1:0]     i_rs,
        
        ///ControlEX
        input   wire                        i_reg_dst_rd,
        input   wire                        i_jal,
        input   wire                        i_alu_src,
        input   wire    [1:0]               i_unit_alu_op,
        ///ControlMEM
        input   wire                        i_mem_write,
        input   wire                        i_mem_read ,
        input   wire    [1:0]               i_datomem_size,
        ///ControlWB
        input   wire                        i_mem_to_reg,
        input   wire                        i_reg_write,
        input   wire    [1:0]               i_data_load_size,
        input   wire                        i_zero_extend,
        input   wire                        i_lui,
        input   wire                        i_halt,

        output  wire    [BITS_SIZE-1:0]     o_pc4,
        output  wire    [BITS_SIZE-1:0]     o_pc8,
        output  wire    [BITS_SIZE-1:0]     o_instruction,
        output  wire    [BITS_SIZE-1:0]     o_register_1,
        output  wire    [BITS_SIZE-1:0]     o_register_2,
        output  wire    [BITS_SIZE-1:0]     o_extension,
        output  wire    [BITS_REGS-1:0]     o_rs,
        output  wire    [BITS_REGS-1:0]     o_rt,
        output  wire    [BITS_REGS-1:0]     o_rd,

        ///ControlEX
        output  wire                        o_jal,
        output  wire                        o_alu_src,
        output  wire    [1:0]               o_unit_alu_op,
        output  wire                        o_register_rd_dst,
        ///ControlMEM
        output  wire                        o_mem_write,
        output  wire                        o_mem_read ,
        output  wire    [1:0]               o_datamem_size,
        ///ControlWB
        output  wire                        o_mem_to_reg,
        output  wire                        o_register_write,
        output  wire    [1:0]               o_data_load_size,
        output  wire                        o_zero_extend,
        output  wire                        o_lui,
        output  wire                        o_halt
    );

    reg     [BITS_SIZE-1:0] reg_PC4;
    reg     [BITS_SIZE-1:0] reg_PC8;
    reg     [BITS_SIZE-1:0] reg_instruction;
    reg     [BITS_SIZE-1:0] reg_data_reg1;
    reg     [BITS_SIZE-1:0] reg_data_reg2;
    reg     [BITS_SIZE-1:0] reg_extension;
    reg     [BITS_REGS-1:0] reg_rs;
    reg     [BITS_REGS-1:0] reg_rt;
    reg     [BITS_REGS-1:0] reg_rd;

    //RegEX
    reg                     reg_jal ;
    reg                     reg_alu_src;
    reg     [1:0]           reg_unit_alu_op;
    reg                     reg_register_rd;

    //RegMEM
    reg                     reg_mem_write ;
    reg                     reg_mem_read;
    reg     [1:0]           reg_datamem_size;

    //RegWB
    reg                     reg_mem_to_register;
    reg                     reg_register_write;
    reg     [1:0]           reg_data_load_size;
    reg                     reg_zero_extend;
    reg                     reg_lui;
    reg                     reg_halt;


    always @(posedge i_clk)
        if( i_reset)
        begin
            reg_PC4             <=  {BITS_SIZE{1'b0}};
            reg_PC8             <=  {BITS_SIZE{1'b0}};
            reg_instruction     <=  {BITS_SIZE{1'b0}};
            reg_data_reg1       <=  {BITS_SIZE{1'b0}};
            reg_data_reg2       <=  {BITS_SIZE{1'b0}};
            reg_extension       <=  {BITS_SIZE{1'b0}};
            reg_rs              <=  {BITS_REGS{1'b0}};
            reg_rt              <=  {BITS_REGS{1'b0}};
            reg_rd              <=  {BITS_REGS{1'b0}};

            //EX
            reg_jal             <=  1'b0;
            reg_alu_src         <=  1'b0;
            reg_unit_alu_op     <=  2'b00;
            reg_register_rd     <=  1'b0;

            //M
            reg_mem_write       <=  1'b0;
            reg_mem_read        <=  1'b0;
            reg_datamem_size    <=  2'b00;

            //WB
            reg_mem_to_register <=  1'b0;
            reg_register_write  <=  1'b0;
            reg_data_load_size  <=  2'b00;
            reg_zero_extend     <=  1'b0;
            reg_lui             <=  1'b0;
            reg_halt            <=  1'b0;
        end
        else if (i_step)
        begin
            reg_PC4             <=  i_pc4;
            reg_PC8             <=  i_pc8 ;
            reg_instruction     <=  i_instruction;
            reg_data_reg1       <=  i_data_rs;
            reg_data_reg2       <=  i_register_data_2;
            reg_extension       <=  i_extension;
            reg_rs              <=  i_rs;
            reg_rt              <=  i_rt;
            reg_rd              <=  i_rd;

            //EX
            reg_jal             <=  i_jal;
            reg_alu_src         <=  i_alu_src;
            reg_unit_alu_op     <=  i_unit_alu_op;
            reg_register_rd     <=  i_reg_dst_rd;

            //MEM
            reg_mem_write       <=  i_mem_write;
            reg_mem_read        <=  i_mem_read;
            reg_datamem_size     <=  i_datomem_size;

            //WB
            reg_mem_to_register <=  i_mem_to_reg;
            reg_register_write  <=  i_reg_write;
            reg_data_load_size  <=  i_data_load_size;
            reg_zero_extend     <=  i_zero_extend;
            reg_lui             <=  i_lui;
            reg_halt            <=  i_halt;
        end


    assign o_pc4            =   reg_PC4;
    assign o_pc8            =   reg_PC8;
    assign o_instruction    =   reg_instruction;
    assign o_register_1     =   reg_data_reg1;
    assign o_register_2     =   reg_data_reg2;
    assign o_extension      =   reg_extension;
    assign o_rs             =   reg_rs;
    assign o_rt             =   reg_rt;
    assign o_rd             =   reg_rd;

    //ControlEX
    assign o_jal             =   reg_jal;
    assign o_alu_src         =   reg_alu_src;
    assign o_unit_alu_op     =   reg_unit_alu_op;
    assign o_register_rd_dst =   reg_register_rd ;

    //ControlMEM
    assign o_mem_write       =   reg_mem_write;
    assign o_mem_read        =   reg_mem_read;
    assign o_datamem_size    =   reg_datamem_size;

    //ControlWB
    assign o_mem_to_reg      =   reg_mem_to_register;
    assign o_register_write  =   reg_register_write;
    assign o_data_load_size  =   reg_data_load_size;
    assign o_zero_extend     =   reg_zero_extend;
    assign o_lui             =   reg_lui;
    assign o_halt            =   reg_halt;
    
endmodule