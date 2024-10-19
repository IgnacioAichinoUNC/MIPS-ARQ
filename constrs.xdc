set_property PACKAGE_PIN W5 [get_ports i_clk]
set_property IOSTANDARD LVCMOS33 [get_ports i_clk]
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 5} [get_ports i_clk]

set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports i_reset]

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# LED outputs
#data de 8 bits que llega al uart rx
#set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports uart_rx_data[0]]
#set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports uart_rx_data[1]]
#set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports uart_rx_data[2]]
#set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports uart_rx_data[3]]
#set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports uart_rx_data[4]]
#set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports uart_rx_data[5]]
#set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports uart_rx_data[6]]
#set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports uart_rx_data[7]]

#debug states
set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports o_debug_state[3]]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports o_debug_state[2]]
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports o_debug_state[1]]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports o_debug_state[0]]

set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports i_uart_rx]
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports o_uart_tx]


set_property CONFIG_VOLTAGE 3.3 [current_design]