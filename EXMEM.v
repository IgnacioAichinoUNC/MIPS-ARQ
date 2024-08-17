`timescale 1ns / 1ps

module EXMEM
    #(
        parameter BITS_SIZE         =   32,
        parameter BITS_REGS         =   5       
    )
    (  
        input   wire                        i_clk,
        input   wire                        i_reset,
        input   wire                        i_step,
        input   wire                        i_flush_latch,
        input   wire    [BITS_SIZE-1:0]     i_pc4,
        input   wire    [BITS_SIZE-1:0]     i_pc8,
        input   wire    [BITS_REGS-1:0]     i_register_dst,
        input   wire    [BITS_SIZE-1:0]     i_pc_branch,
        input   wire    [BITS_SIZE-1:0]     i_idex_instruction,
        input   wire                        i_flag_alu_zero,
        input   wire    [BITS_SIZE-1:0]     i_alu_result,
        input   wire    [BITS_SIZE-1:0]     i_idex_register2,
        input   wire    [BITS_SIZE-1:0]     i_idex_extension,
        // ControlM
        input   wire                        i_branch,
        input   wire                        i_new_branch,
        input   wire                        i_mem_write,
        input   wire                        i_mem_read, 
        input   wire    [1:0]               i_size_filter, 
        // ControlWB
        input   wire                        i_jal,      
        input   wire                        i_mem_to_reg,
        input   wire                        i_reg_write,
        input   wire    [1:0]               i_size_filterL,
        input   wire                        i_zero_extend,
        input   wire                        i_lui,
        input   wire                        i_halt,

        output  wire    [BITS_SIZE-1:0]     o_pc4,
        output  wire    [BITS_SIZE-1:0]     o_pc8,      
        output  wire    [BITS_SIZE-1:0]     o_pc_branch,
        output  wire    [BITS_SIZE-1:0]     o_instruction,
        output  wire                        o_jal,
        output  wire                        o_zero,
        output  wire    [BITS_SIZE-1:0]     o_alu,
        output  wire    [BITS_SIZE-1:0]     o_register_2,
        output  wire    [BITS_REGS-1:0]     o_register_rd_dst,
        output  wire    [BITS_SIZE-1:0]     o_extension,
        // OControlM
        output  wire                        o_branch,
        output  wire                        o_new_branch,
        output  wire                        o_mem_write,
        output  wire                        o_mem_read,
        output  wire   [1:0]                o_size_filter,
        // OControlWB
        output  wire                        o_mem_to_reg,
        output  wire                        o_register_write,
        output  wire   [1:0]                o_size_filterL,
        output  wire                        o_zero_extend,
        output  wire                        o_lui,
        output  wire                        o_halt
    );

    reg     [BITS_SIZE-1    :0] reg_pc4;
    reg     [BITS_SIZE-1    :0] reg_pc8;
    reg     [BITS_SIZE-1    :0] reg_pc_branch;
    reg     [BITS_SIZE-1    :0] reg_instruction;
    reg                         reg_jal;
    reg                         reg_zero;
    reg     [BITS_SIZE-1    :0] reg_alu;
    reg     [BITS_SIZE-1    :0] reg_register2;
    reg     [BITS_REGS-1    :0] reg_register_dst;
    reg     [BITS_SIZE-1    :0] reg_extension;

    // RegM
    reg                         reg_branch;
    reg                         reg_new_branch;
    reg                         reg_mem_write;
    reg                         reg_mem_read;
    reg     [1:0]               reg_size_filter;

    // RegWB
    reg                         reg_mem_to_reg;
    reg                         reg_register_write;
    reg     [1:0]               reg_size_filterL;
    reg                         reg_zero_extend;
    reg                         reg_lui;
    reg                         reg_halt;

    always @(posedge i_clk)
        if(i_flush_latch | i_reset)
             begin 
                reg_pc4             <=  {BITS_SIZE{1'b0}};
                reg_pc8             <=  {BITS_SIZE{1'b0}};
                reg_pc_branch       <=  {BITS_SIZE{1'b0}};
                reg_instruction     <=  {BITS_SIZE{1'b0}};
                reg_zero            <=  1'b0;
                reg_alu             <=  {BITS_SIZE{1'b0}};        
                reg_register2       <=  {BITS_SIZE{1'b0}};
                reg_register_dst    <=  {BITS_REGS{1'b0}};
                reg_extension       <=  {BITS_SIZE{1'b0}};
                
                // M
                reg_branch          <=  1'b0;
                reg_new_branch      <=  1'b0;
                reg_mem_write       <=  1'b0;
                reg_mem_read        <=  1'b0;
                reg_size_filter     <=  2'b00;
        
                // WB
                reg_jal             <=  1'b0;            
                reg_mem_to_reg      <=  1'b0;
                reg_register_write  <=  1'b0;
                reg_size_filterL    <=  2'b00;
                reg_zero_extend     <=  1'b0;
                reg_lui             <=  1'b0;
                reg_halt            <=  1'b0;
            end
        else if (i_step)
            begin 
                reg_pc4             <=  i_pc4;
                reg_pc8             <=  i_pc8;
                reg_pc_branch       <=  i_pc_branch;
                reg_instruction     <=  i_idex_instruction;
                reg_zero            <=  i_flag_alu_zero;
                reg_alu             <=  i_alu_result;        
                reg_register2       <=  i_idex_register2;
                reg_register_dst    <=  i_register_dst;
                reg_extension       <=  i_idex_extension;
                
                // M
                reg_branch          <=  i_branch;
                reg_new_branch      <=  i_new_branch;
                reg_mem_write       <=  i_mem_write;
                reg_mem_read        <=  i_mem_read;
                reg_size_filter     <=  i_size_filter;
        
                // WB
                reg_jal             <=  i_jal;            
                reg_mem_to_reg      <=  i_mem_to_reg;
                reg_register_write  <=  i_reg_write;
                reg_size_filterL    <=  i_size_filterL;
                reg_zero_extend     <=  i_zero_extend;
                reg_lui             <=  i_lui;
                reg_halt            <=  i_halt;
            end

    assign o_pc4                =   reg_pc4;
    assign o_pc8                =   reg_pc8;
    assign o_pc_branch          =   reg_pc_branch;
    assign o_instruction        =   reg_instruction;
    assign o_zero               =   reg_zero;
    assign o_jal                =   reg_jal;
    assign o_alu                =   reg_alu;
    assign o_register_2         =   reg_register2;
    assign o_register_rd_dst    =   reg_register_dst;
    assign o_extension          =   reg_extension;
    
    // AssignM
    assign o_branch             =   reg_branch;
    assign o_new_branch         =   reg_new_branch;
    assign o_mem_write          =   reg_mem_write;
    assign o_mem_read           =   reg_mem_read;
    assign o_size_filter        =   reg_size_filter;
    
    // AssignWB
    assign o_mem_to_reg         =   reg_mem_to_reg;
    assign o_register_write     =   reg_register_write;
    assign o_size_filterL       =   reg_size_filterL;
    assign o_zero_extend        =   reg_zero_extend;
    assign o_lui                =   reg_lui;
    assign o_halt               =   reg_halt;     

endmodule
