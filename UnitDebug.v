`timescale 1ns / 1ps



module UnitDebug
    #(
        parameter       BANK_REGISTERS_SIZE     = 32,
        parameter       MEM_DATA_SIZE           = 16,
        parameter       MEM_INST_TOTAL_SIZE     = 256,
        parameter       MEM_INST_SIZE_BITS      = 8,
        parameter       SIZE_TRAMA              = 8,
        parameter       BITS_SIZE               = 32,
        parameter       BITS_REGS               = 5
    )
    (
        input                                   i_clk,
        input                                   i_reset,
        input           [BITS_SIZE-1 :0]        i_clk_wiz_count,
        input                                   i_uart_rx_flag_ready,
        input           [SIZE_TRAMA-1:0]        i_uart_rx_data,
        input                                   i_uart_tx_done,
        input           [BITS_SIZE-1:0]         i_mips_pc,
        input           [BITS_SIZE-1:0]         i_data_bankregisters,
        input           [BITS_SIZE-1:0]         i_data_mem,
        input                                   i_halt,


        output                                  o_ctl_clk_wiz,
        output                                  o_uart_rx_reset,
        output                                  o_flag_tx_ready,
        output          [SIZE_TRAMA-1:0]        o_uart_tx_data,
        output          [BITS_SIZE-1:0]         o_select_addr_memdata
        output          [BITS_REGS-1:0]         o_select_addr_registers,
        output                                  o_flag_instr_write,
        output          [MEM_INST_SIZE_BITS-1:0]     o_select_addr_mem_instr,
        output          [BITS_SIZE-1:0]         o_dato_mem_instruction,
        output          [3:0]                   o_debug_state,


    );

    localparam IDLE             =   4'b0000;      //estado default
    localparam CONTINUO         =   4'b0010;     //'c' modo continuo para mips
    localparam STEP             =   4'b0001;      //'s' modo step mips
    localparam DATA_RX_LOAD     =   4'b0011;     //'d' estado data load donde se habilita la carga de instrucciones cuando se tienen los 32 bits por rx
    localparam SEND_DATA_TX     =   4'b0100;      //  envio 8 btis
    localparam WAIT_TX          =   4'b0110;      
    localparam LOAD_DATA_TX     =   4'b0111;      //segun el contador se carga la data para enviar (pc, registros y ciclos)
    localparam PREPARE_INSTRUCT =   4'b1000; 
    localparam DATA_INSTR       =   4'b1001;    
    localparam MGMT_STOP        =   2'b00;           //para gestionar el modulo clock e i_step
    localparam MGMT_CONTINUO    =   2'b01;
    localparam MGMT_STEP        =   2'b11;
    localparam SIZE_COUNTER_DIR = $clog2(MEM_INST_TOTAL_SIZE);
    localparam MEM_COUNT_SIZE   = $clog2(MEM_DATA_SIZE);
    localparam REG_COUNT_SIZE   = $clog2(BANK_REGISTERS_SIZE);


    reg                             reg_ctl_clk_wiz;
    reg     [4:0]                   state, state_next;
    reg     [3:0]                   debug_state, debug_state_next;
    reg                             uart_rx_reset, uart_rx_reset_next;
    reg     [BITS_SIZE-1:0]         reg_instruccion, reg_instruccion_next;
    reg                             reg_rx_instr_write, reg_rx_instr_write_next;
    reg     [SIZE_COUNTER_DIR-1:0]  reg_counter_mem_address=0, reg_counter_mem_address_next=0;
    reg     [1:0]                   reg_rx_counter_bytes=0, reg_rx_counter_bytes_next=0;
    reg     [1:0]                   mode, mode_next;
    reg                             mips_step, mips_step_next;

    reg    [SIZE_TRAMA-1:0]         uart_tx_data, uart_tx_data_next;
    reg                             reg_flag_tx_ready, reg_flag_tx_ready_next;
    reg    [BITS_SIZE-1:0]          tx_data_32, tx_data_32_next;
    reg    [1:0]                    reg_tx_counter_bytes, reg_tx_counter_bytes_next;
    reg    [2:0]                    reg_tx_selector_data, reg_tx_selector_data_next;
    reg    [REG_COUNT_SIZE-1:0]     reg_tx_register_counter, reg_tx_register_counter_next;
    reg    [MEM_COUNT_SIZE-1:0]     reg_tx_counter_mem, reg_tx_counter_mem_next;



    always @ (posedge i_clk)
        begin
            if (i_reset)begin
                state                   <= IDLE;
                uart_rx_reset           <= 1;
                reg_instruccion         <= 0;
                reg_rx_counter_bytes    <= 0;
                reg_counter_mem_address   <= 0;
                reg_rx_instr_write      <= 0;
                uart_tx_data            <= 0;
                reg_flag_tx_ready       <= 0;
                reg_tx_counter_bytes    <= 0;
                reg_tx_selector_data    <= 0;
                reg_tx_register_counter <= 0;
                reg_tx_counter_mem      <= 0;
                tx_data_32              <= 0;
                mode                    <= MGMT_STOP;
                mips_step               <= 0;
                debug_state             <= 0;
            end else begin
                debug_state             <= debug_state_next;
                state                   <= state_next;
                uart_rx_reset           <= uart_rx_reset_next;
                reg_instruccion         <= reg_instruccion_next;
                reg_rx_counter_bytes    <= reg_rx_counter_bytes_next;
                reg_counter_mem_address   <= reg_counter_mem_address_next;
                reg_rx_instr_write      <= reg_rx_instr_write_next;
                uart_tx_data            <= uart_tx_data_next;
                reg_flag_tx_ready       <= reg_flag_tx_ready_next;
                reg_tx_counter_bytes    <= reg_tx_counter_bytes_next;
                reg_tx_selector_data    <= reg_tx_selector_data_next;
                reg_tx_register_counter <= reg_tx_register_counter_next;
                reg_tx_counter_mem      <= reg_tx_counter_mem_next;
                tx_data_32              <= tx_data_32_next;
                mode                    <= mode_next;
                mips_step               <= mips_step_next;
            end
        end

    always @*
    begin
        state_next                  <= state;
        debug_state_next            <= debug_state;
        uart_rx_reset_next          <= uart_rx_reset;
        reg_instruccion_next        <= reg_instruccion;
        reg_rx_counter_bytes_next   <= reg_rx_counter_bytes;
        reg_counter_mem_address_next  <= reg_counter_mem_address;
        reg_rx_instr_write_next     <= reg_rx_instr_write;
        uart_tx_data_next           <= uart_tx_data;
        reg_flag_tx_ready_next      <= reg_flag_tx_ready;
        reg_tx_counter_bytes_next   <= reg_tx_counter_bytes;
        reg_tx_selector_data_next   <= reg_tx_selector_data;
        reg_tx_register_counter_next    <= reg_tx_register_counter;
        reg_tx_counter_mem_next     <= reg_tx_counter_mem;
        tx_data_32_next             <= tx_data_32;
        mode_next                   <= mode;
        mips_step_next              <= mips_step;

        case (state)
            IDLE:
            begin
                debug_state_next <= 1;

                if (~i_uart_rx_flag_ready) begin 
                    uart_rx_reset_next  <= 0;
                end 
                else begin 
                    uart_rx_reset_next  <= 1;
                    case(i_uart_rx_data)
                        8'b01100011:    state_next          <= CONTINUO; // c
                        8'b01110011:    state_next          <= STEP;    // s
                        8'b01100100:    state_next          <= PREPARE_INSTRUCT; //d
                        default:        state_next          <= IDLE;      
                    endcase
                end
            end
            CONTINUO:
            begin
                mode_next  <= MGMT_CONTINUO;
                if( i_halt ) begin
                    mode_next       <= MGMT_STOP;
                    state_next      <= LOAD_DATA_TX;
                end
            end
            STEP:
            begin
                debug_state_next    <= 2;
                mode_next           <= MGMT_STEP;

                if( i_halt ) begin
                    mode_next       <= MGMT_STOP;
                    state_next      <= LOAD_DATA_TX;
                end
                if( mips_step ) begin
                    mips_step_next  <= 0;
                    state_next      <= LOAD_DATA_TX;
                end 
                else begin
                    if (~i_uart_rx_flag_ready) begin
                        uart_rx_reset_next  <= 0;
                    end 
                    else begin // Verifica si el char recibido es n (next)
                        uart_rx_reset_next  <= 1;
                        if( i_uart_rx_data == 8'b01101110) begin   //n
                            mips_step_next <= 1;
                        end
                    end
                end
            end
            PREPARE_INSTRUCT:
            begin
                debug_state_next <= 3;

                if (~i_uart_rx_flag_ready) begin
                    uart_rx_reset_next  <= 0;
                end 
                else begin // Recibo dato
                    uart_rx_reset_next          <= 1;
                    reg_instruccion_next        <= {reg_instruccion [23:0], i_uart_rx_data};
                    reg_rx_counter_bytes_next   <= reg_rx_counter_bytes + 1;
                    state_next                  <= DATA_RX_LOAD;
                end
            end
            DATA_RX_LOAD: //Chequeo si ya tengo los 32 bits por el contador
            begin
                debug_state_next <= 4;
                
                if(reg_rx_counter_bytes == 0) begin
                    reg_rx_instr_write_next     <= 1; //habilita escribir la instruccion
                    state_next                  <= DATA_INSTR;
                end 
                else begin
                    state_next                  <= PREPARE_INSTRUCT;
                end
            end
            DATA_INSTR: 
            begin
                debug_state_next                <= 5;
                reg_rx_instr_write_next         <= 0; 

                if(reg_instruccion == 32'b11111111111111111111111111111111) begin //instruccion armada HALT se vuelve al inicio
                    reg_counter_mem_address_next  <= 0;
                    state_next                    <= IDLE;
                end 
                else begin
                    reg_counter_mem_address_next  <= reg_counter_mem_address + 4; //Aumenta en 4 la direccion de memoria para la instruccion
                    state_next                    <= PREPARE_INSTRUCT;
                end
            end
            LOAD_DATA_TX:
            begin
                debug_state_next <= 6;
                
                case(reg_tx_selector_data)
                    0: // Envia el dato de PC del MIPS
                    begin
                        tx_data_32_next           <= i_mips_pc;
                        reg_tx_selector_data_next <= reg_tx_selector_data + 1;
                        state_next                <= SEND_DATA_TX;
                    end

                    1: //se envia numero de ciclos realizados en total desde el inicio
                    begin
                        tx_data_32_next           <= i_clk_wiz_count;
                        reg_tx_selector_data_next <= reg_tx_selector_data + 1;
                        state_next                <= SEND_DATA_TX;
                    end

                    2: // envio data de los 32 registros
                    begin
                        tx_data_32_next             <= i_data_bankregisters;
                        reg_tx_register_counter_next    <= reg_tx_register_counter + 1;
                        
                        if(reg_tx_register_counter == BANK_REGISTERS_SIZE-1) begin
                            reg_tx_selector_data_next <= reg_tx_selector_data + 1;
                        end
                        state_next  <= SEND_DATA_TX;
                    end

                    3: //Envio el contenido de memoria de datos
                    begin
                        tx_data_32_next         <= i_data_mem;
                        reg_tx_counter_mem_next <= reg_tx_counter_mem + 1;

                        if(reg_tx_counter_mem == MEM_DATA_SIZE-1) begin
                            reg_tx_selector_data_next <= reg_tx_selector_data + 1;
                        end
                        state_next  <= SEND_DATA_TX;
                    end

                    4: //envie todo 
                    begin
                        reg_tx_selector_data_next  <= 0;

                        if(mode  == MGMT_STEP) begin
                            state_next  <= STEP;
                        end else 
                        begin
                            state_next  <= IDLE;
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
                debug_state_next        <= 7;
                uart_tx_data_next       <= tx_data_32[ BITS_SIZE-1: BITS_SIZE - SIZE_TRAMA];
                reg_flag_tx_ready_next  <= 1;

                if(~i_uart_tx_done) begin
                   reg_flag_tx_ready_next       <= 0;
                   reg_tx_counter_bytes_next    <= reg_tx_counter_bytes +1;
                   state_next                   <= WAIT_TX;
                end
            end
            WAIT_TX:
            begin
                debug_state_next <= 8;

                if(i_uart_tx_done) begin
                    if(reg_tx_counter_bytes == 0) begin
                        state_next <= LOAD_DATA_TX;
                    end 
                    else begin
                        tx_data_32_next       <= tx_data_32 << 8;
                        state_next            <= SEND_DATA_TX;
                    end
                end
            end
           default:
                state_next <= IDLE; //default idle
         endcase
    end

    //Control el del modulo clock segun el modo
    always @*
    begin
        case(mode)
            MGMT_CONTINUO:   reg_ctl_clk_wiz <= 1'b1;
            MGMT_STEP:       reg_ctl_clk_wiz <= mips_step;
            MGMT_STOP:       reg_ctl_clk_wiz <= 1'b0;
            default:         reg_ctl_clk_wiz <= 1'b0;
        endcase
    end

    assign o_debug_state            = debug_state;
    assign o_flag_tx_ready          = reg_flag_tx_ready;
    assign o_uart_tx_data           = uart_tx_data;
    assign o_uart_rx_reset          = uart_rx_reset;
    assign o_ctl_clk_wiz            = reg_ctl_clk_wiz;
    assign o_select_addr_registers  = reg_tx_register_counter;
    assign o_select_addr_memdata    = reg_tx_counter_mem;
    assign o_select_addr_mem_instr  = reg_counter_mem_address;
    assign o_dato_mem_instruction    = reg_instruccion;
    assign o_flag_instr_write       = reg_rx_instr_write;

endmodule