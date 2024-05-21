`timescale 1ns / 1ps

module UART_rx
    #(
        parameter       CLK_FR       = 50000000,  
        parameter       BAUD_RATE    = 9600, 
        parameter       TICK_BAUD    = 16, 
        parameter       SIZE_TRAMA   = 8 
    )
    (
        input   wire                        i_clk,
        input   wire                        i_reset,
        input   wire                        i_rx_bit,
        output  wire                        o_rx_done,
        output  wire   [SIZE_TRAMA-1    :0] o_data
    );
    
    //Estados
    localparam     IDLE                = 1'b0;
    localparam     RECIVE              = 1'b1;
   
    localparam     SIZE_COUNTER_BIT    = $clog2(SIZE_TRAMA+1); //Size para el contador de bits de una trama
    localparam     TICK_COUNTER        = CLK_FR/(BAUD_RATE*TICK_BAUD);  //Calculo del contador para generar un tick
    localparam     TICK_SAMPLE         = (TICK_BAUD/2)-1;  //medio de un bit en el que desea  tomar la muestra
    localparam     SIZE_COUNTER        = $clog2(TICK_COUNTER+1)+1; //size para el contador de TICKS
    localparam     SIZE_COUNTER_SAMPLE = $clog2(TICK_BAUD+1);   //Size para el contador de medio bit
    
    
    reg [SIZE_TRAMA-1    :0]        reg_shift, reg_shift_next;   
    reg                             state, state_next;
    reg                             reg_data_done, reg_data_done_next;    
    reg [SIZE_COUNTER_BIT-1     :0] reg_counter_bit, reg_counter_bit_next; // Contador para saber si tengo los 8 bits
    reg [SIZE_COUNTER_SAMPLE-1  :0] reg_counter_sample, reg_counter_sample_next; // Contador de muestras de 2 bits para contar hasta 4 para oversampling
    reg [SIZE_COUNTER+1         :0] reg_counter; //Contador de la tasa de baudios

    
    assign o_data       = reg_shift [SIZE_TRAMA-1:0]; 
    assign o_rx_done    = reg_data_done;
    
    always @ (posedge i_clk, posedge i_reset)
        begin 
            if (i_reset)begin       
                reg_counter             <= 0; 
                state                   <= IDLE; 
                reg_counter_bit         <= 0; 
                reg_counter_sample      <= 0; 
                reg_shift               <= 0;
                reg_data_done           <= 0;
            end 
            else begin 
                reg_counter <= reg_counter +1;
                if (reg_counter >= TICK_COUNTER-1) begin //Cuando el reg_counter llego a un tick
                    reg_counter         <= 0; 
                    state               <= state_next; 
                    reg_counter_bit     <= reg_counter_bit_next;
                    reg_data_done       <= reg_data_done_next;
                    reg_counter_sample  <= reg_counter_sample_next;
                    reg_shift           <= reg_shift_next;                    
                end
            end
        end
       
    always @* 
    begin 
        state_next                  <=  state;
        reg_counter_sample_next     <=  reg_counter_sample;
        reg_counter_bit_next        <=  reg_counter_bit;
        reg_data_done_next          <=  reg_data_done;
        reg_shift_next              <=  reg_shift;
        case (state)
            IDLE:
             begin 
                if (~i_rx_bit) begin //Bit de start=0 Se puede comenzar a recibir
                    state_next                  <= RECIVE; 
                    reg_counter_bit_next        <= 0;
                    reg_counter_sample_next     <= 0;
                    reg_data_done_next          <= 0;
                end
            end
            RECIVE: 
            begin
                if (reg_counter_sample == TICK_SAMPLE) begin   
                    reg_shift_next      <=  {i_rx_bit,reg_shift[SIZE_TRAMA-1:1]}; //Voy concatenando los bits que recibo en mi shift register
                end            
                if (reg_counter_sample == TICK_BAUD - 1) begin
                    if (reg_counter_bit == SIZE_TRAMA) begin //Recibi el byte completo
                        state_next              <= IDLE; 
                        reg_data_done_next      <= 1;
                    end 
                                       
                    reg_counter_bit_next     <= reg_counter_bit + 1; 
                    reg_counter_sample_next  <= 0; //Reinicia el contador de muestreo
                end 
                else begin 
                    reg_counter_sample_next  <= reg_counter_sample + 1;          
                end
            end
           default: 
                state_next <= IDLE;
         endcase
    end         
endmodule