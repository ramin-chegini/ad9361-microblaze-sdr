set_property -dict {PACKAGE_PIN AK17 IOSTANDARD LVDS} [get_ports sys_clk_p ]; 
set_property -dict {PACKAGE_PIN AK16 IOSTANDARD LVDS} [get_ports sys_clk_n ]; 
create_clock -name sys_clk_i -period 5.000 [get_ports sys_clk_p]
set_clock_groups -group [get_clocks sys_clk_i -include_generated_clocks] -asynchronous
 
set_property -dict {PACKAGE_PIN AJ11 IOSTANDARD LVCMOS18} [get_ports UART_rxd  ];
set_property -dict {PACKAGE_PIN AM9  IOSTANDARD LVCMOS18} [get_ports UART_txd  ]; 
set_property -dict {PACKAGE_PIN E12  IOSTANDARD LVCMOS18} [get_ports led       ]; 

set_property IOB FALSE [get_cells system_i/axi_quad_spi_0/U0/NO_DUAL_QUAD_MODE.QSPI_NORMAL/IO1_I_REG]

set_clock_groups -asynchronous -group [get_clocks rx1_clk_in_p] \
                                 -group [get_clocks -of_objects [get_pins system_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]]                            