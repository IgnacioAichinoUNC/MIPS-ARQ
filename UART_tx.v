`timescale 1ns / 1ps


module UART_tx
    #(
        parameter       CLK_FR     = 50000000,  //50Mhz
        parameter       BAUD_RATE  = 9600,     //Baudios
        parameter       SIZE_TRAMA = 8
    )
    (
        input                           i_clk, 
        input                           i_reset, 
        input                           i_tx_start,     //Flag de recepcion de datos i_data_trama
        input   [SIZE_TRAMA-1    :0]    i_data_trama,   // Datos a transmitir
        output                          o_tx_data, 
        output                          o_tx_done       //Flag de finalizacion de TX
    );
    
    //States
    localparam   IDLE                = 1'b0;
    localparam   SEND                = 1'b1; 
        
    localparam   SIZE_COUNTER_BIT    = $clog2(SIZE_TRAMA+2); //Size para el contador de bits de una trama
    localparam   TICK_COUNTER        = CLK_FR / BAUD_RATE;  //Calculo del contador para generar un tick
    localparam   SIZE_COUNTER        = $clog2(TICK_COUNTER+1); //size para el contador de TICKS
    
    reg [SIZE_COUNTER-1         :0]  reg_counter; //Count, have to divide the system clock frequency to get a frequency (div_sample) time higher than (baud_rate)  
    reg [SIZE_COUNTER_BIT-1     :0]  reg_counter_bit, reg_counter_bit_next; //Contador para saber si se enviaron 10 bits
    reg                              state, state_next;
    reg [SIZE_TRAMA+1            :0] reg_shift, reg_shift_next; 
    reg reg_tx_data, reg_tx_data_next;
    reg reg_tx_done, reg_tx_done_next;


    assign o_tx_data = reg_tx_data;
    assign o_tx_done = reg_tx_done;
    
    always @ (posedge i_clk, posedge i_reset) 
    begin 
        if (i_reset) begin
            state               <= IDLE;
            reg_counter         <= 0; 
            reg_counter_bit     <= 0;
            reg_tx_done         <= 1; 
            reg_tx_data         <= 1;
        end
        else begin
            reg_counter <= reg_counter + 1; 
            if (reg_counter >= TICK_COUNTER) begin //Cuando el reg_counter llego a un tick      
              reg_counter       <=  0;        
              state             <=  state_next;
              reg_shift         <=  reg_shift_next;
              reg_counter_bit   <=  reg_counter_bit_next;
              reg_tx_data       <=  reg_tx_data_next;
              reg_tx_done       <=  reg_tx_done_next;
           end
         end
    end 
       
    always @* 
    begin        
        reg_shift_next          <= reg_shift;
        reg_tx_data_next        <= reg_tx_data;
        reg_counter_bit_next    <= reg_counter_bit;
        reg_tx_done_next        <= reg_tx_done;
        case (state)
            IDLE:
            begin 
                if (i_tx_start) begin //Si es 1, llegaron datos y puedo comenzar
                   state_next       <= SEND;
                   reg_shift_next   <= {1'b1,i_data_trama,1'b0}; //Cargo 8 bits de datos con bit start y stop
                end 
                else begin // Si no hay dato espero
                   state_next           <= IDLE;
                   reg_tx_data_next     <= 1; 
                   reg_tx_done_next     <= 1;
                end
            end
            SEND:
            begin  
                if (reg_counter_bit >= 10) begin // Si se transmitieron 10 bits vuelve a IDLE, 8 bits data, bit start y stop
                    state_next               <= IDLE; 
                    reg_counter_bit_next     <= 0;
                end 
                else begin //Si la transmision no completo envia el siguiente bit
                    state_next              <=  SEND; //Envia de 1 bit, Y se queda en este estado enviando de 1
                    reg_tx_done_next        <=  0;
                    reg_tx_data_next        <=  reg_shift[0]; 
                    reg_shift_next          <=  reg_shift >> 1; //Mueve el registro en 1 bit
                    reg_counter_bit_next    <=  reg_counter_bit + 1;
                end
            end
            default: 
                state_next <= IDLE;                      
        endcase
    end

endmodule

