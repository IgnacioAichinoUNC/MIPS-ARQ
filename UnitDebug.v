`timescale 1ns / 1ps



module UnitDebug
    #(
        parameter       MEM_INST_TOTAL_SIZE         = 256,
        parameter       MEM_DATA_SIZE               = 16,
        parameter       MEM_INST_SIZE_BITS          = 8,
        parameter       SIZE_TRAMA                  = 8,  
        parameter       MEM_REGISTER_SIZE           = 32,
        parameter       BITS_REGS                   = 5,
        parameter       BITS_SIZE                   = 32
        
    )
    (
        input                                       i_clk,
        input                                       i_reset,
        input                                       i_uart_rx_flag_ready,  //o_rx_done  FROM UART.V  Tengo un flag para indicar que tengo datos de la recepcion
        input           [SIZE_TRAMA-1:0]            i_uart_rx_data,        // o_rx_data  Dato de 8 bits receptado. 
        input                                       i_uart_tx_done,        // o_tx_done Flag para indicar que termino la transmicion
        
        input           [BITS_SIZE-1 :0]            i_clk_wiz_count,   
        input                                       i_halt,
        input           [BITS_SIZE-1:0]             i_mips_pc,
        input           [BITS_SIZE-1:0]             i_data_reg_file,
        input           [BITS_SIZE-1:0]             i_data_mem,


        
        output                                      o_uart_rx_reset,   // ESTE PARA RESET RX? CANCELA LA RECEPCION? DONDE LO USA EN EL TOP
        output                                      o_ctl_clk_wiz,
        output          [MEM_INST_SIZE_BITS-1:0]    o_select_mem_ins_dir,  //Este output tiene la posicion de memoria donde escribir la instruccion
        output          [BITS_SIZE-1:0]             o_dato_mem_ins,
        output                                      o_flag_instr_write,
        output          [3:0]                       o_debug_state,
        output          [BITS_REGS-1:0]             o_select_register_dir,
        output                                      o_flag_tx_ready,
        output          [SIZE_TRAMA-1:0]            o_uart_tx_data,
        output          [BITS_SIZE-1:0]             o_select_mem_dir

    );

    localparam IDLE                 =   4'b0000; //Estado inicial
    localparam CONTINUO             =   4'b0010; //'c' Mode continuo MIPS
    localparam STEP                 =   4'b0001; //'s' modo step by step MIPS
   
    localparam DATA_RX_LOAD         =   4'b0011; //'d' estado donde se habilita la escritura de la instruc, porque ya se armaron los 32 bits
    localparam SEND_DATA_TX         =   4'b0100; //  envio 8 btis
    localparam WAIT_TX              =   4'b0110; // si en contador es 0 pasa a DATA_RX_LOAD sino voy al estado para cargar otro dato, deplazo de a 8 para de los 32 solo enviar los 8 que quiero
    localparam LOAD_DATA_TX         =   4'b0111; //segun el contador se carga la data para enviar (pc, registros y ciclos)  
    localparam PREPARE_INSTRUCT     =   4'b1000; //ARMO instruccion de 32 bits
    localparam DATA_INSTR           =   4'b1001; //Espero hatl o vuelvo a data init
   
    localparam MGMT_CONTINUO        =   2'b01;
    localparam MGMT_STOP            =   2'b00;  //Control del clock y el step by step flag    
    localparam MGMT_STEP            =   2'b11;

    localparam   SIZE_COUNTER_DIR   = $clog2(MEM_INST_TOTAL_SIZE);
    localparam   REG_COUNTER_SIZE   = $clog2(MEM_REGISTER_SIZE);
    localparam   MEM_COUNTER_SIZE   = $clog2(MEM_DATA_SIZE);

    reg                                                reg_ctl_clk_wiz;
    reg               [4:0]                            state, state_next;
    reg               [3:0]                            debug_state, debug_state_next; //Satate para debuggear en tb
    reg                                                reg_uart_rx_reset, reg_uart_rx_reset_next;
    reg               [BITS_SIZE-1:0]                  reg_instruccion, reg_instruccion_next;
    reg                                                reg_rx_instr_write, reg_rx_instr_write_next;
    reg               [SIZE_COUNTER_DIR-1:0]           reg_counter_dir_mem_instr=0, reg_counter_dir_mem_instr_next=0;  //Contador para direccionar las ubicaciones de memoria de instr disponible
    reg               [1:0]                            reg_rx_counter_bytes=0, reg_rx_counter_bytes_next=0;
    reg               [1:0]                            mode, mode_next;
    reg                                                mips_step, mips_step_next;
    reg               [1:0]                            reg_tx_counter_bytes=0, reg_tx_counter_bytes_next=0;
    reg               [2:0]                            reg_tx_selector_data, reg_tx_selector_data_next;
    reg               [REG_COUNTER_SIZE-1:0]           reg_tx_register_counter, reg_tx_register_counter_next;
    reg                                                reg_flag_tx_ready, reg_flag_tx_ready_next;
    reg               [SIZE_TRAMA-1:0]                 uart_tx_data, uart_tx_data_next;
    reg               [BITS_SIZE-1:0]                  tx_data_32, tx_data_32_next;
    reg               [MEM_COUNTER_SIZE-1:0]           reg_tx_counter_mem, reg_tx_counter_mem_next;




    

    always @ (posedge i_clk)
        begin
            if (i_reset)begin
                state                       <= IDLE;
                reg_uart_rx_reset           <= 1;
                reg_instruccion             <= 0;
                reg_rx_counter_bytes        <= 0;
                reg_counter_dir_mem_instr   <= 0;
                reg_rx_instr_write          <= 0;
                reg_tx_counter_bytes        <= 0;
                reg_tx_selector_data        <= 0;
                reg_tx_register_counter     <= 0;
                uart_tx_data                <= 0;
                tx_data_32                  <= 0;
                reg_flag_tx_ready           <= 0;
                reg_tx_counter_mem          <= 0;
                mips_step                   <= 0;
                debug_state                 <= 0;
                mode                        <= MGMT_STOP;    
            end 
            else begin
                mode                        <= mode_next;
                debug_state                 <= debug_state_next;
                state                       <= state_next;
                mips_step                   <= mips_step_next;
                reg_uart_rx_reset           <= reg_uart_rx_reset_next;
                reg_instruccion             <= reg_instruccion_next;
                reg_rx_counter_bytes        <= reg_rx_counter_bytes_next;
                reg_tx_counter_bytes        <= reg_tx_counter_bytes_next;
                reg_tx_selector_data        <= reg_tx_selector_data_next;
                reg_tx_register_counter     <= reg_tx_register_counter_next;
                uart_tx_data                <= uart_tx_data_next;
                tx_data_32                  <= tx_data_32_next;
                reg_flag_tx_ready           <= reg_flag_tx_ready_next;
                reg_tx_counter_mem          <= reg_tx_counter_mem_next;
                reg_counter_dir_mem_instr   <= reg_counter_dir_mem_instr_next;
                reg_rx_instr_write          <= reg_rx_instr_write_next;
                
            end
        end

    always @*
        begin
            state_next                      <= state;
            mode_next                       <= mode;
            debug_state_next                <= debug_state;
            mips_step_next                  <= mips_step;
            reg_uart_rx_reset_next          <= reg_uart_rx_reset;
            reg_instruccion_next            <= reg_instruccion;
            reg_rx_counter_bytes_next       <= reg_rx_counter_bytes;
            reg_tx_counter_bytes_next       <= reg_tx_counter_bytes;
            reg_tx_selector_data_next       <= reg_tx_selector_data;
            reg_tx_register_counter_next    <= reg_tx_register_counter;
            uart_tx_data_next               <= uart_tx_data;
            tx_data_32_next                 <= tx_data_32;
            reg_flag_tx_ready_next          <= reg_flag_tx_ready;
            reg_tx_counter_mem_next         <= reg_tx_counter_mem;            
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
                        8'b01100100:    state_next          <= DATA_RX_LOAD; //Recibi "d" desde PY para indicar la carga de instrucciones.
                        default:        state_next          <= IDLE; 
                    endcase
                end
            end

            CONTINUO: //Se recibe una "c"
            begin
                mode_next  <= MGMT_CONTINUO;
                if(i_halt) begin                   //Se ejecuta un halt como instruccion por lo que finaliza el modo y clk_wiz
                    mode_next  <= MGMT_STOP;
                    state_next <= LOAD_DATA_TX;
                end
            end

            STEP:
            begin
                debug_state_next <= 2;
                mode_next       <= MGMT_STEP;
                if(i_halt) begin                 //Se ejecuta un halt como instruccion por lo que finaliza el modo y clk_wiz
                    mode_next  <= MGMT_STOP;
                    state_next <= LOAD_DATA_TX;
                end
                if(mips_step) begin             //Se avanza en instrucciones y envio info por TX
                    mips_step_next <= 0;
                    state_next     <= LOAD_DATA_TX;
                end 
                else begin
                    if (~i_uart_rx_flag_ready) begin// Verifica si recibo un dato de avanzar step por UART RX
                        reg_uart_rx_reset_next  <= 0;
                    end 
                    else begin // Verifica si el char recibido es "N" (next)
                        reg_uart_rx_reset_next  <= 1;
                        if( i_uart_rx_data == 8'b01101110) begin 
                            mips_step_next <= 1;
                        end
                    end
                end
            end
            
            DATA_RX_LOAD: //Puedo cargar instrucciones
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
                    state_next               <= DATA_INSTR;
                end 
                else begin
                    state_next              <= DATA_RX_LOAD;  //Sigo esperando completar los 32 bits
                end
            end

            DATA_INSTR: //Verifico si la instruccion fue HALT para terminar la carga, sino sigo cargando
            begin
                debug_state_next                      <= 5;
                reg_rx_instr_write_next               <= 0;
                if(reg_instruccion == 32'b11111111111111111111111111111111) begin //HALT
                    reg_counter_dir_mem_instr_next    <= 0;
                    state_next                        <= IDLE;
                end 
                else begin
                    reg_counter_dir_mem_instr_next   <= reg_counter_dir_mem_instr + 4; //Aumenta en 4 para la siguiente direccion de memoria donde colocar la instruccion
                    state_next                       <= DATA_RX_LOAD;
                end
            end

            WAIT_TX:
            begin
                debug_state_next <= 8;
                if(i_uart_tx_done) begin    //Se completo la transmicion en UART Tx
                    if(reg_tx_counter_bytes == 0) begin  //Desborda el contador tx
                        state_next <= LOAD_DATA_TX;
                    end 
                    else  begin
                        tx_data_32_next        <= tx_data_32 << 8;
                        state_next             <= SEND_DATA_TX;
                    end
                end
            end

            LOAD_DATA_TX:
            begin
                debug_state_next <= 6;
                case(reg_tx_selector_data)
                    0: //Send PC MIPS
                    begin
                        tx_data_32_next           <= i_mips_pc;
                        reg_tx_selector_data_next <= reg_tx_selector_data + 1;
                        state_next                <= SEND_DATA_TX;
                    end

                    1: // se envia numero de ciclos realizados en total desde el inicio
                    begin
                        tx_data_32_next           <= i_clk_wiz_count;
                        reg_tx_selector_data_next <= reg_tx_selector_data + 1;
                        state_next                <= SEND_DATA_TX;
                    end

                    2: // envio data de los 32 registros
                    begin
                        tx_data_32_next                 <= i_data_reg_file;
                        reg_tx_register_counter_next    <= reg_tx_register_counter + 1;

                        if(reg_tx_register_counter == MEM_REGISTER_SIZE-1) begin
                            reg_tx_selector_data_next <= reg_tx_selector_data + 1;
                        end
                        state_next  <= SEND_DATA_TX;
                    end

                    3: //Envio el contenido del reg de data memory
                    begin
                        tx_data_32_next        <= i_data_mem;
                        reg_tx_counter_mem_next <= reg_tx_counter_mem + 1;

                        if(reg_tx_counter_mem == MEM_COUNTER_SIZE-1) begin
                            reg_tx_selector_data_next <= reg_tx_selector_data + 1;
                        end
                        state_next  <= SEND_DATA_TX;
                    end

                    4: // cuando termino de envitar toda la data y se vuelve a IDLE o STEP
                    begin
                        reg_tx_selector_data_next  <= 0;

                        if(mode  == MGMT_STEP) begin
                            state_next           <= STEP;
                        end else begin
                            state_next           <= IDLE;
                        end
                    end
                    
                    default:
                    begin
                        reg_tx_selector_data_next   <= 0;
                        state_next                  <= IDLE;
                    end
                endcase
            end

            SEND_DATA_TX:
            begin
                debug_state_next <= 7;
                uart_tx_data_next           <= tx_data_32[ BITS_SIZE-1: BITS_SIZE - SIZE_TRAMA];
                reg_flag_tx_ready_next      <= 1;

                if(~i_uart_tx_done) begin
                   reg_flag_tx_ready_next   <= 0;
                   reg_tx_counter_bytes_next <= reg_tx_counter_bytes +1;
                   state_next               <= WAIT_TX;
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
            MGMT_STEP:              reg_ctl_clk_wiz <= mips_step;
            MGMT_CONTINUO:          reg_ctl_clk_wiz <= 1'b1;
            MGMT_STOP:              reg_ctl_clk_wiz <= 1'b0;
            default:                reg_ctl_clk_wiz <= 1'b0;
        endcase
    end

    assign o_debug_state            = debug_state;
    assign o_uart_rx_reset          = reg_uart_rx_reset;
    assign o_ctl_clk_wiz            = reg_ctl_clk_wiz;
    assign o_flag_instr_write       = reg_rx_instr_write;
    assign o_select_mem_ins_dir     = reg_counter_dir_mem_instr;   //Ubicacion en memoria de intrucciones
    assign o_dato_mem_ins           = reg_instruccion;             //Intruccion a escribir.
    assign o_flag_tx_ready          = reg_flag_tx_ready;
    assign o_uart_tx_data           = uart_tx_data;
    assign o_select_mem_dir         = reg_tx_counter_mem;
    assign o_select_register_dir    = reg_tx_register_counter;

        
        
endmodule