
`timescale 1ns / 1ps

module tb_top();

    localparam BITS_SIZE            = 32;
    localparam SIZE_TRAMA           = 8;
    localparam SIZE_MEM_INSTRUC     = 256;
    localparam CLK_FREQ             = 50000000;
    localparam BAUD_RATE            = 9600;
        
    localparam  MEM_INSTR_SIZE = $clog2(SIZE_MEM_INSTRUC);
    
    reg                                 i_clk;
    reg                                 i_reset;
    wire                                o_uart_tx;
    wire        [3:0]                   o_debug_state;
    reg     [BITS_SIZE-1:0]             clk_wiz_count;  //contador de ciclos a enviar
    wire                                clk_wz;
    wire    [BITS_SIZE-1:0]             pc;

    wire    [MEM_INSTR_SIZE-1:0]        select_mem_ins_dir;    //lo mandamos pero no lo mostramos en pantalla
    wire    [BITS_SIZE-1:0]             dato_mem_ins;
    wire                                write_mem_ins;   //cuando recibi el dato(rx) se pone a 1 para escribir mem instruc
    wire                                uart_tx_start;
    wire    [SIZE_TRAMA-1:0]            uart_tx_data;
    wire                                uart_tx_done;
    wire                                ctl_clk_wiz;  //segun el modo o si esta en stop, el clock se incrementa o no (1 o 0)
    wire                                uart_rx_reset;

    reg    [SIZE_TRAMA-1:0]             uart_rx_data;
    reg                                 uart_rx_data_ready;

    
   clk_wiz_0 clk_wiz
   (
    .clk_out1(clk_wz),     // output clk_out50MHz
    .reset(i_reset), // input reset
    .locked(locked),       // output locked
    .clk_in1(i_clk)
    ); 
    
    
     TOP_MIPS #(
        .BITS_SIZE          (BITS_SIZE),
        .SIZE_MEM_INSTRUC   (SIZE_MEM_INSTRUC)
    )
    u_MIPS
    (
        .i_clk                          (clk_wz),
        .i_reset                        (i_reset),
        .i_ctl_clk_wiz                  (ctl_clk_wiz),
        .i_select_address_mem_instr     (select_mem_ins_dir),
        .i_dato_mem_ins                 (dato_mem_ins),
        .i_flag_write_mem_ins           (write_mem_ins),
        .o_pc                           (pc)
    );


    UART_tx #(
        .CLK_FR         (CLK_FREQ),
        .BAUD_RATE      (BAUD_RATE),
        .SIZE_TRAMA     (SIZE_TRAMA)
    )
    u_tx (
        .i_clk                  (clk_wz),
        .i_reset                (i_reset),
        .i_tx_start             (uart_tx_start),
        .i_data_trama           (uart_tx_data),
        .o_tx_data              (o_uart_tx),
        .o_tx_done              (uart_tx_done)
    );

    UnitDebug #(
        .SIZE_TRAMA     (SIZE_TRAMA),
        .SIZE_INSTRUC   (BITS_SIZE)
    )
    u_Debug
    (
        .i_clk                  (clk_wz),
        .i_reset                (i_reset),
        .i_uart_rx_flag_ready   (uart_rx_data_ready),
        .i_uart_rx_data         (uart_rx_data),
        .i_uart_tx_done         (uart_tx_done),
        .i_clk_wiz_count        (clk_wiz_count),
        .o_uart_rx_reset        (uart_rx_reset),
        .o_ctl_clk_wiz          (ctl_clk_wiz),
        .o_select_mem_ins_dir   (select_mem_ins_dir),
        .o_dato_mem_ins         (dato_mem_ins),
        .o_flag_instr_write     (write_mem_ins),
        .o_debug_state          (o_debug_state)
     );
    
    
    initial begin

      i_clk = 1'b0; 
      uart_rx_data_ready=1'b0;
      i_reset=1'b1;
      #20
      i_reset=1'b0;
      #30
      uart_rx_data=8'b01100100;  //mando una d para que debug vaya al estado init
      uart_rx_data_ready=1'b1;
      #1110
      uart_rx_data_ready=1'b0;
      #20
      uart_rx_data_ready=1'b1;
      uart_rx_data=8'b00000000;
      #60
      uart_rx_data_ready=1'b0;
      #20
      uart_rx_data_ready=1'b1;
      uart_rx_data=8'b00000000;
      #60
      uart_rx_data_ready=1'b0;
      #20
      uart_rx_data_ready=1'b1;
      uart_rx_data=8'b00000000;
      #60
      uart_rx_data_ready=1'b0;
      #20
      uart_rx_data_ready=1'b1;
      uart_rx_data=8'b00000000;
      #60
      uart_rx_data_ready=1'b0;

    //ADD:  000000  |   RS      |   RT  |   RD  |   00000   |   100000
    //      000000     00001      00011   00000     00000       100000
  
      #20
      uart_rx_data_ready=1'b1;
      uart_rx_data=8'b00000000;
      #60
      uart_rx_data_ready=1'b0;    
      #20
      uart_rx_data_ready=1'b1;
      uart_rx_data=8'b00100011;
      #60
      uart_rx_data_ready=1'b0;
      #20
      uart_rx_data=8'b00000000;
      uart_rx_data_ready=1'b1;
      #60
      uart_rx_data_ready=1'b0;
      #20
      uart_rx_data_ready=1'b1;
      uart_rx_data=8'b00100000;
      #100
      uart_rx_data_ready=1'b0;
      
   //      OPCODE      RS          RT      RD      SHAMT       FUNCT
   // sub  000000     00000      00010   00001     00000       100010   
      #20
      uart_rx_data_ready=1'b1;
      uart_rx_data=8'b00000000;
      #60
      uart_rx_data_ready=1'b0;    
      #20
      uart_rx_data_ready=1'b1;
      uart_rx_data=8'b00000010;
      #60
      uart_rx_data_ready=1'b0;
      #20
      uart_rx_data=8'b00001000;
      uart_rx_data_ready=1'b1;
      #60
      uart_rx_data_ready=1'b0;
      #20
      uart_rx_data_ready=1'b1;
      uart_rx_data=8'b00100010;
      #100
      uart_rx_data_ready=1'b0;
     
       
      $finish();
    end

    always #10 i_clk = ~i_clk;
    
endmodule