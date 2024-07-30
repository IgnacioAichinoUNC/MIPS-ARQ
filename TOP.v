`timescale 1ns / 1ps

module TOP
    #(
        parameter BITS_SIZE             = 32,
        parameter SIZE_MEM_INSTRUC      = 256,
        parameter SIZE_INSTRUC_DEBUG    = 8,
        parameter SIZE_TRAMA            = 8,
        parameter BAUD_RATE             = 9600,
        parameter CLK_FREQ              = 50000000,
        parameter RX_TICK_BAUD          = 16 //16 veces la tasa de baudio,una frecuencia de muestreo más alta que la tasa de baudios para recuperar los datos

    )  
    (
        input   wire                i_clk,
        input   wire                i_reset,
        input   wire                i_uart_rx,
        output  wire                o_uart_tx,
        output  wire        [3:0]   o_debug_state  //conozco el estado en el que esta el debug
    );

        localparam  MEM_INSTR_SIZE      = $clog2(SIZE_MEM_INSTRUC);
        localparam  MEM_REGISTERS_SIZE  = $clog2(BITS_SIZE);


        wire    [BITS_SIZE-1:0]         select_mem_dir;
        wire    [MEM_INSTR_SIZE-1:0]    select_mem_ins_dir;  //Sirve para contar cada posicion de la memoria de instrucciones. Es decir cada posicion donde se va alojar una instr
        wire    [MEM_REGISTERS_SIZE-1:0]     select_reg_dir; //se incrementa en 1 para que mips manda a la salida el valor de ese reg_file
        
        wire                            i_ctl_clk_wiz;  //segun el modo o si esta en stop,(1,0) con 1 se incrementa el clock, es control
        wire    [BITS_SIZE-1:0]         dato_mem_ins;
        wire                            flag_write_mem_instr;   //cuando recibi el dato(rx) se pone a 1 para escribir mem instruc
        wire    [BITS_SIZE-1:0]         pc;
        wire    [BITS_SIZE-1:0]         data_mem;
        wire                            halt;


        wire                            uart_rx_reset;
        wire                            uart_rx_done;
        wire    [SIZE_TRAMA-1:0]        uart_rx_data;

        wire                            uart_tx_start;
        wire    [SIZE_TRAMA-1:0]        uart_tx_data;
        wire                            uart_tx_done;


        //Clock
        reg     [BITS_SIZE-1:0]         reg_clk_wiz_count;  //contador de ciclos a enviar
        wire                            wire_clk_wz;

    clk_wiz_0 clk_wiz
   (
    .clk_out1(wire_clk_wz),      // output clk_out50MHz
    .reset(i_reset),        // input reset
    .locked(locked),        // output locked
    .clk_in1(i_clk)
    ); 


    TOP_MIPS #(
        .BITS_SIZE          (BITS_SIZE),
        .SIZE_MEM_INSTRUC       (SIZE_MEM_INSTRUC),
        .SIZE_INSTRUC_DEBUG (SIZE_INSTRUC_DEBUG)
    )
    module_TOP_MIPS
    (
        .i_clk                          (wire_clk_wz),
        .i_reset                        (i_reset),
        .i_ctl_clk_wiz                  (i_ctl_clk_wiz),
        .i_select_address_mem_instr     (select_mem_ins_dir),
        .i_select_address_register      (select_register_dir),
        .i_dato_mem_ins                 (dato_mem_ins),
        .i_flag_write_mem_ins           (flag_write_mem_instr),
        .o_pc                           (pc)
    );


    UART #(
        .BAUD_RATE      (BAUD_RATE),
        .CLK_FR         (CLK_FREQ),
        .RX_TICK_BAUD   (RX_TICK_BAUD)        
    )
    module_UART(
        .i_clk                  (wire_clk_wz),
        .i_reset                (i_reset),
        .i_rx_reset             (uart_rx_reset),
        .i_tx_start             (uart_tx_start),
        .i_tx_data              (uart_tx_data),
        .i_uart_rx              (i_uart_rx),  //Recibo por RX dato from PC
        .o_uart_tx              (o_uart_tx),  //Salida para PC  
        .o_rx_done              (uart_rx_done),
        .o_tx_done              (uart_tx_done), 
        .o_rx_data              (uart_rx_data)
    );

    UnitDebug #(
        .SIZE_TRAMA     (SIZE_INSTRUC_DEBUG),
        .SIZE_INSTRUC   (BITS_SIZE)
    )
    module_Debug
    (
        .i_clk                  (wire_clk_wz),
        .i_reset                (i_reset),
        .i_halt                 (halt),
        .i_uart_rx_flag_ready   (uart_rx_done),
        .i_uart_rx_data         (uart_rx_data),
        .i_uart_tx_done         (uart_tx_done),
        .i_clk_wiz_count        (clk_wiz_count),
        .o_uart_rx_reset        (uart_rx_reset),
        .o_ctl_clk_wiz          (o_ctl_clk_wiz),
        .o_select_mem_ins_dir   (select_mem_ins_dir),
        .o_select_register_dir  (select_register_dir),
        .o_dato_mem_ins         (dato_mem_ins),
        .o_flag_instr_write     (flag_write_mem_instr),
        .o_debug_state          (o_debug_state)
     );

    always @(posedge wire_clk_wz)
        begin
            if(i_reset) begin
                reg_clk_wiz_count = 0;
            end else if (o_ctl_clk_wiz) begin
                reg_clk_wiz_count = reg_clk_wiz_count + 1;
            end
        end

endmodule