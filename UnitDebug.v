`timescale 1ns / 1ps



module UnitDebug
    #(
        parameter       MEM_INST_TOTAL_SIZE         = 256,
        parameter       MEM_INST_SIZE_BITS          = 8,
        parameter       SIZE_TRAMA                  = 8,  
        parameter       SIZE_INSTRUC                = 32
    )
    (
        input                                       i_clk,
        input                                       i_reset,
        input                                       i_uart_rx_flag_ready,  //o_rx_done  FROM UART.V  Tengo un flag para indicar que tengo datos de la recepcion
        input           [SIZE_TRAMA-1:0]            i_uart_rx_data,        // o_rx_data  Dato de 8 bits receptado. 
        input                                       i_uart_tx_done,        // o_tx_done Flag para indicar que termino la transmicion
        input           [SIZE_INSTRUC-1 :0]         i_clk_wiz_count,   
        
        
        output                                      o_uart_rx_reset,   // ESTE PARA RESET RX? CANCELA LA RECEPCION? DONDE LO USA EN EL TOP
        output                                      o_ctl_clk_wiz,
        output          [MEM_INST_SIZE_BITS-1:0]    o_select_mem_ins_dir,  //Este output tiene la posicion de memoria donde escribir la instruccion
        output          [SIZE_INSTRUC-1:0]          o_dato_mem_ins,
        output                                      o_flag_instr_write,
        output          [3:0]                       o_debug_state
    );

    localparam IDLE                 =   4'b0000; //Estado inicial
   
    localparam CONTINUO       =   4'b0010; //'c' Mode continuo MIPS
    localparam STEP           =   4'b0001; //'s' modo step by step MIPS
   
    localparam ENABLE_LOAD_INSTR    =   4'b0011; //'d' estado donde se habilita la escritura de la instruc, porque ya se armaron los 32 bits
    localparam SEND_DATA_TX         =   4'b0100; //  envio 8 btis
    localparam WAIT_TX              =   4'b0110; // si en contador es 0 pasa a data_init sino voy al estado para cargar otro dato, deplazo de a 8 para de los 32 solo enviar los 8 que quiero
      
    localparam PREPARE_INSTRUCT     =   4'b1000; //ARMO instruccion de 32 bits
    localparam WAIT_DATA_INSTR      =   4'b1001; //Espero hatl o vuelvo a data init
   
 
    localparam   SIZE_COUNTER_DIR = $clog2(MEM_INST_TOTAL_SIZE);
    
   
    reg                                                reg_ctl_clk_wiz;
    reg               [4:0]                            state, state_next;
    reg               [3:0]                            debug_state, debug_state_next; //Satate para debuggear en tb
    reg                                                reg_uart_rx_reset, reg_uart_rx_reset_next;
    reg               [SIZE_INSTRUC-1:0]               reg_instruccion, reg_instruccion_next;
    reg                                                reg_rx_instr_write, reg_rx_instr_write_next;
    reg               [SIZE_COUNTER_DIR-1:0]           reg_counter_dir_mem_instr=0, reg_counter_dir_mem_instr_next=0;  //Contador para direccionar las ubicaciones de memoria de instr disponible
    reg               [1:0]                            reg_rx_counter_bytes=0, reg_rx_counter_bytes_next=0;
    reg               [1:0]                            mode, mode_next;
    

    always @ (posedge i_clk)
        begin
            if (i_reset)begin
                state                       <= IDLE;
                reg_uart_rx_reset           <= 1;
                reg_instruccion             <= 0;
                reg_rx_counter_bytes        <= 0;
                reg_counter_dir_mem_instr   <= 0;
                reg_rx_instr_write          <= 0;
                debug_state                 <= 0;
                mode                        <= 2'b00;    
            end 
            else begin
                mode                        <= mode_next;
                debug_state                 <= debug_state_next;
                state                       <= state_next;
                reg_uart_rx_reset           <= reg_uart_rx_reset_next;
                reg_instruccion             <= reg_instruccion_next;
                reg_rx_counter_bytes        <= reg_rx_counter_bytes_next;
                reg_counter_dir_mem_instr   <= reg_counter_dir_mem_instr_next;
                reg_rx_instr_write          <= reg_rx_instr_write_next;
                
            end
        end

    always @*
        begin
            state_next                      <= state;
            debug_state_next                <= debug_state;
            reg_uart_rx_reset_next          <= reg_uart_rx_reset;
            reg_instruccion_next            <= reg_instruccion;
            reg_rx_counter_bytes_next       <= reg_rx_counter_bytes;
            reg_counter_dir_mem_instr_next  <= reg_counter_dir_mem_instr;
            reg_rx_instr_write_next         <= reg_rx_instr_write;
            

        case (state)
            IDLE:   //ESTADO INICIAL
            begin
                debug_state_next <= 1;
                if (~i_uart_rx_flag_ready) begin  //Check de si se tiene datos disponbibles desde RX UART
                    reg_uart_rx_reset_next  <= 0;
                end 
                else begin //Check que se recibe como char para pasar a el estado correspondiente
                    reg_uart_rx_reset_next  <= 1;

                    case(i_uart_rx_data)// DATO RECIBIDO DE 8 BITS
                        8'b01100011:    state_next          <= CONTINUO; //espero una c 
                        8'b01110011:    state_next          <= STEP;    //espero una s
                        8'b01100100:    state_next          <= ENABLE_LOAD_INSTR; //Recibi "d" desde PY para indicar la carga de instrucciones.
                        default:        state_next          <= IDLE; 
                    endcase
                end
            end
            
            ENABLE_LOAD_INSTR: //Puedo cargar instrucciones
            begin
                debug_state_next <= 3;
                if (~i_uart_rx_flag_ready) begin  //Check de si se tiene datos disponbibles desde RX UART
                    reg_uart_rx_reset_next      <= 0;
                end 
                else begin 
                    reg_uart_rx_reset_next      <= 1;
                    reg_instruccion_next        <= {reg_instruccion [23:0], i_uart_rx_data}; //Ubica los 8 bits recibidos en los mas altos
                    reg_rx_counter_bytes_next   <= reg_rx_counter_bytes + 1;
                    state_next                  <= PREPARE_INSTRUCT;
                end
            end

            PREPARE_INSTRUCT: //Verifico el counter de bytes, si llega a 4 porque tengo los 32 bits de la instruccion y habilito la esritura sino sigo concatenando los 8 bits por RX
            begin
                debug_state_next <= 4; //solo indico que en estado estoy

                if(reg_rx_counter_bytes == 0) begin //Desborde de counter bytes
                    reg_rx_instr_write_next  <= 1; //Habilito la escritura en el reg de instrucciones
                    state_next               <= WAIT_DATA_INSTR;
                end 
                else begin
                    state_next              <= ENABLE_LOAD_INSTR;  //Sigo esperando completar los 32 bits
                end
            end

            WAIT_DATA_INSTR: //Verifico si la instruccion fue HALT para terminar la carga, sino sigo cargando
            begin
                debug_state_next                      <= 5;
                reg_rx_instr_write_next               <= 0;
                if(reg_instruccion == 32'b11111111111111111111111111111111) begin //HALT
                    reg_counter_dir_mem_instr_next    <= 0;
                    state_next                        <= IDLE;
                end 
                else begin
                    reg_counter_dir_mem_instr_next   <= reg_counter_dir_mem_instr + 4; //Aumenta en 4 para la siguiente direccion de memoria donde colocar la instruccion
                    state_next                       <= ENABLE_LOAD_INSTR;
                end
            end
            default:
                state_next <= IDLE; //default idle
        endcase
        end

    always @*
    begin
        case(mode)
            //Tenedriamos que definir mode continuo y step para modificar el paso del clock
            default:                reg_ctl_clk_wiz <= 1'b0;
        endcase
    end

    assign o_debug_state        = debug_state;
    assign o_uart_rx_reset      = reg_uart_rx_reset;
    assign o_ctl_clk_wiz        = reg_ctl_clk_wiz;
    assign o_flag_instr_write   = reg_rx_instr_write;
    assign o_select_mem_ins_dir = reg_counter_dir_mem_instr;   //Ubicacion en memoria de intrucciones
    assign o_dato_mem_ins       = reg_instruccion;             //Intruccion a escribir.
        
        
endmodule