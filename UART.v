`timescale 1ns / 1ps

module UART
    #(
        parameter SIZE_TRAMA        = 8,
        parameter BAUD_RATE         = 9600,
        parameter CLK_FR            = 50000000,
        parameter RX_TICK_BAUD      = 16 //16 veces la tasa de baudio,una frecuencia de muestreo más alta que la tasa de baudios para recuperar los datos
    )
    (
        input   wire                            i_clk,
        input   wire                            i_reset,
        input   wire                            i_rx_reset,
        input   wire                            i_tx_start,
        input   wire    [SIZE_TRAMA-1:    0]    i_tx_data,
        input   wire                            i_uart_rx,
        output  wire                            o_uart_tx,
        output  wire                            o_rx_done,
        output  wire                            o_tx_done,
        output  wire    [SIZE_TRAMA-1:    0]    o_rx_data
    );

    UART_tx #(
        .CLK_FR     (CLK_FR),
        .BAUD_RATE  (BAUD_RATE),
        .SIZE_TRAMA (SIZE_TRAMA)
    )
    tx (
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_tx_start     (i_tx_start),
        .i_data_trama   (i_tx_data),
        .o_tx_data      (o_uart_tx),
        .o_tx_done      (o_tx_done)
    );

    UART_rx #(
        .CLK_FR     (CLK_FR),
        .BAUD_RATE  (BAUD_RATE),
        .TICK_BAUD  (RX_TICK_BAUD),
        .SIZE_TRAMA (SIZE_TRAMA)
    )
    rx
    (
        .i_clk          (i_clk),
        .i_reset        (i_rx_reset),
        .i_rx_bit       (i_uart_rx),
        .o_rx_done      (o_rx_done),
        .o_data         (o_rx_data)
    ); 
    
endmodule