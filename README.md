# MIPS-ARQ

**Notas Debug**

ENABLE_LOAD_INSTRU:
reg_instruccion_next        <= {reg_instruccion [23:0], i_uart_rx_data};

{reg_instruccion[23:0], i_uart_rx_data} concatena dos señales.

reg_instruccion[23:0] toma los 24 bits menos significativos de reg_instruccion (bits 0 a 23).

i_uart_rx_data es otro registro (de 8 bits).

Si reg_instruccion tiene el valor 32'bAAAAAAAA_BBBBBBBB_CCCCCCCC_DDDDDDDD y i_uart_rx_data tiene el valor 8'bEEEEEEEE:

reg_instruccion[23:0] es 24'bBBBBBBB_CCCCCCCC_DDDDDDDD.

La concatenación {reg_instruccion[23:0], i_uart_rx_data} resulta en 32'bBBBBBBB_CCCCCCCC_DDDDDDDD_EEEEEEEE.
