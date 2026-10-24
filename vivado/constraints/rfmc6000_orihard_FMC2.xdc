
# ORIHARD (FMC2) + RFMC6000  

# -------------------------------------------------------------------
# CLOCK
# -------------------------------------------------------------------

set_property -dict {PACKAGE_PIN K26 IOSTANDARD LVDS} [get_ports Clk_in_100M]
#set_property -dict {PACKAGE_PIN K26 IOSTANDARD LVDS} [get_ports sys_clk_p]
create_clock -period 10.000 -name Clk_in_100M [get_ports Clk_in_100M]
#create_clock -period 10.000 -name sys_clk_p [get_ports sys_clk_p]
set_clock_groups -asynchronous -group [get_clocks Clk_in_100M -include_generated_clocks]
#set_clock_groups -asynchronous -group [get_clocks sys_clk_p -include_generated_clocks]

#set_property -dict {PACKAGE_PIN AH31 IOSTANDARD LVCMOS18} [get_ports reset_n]

# -------------------------------------------------------------------
# SPI
# -------------------------------------------------------------------

set_property -dict {PACKAGE_PIN F28 IOSTANDARD LVCMOS18 PULLUP true} [get_ports spi_csn]; #FMC2_LA19_P
set_property -dict {PACKAGE_PIN F30 IOSTANDARD LVCMOS18} [get_ports spi_clk];  #FMC2_LA18_N_CC
set_property -dict {PACKAGE_PIN G30 IOSTANDARD LVCMOS18} [get_ports spi_mosi]; #FMC2_LA18_P_CC
set_property -dict {PACKAGE_PIN F33 IOSTANDARD LVCMOS18} [get_ports spi_miso]; #FMC2_LA20_P

# -------------------------------------------------------------------
# CTRL
# -------------------------------------------------------------------

# AD9361 Ctrl signal

set_property -dict {PACKAGE_PIN G31 IOSTANDARD LVCMOS18} [get_ports sync_in];     #FMC2_LA17_P_CC
set_property -dict {PACKAGE_PIN M32 IOSTANDARD LVCMOS18} [get_ports en_agc];      #FMC2_LA16_P
set_property -dict {PACKAGE_PIN E28 IOSTANDARD LVCMOS18} [get_ports enable];      #FMC2_LA19_N
set_property -dict {PACKAGE_PIN H28 IOSTANDARD LVCMOS18} [get_ports resetb];      #FMC2_LA23_P
set_property -dict {PACKAGE_PIN F31 IOSTANDARD LVCMOS18} [get_ports txnrx];       #FMC2_LA17_N_CC
set_property -dict {PACKAGE_PIN E33 IOSTANDARD LVCMOS18} [get_ports clk_out];     #FMC2_LA20_N
set_property -dict {PACKAGE_PIN M25 IOSTANDARD LVCMOS18} [get_ports {ctrl_in[0]}];  #FMC2_LA26_P
set_property -dict {PACKAGE_PIN J31 IOSTANDARD LVCMOS18} [get_ports {ctrl_in[1]}];  #FMC2_LA22_N
set_property -dict {PACKAGE_PIN C32 IOSTANDARD LVCMOS18} [get_ports {ctrl_in[2]}];  #FMC2_LA21_P
set_property -dict {PACKAGE_PIN F29 IOSTANDARD LVCMOS18} [get_ports {ctrl_in[3]}];  #FMC2_LA25_P
set_property -dict {PACKAGE_PIN E29 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[0]}]; #FMC2_LA25_N
set_property -dict {PACKAGE_PIN C28 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[1]}]; #FMC2_LA24_N
set_property -dict {PACKAGE_PIN C33 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[2]}]; #FMC2_LA21_N
set_property -dict {PACKAGE_PIN K31 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[3]}]; #FMC2_LA22_P
set_property -dict {PACKAGE_PIN G28 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[4]}]; #FMC2_LA23_N
set_property -dict {PACKAGE_PIN D27 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[5]}]; #FMC2_LA24_P
set_property -dict {PACKAGE_PIN L26 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[6]}]; #FMC2_LA26_N
set_property -dict {PACKAGE_PIN L31 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[7]}]; #FMC2_LA16_N

# -------------------------------------------------------------------
# Y520_50
# -------------------------------------------------------------------

set_property -dict {PACKAGE_PIN P24 IOSTANDARD LVCMOS18 PULLUP true SLEW SLOW } [get_ports cdcm_spi_cs]; #FMC2_LA30_P
set_property -dict {PACKAGE_PIN E27 IOSTANDARD LVCMOS18} [get_ports cdcm_spi_clk];  #FMC2_LA29_N
set_property -dict {PACKAGE_PIN L25 IOSTANDARD LVCMOS18} [get_ports cdcm_spi_miso]; #FMC2_LA31_N
set_property -dict {PACKAGE_PIN N24 IOSTANDARD LVCMOS18} [get_ports cdcm_spi_mosi]; #FMC2_LA30_N
set_property -dict {PACKAGE_PIN E32 IOSTANDARD LVCMOS18} [get_ports cdcm_sync];     #FMC2_LA33_P

set_property -dict {PACKAGE_PIN E26 IOSTANDARD LVCMOS18} [get_ports ref_select];    #FMC2_LA29_P
set_property -dict {PACKAGE_PIN L24 IOSTANDARD LVCMOS18} [get_ports ref_select2];   #FMC2_LA31_P
set_property -dict {PACKAGE_PIN F25 IOSTANDARD LVCMOS18} [get_ports fdd_tdd_sel];   #FMC2_LA28_N
set_property -dict {PACKAGE_PIN P30 IOSTANDARD LVCMOS18} [get_ports trx_sw];        #FMC2_LA27_N

#set_property -dict {PACKAGE_PIN N8 IOSTANDARD LVCMOS18} [get_ports gpio_scl]; #FMC2_SCL connected to XC3S200AN-4FTG256I
#set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVCMOS18} [get_ports gpio_sda]; #FMC2_SDA connected to XC3S200AN-4FTG256I

# above section replaced by following to mitigate the error

set_property -dict {PACKAGE_PIN G25 IOSTANDARD LVCMOS18} [get_ports gpio_scl]; #FMC2_SCL (C30)creplaced by FMC2_LA28_P
set_property -dict {PACKAGE_PIN P29 IOSTANDARD LVCMOS18} [get_ports gpio_sda]; #FMC2_SDA (C31)creplaced by FMC2_LA27_P

set_property -dict {PACKAGE_PIN D31 IOSTANDARD LVCMOS18} [get_ports pps_1s];   #FMC2_LA32_N
#set_property -dict {PACKAGE_PIN D32 IOSTANDARD LVCMOS18} [get_ports rxd_gps];  #FMC2_LA33_N
#set_property -dict {PACKAGE_PIN E31 IOSTANDARD LVCMOS18} [get_ports txd_gps];  #FMC2_LA32_P

# -------------------------------------------------------------------
# TX
# -------------------------------------------------------------------

set_property -dict {PACKAGE_PIN H29  IOSTANDARD LVDS} [get_ports tx_clk_out_p];     #FMC2_CLK0_C2M_P
set_property -dict {PACKAGE_PIN H30  IOSTANDARD LVDS} [get_ports tx_clk_out_n];     #FMC2_CLK0_C2M_N

set_property -dict {PACKAGE_PIN L28  IOSTANDARD LVDS} [get_ports tx_frame_out_p];   #FMC2_LA07_P
set_property -dict {PACKAGE_PIN K28  IOSTANDARD LVDS} [get_ports tx_frame_out_n];   #FMC2_LA07_N

set_property -dict {PACKAGE_PIN R28  IOSTANDARD LVDS} [get_ports {tx_data_out_p[0]}]; #FMC2_LA12_P
set_property -dict {PACKAGE_PIN R29  IOSTANDARD LVDS} [get_ports {tx_data_out_n[0]}]; #FMC2_LA12_N
set_property -dict {PACKAGE_PIN N28  IOSTANDARD LVDS} [get_ports {tx_data_out_p[1]}]; #FMC2_LA11_P
set_property -dict {PACKAGE_PIN N29  IOSTANDARD LVDS} [get_ports {tx_data_out_n[1]}]; #FMC2_LA11_N
set_property -dict {PACKAGE_PIN H33  IOSTANDARD LVDS} [get_ports {tx_data_out_p[2]}]; #FMC2_LA13_P
set_property -dict {PACKAGE_PIN G33  IOSTANDARD LVDS} [get_ports {tx_data_out_n[2]}]; #FMC2_LA13_N
set_property -dict {PACKAGE_PIN L29  IOSTANDARD LVDS} [get_ports {tx_data_out_p[3]}]; #FMC2_LA14_P
set_property -dict {PACKAGE_PIN L30  IOSTANDARD LVDS} [get_ports {tx_data_out_n[3]}]; #FMC2_LA14_N
set_property -dict {PACKAGE_PIN K32  IOSTANDARD LVDS} [get_ports {tx_data_out_p[4]}]; #FMC2_LA15_P
set_property -dict {PACKAGE_PIN J32  IOSTANDARD LVDS} [get_ports {tx_data_out_n[4]}]; #FMC2_LA15_N
set_property -dict {PACKAGE_PIN J29  IOSTANDARD LVDS} [get_ports {tx_data_out_p[5]}]; #FMC2_LA09_P
set_property -dict {PACKAGE_PIN J30  IOSTANDARD LVDS} [get_ports {tx_data_out_n[5]}]; #FMC2_LA09_N

# -------------------------------------------------------------------
# RX
# -------------------------------------------------------------------

set_property -dict {PACKAGE_PIN H32 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx_clk_in_p];       #FMC2_CLK0_P, FMC2_CLK0_M2C_P (H4)
set_property -dict {PACKAGE_PIN G32 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx_clk_in_n];       #FMC2_CLK0_N, FMC2_CLK0_M2C_N (H5)

create_clock -period 4.000 -name rx_clk_in_p [get_ports rx_clk_in_p]

set_property -dict {PACKAGE_PIN P26 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx_frame_in_p];     #FMC2_LA06_P
set_property -dict {PACKAGE_PIN N27 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx_frame_in_n];     #FMC2_LA06_N

set_property -dict {PACKAGE_PIN T26 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_p[0]}]; #FMC2_LA08_P
set_property -dict {PACKAGE_PIN R26 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_n[0]}]; #FMC2_LA08_N
set_property -dict {PACKAGE_PIN M27 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_p[1]}]; #FMC2_LA10_P
set_property -dict {PACKAGE_PIN M28 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_n[1]}]; #FMC2_LA10_N
set_property -dict {PACKAGE_PIN P25 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_p[2]}]; #FMC2_LA04_P
set_property -dict {PACKAGE_PIN N25 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_n[2]}]; #FMC2_LA04_N
set_property -dict {PACKAGE_PIN T24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_p[3]}]; #FMC2_LA03_P
set_property -dict {PACKAGE_PIN R24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_n[3]}]; #FMC2_LA03_N
set_property -dict {PACKAGE_PIN N30 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_p[4]}]; #FMC2_LA05_P
set_property -dict {PACKAGE_PIN M30 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_n[4]}]; #FMC2_LA05_N
set_property -dict {PACKAGE_PIN R27 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_p[5]}]; #FMC2_LA02_P
set_property -dict {PACKAGE_PIN P27 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_n[5]}]; #FMC2_LA02_N

# -------------------------------------------------------------------
# 66505 - UltraScale Component - I/O located in Bitslice [0]
# not available during delay calibration
# -------------------------------------------------------------------

#set_property UNAVAILABLE_DURING_CALIBRATION true [get_ports resetb]
#set_property UNAVAILABLE_DURING_CALIBRATION true [get_ports {tx_data_out_p[4]}]

# -------------------------------------------------------------------
# timing
# -------------------------------------------------------------------

set_false_path -from [get_clocks -of_objects [get_pins system_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks rx_clk_in_p]
set_false_path -from [get_clocks rx_clk_in_p] -to [get_clocks -of_objects [get_pins system_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT0]]

set_property IOB FALSE [get_cells system_i/axi_quad_spi_0/U0/NO_DUAL_QUAD_MODE.QSPI_NORMAL/IO1_I_REG]

#set_clock_groups -asynchronous -group [get_clocks rx1_clk_in_p] #                                 -group [get_clocks -of_objects [get_pins system_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]]


#create_debug_core u_ila_0 ila
#set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
#set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
#set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
#set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
#set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
#set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
#set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
#set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
#set_property port_width 1 [get_debug_ports u_ila_0/clk]
#connect_debug_port u_ila_0/clk [get_nets [list system_i/clk_wiz_0/inst/clk_out1]]
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
#set_property port_width 32 [get_debug_ports u_ila_0/probe0]
#connect_debug_port u_ila_0/probe0 [get_nets [list {axi_lite_drv/irq_ctrl[0]} {axi_lite_drv/irq_ctrl[1]} {axi_lite_drv/irq_ctrl[2]} {axi_lite_drv/irq_ctrl[3]} {axi_lite_drv/irq_ctrl[4]} {axi_lite_drv/irq_ctrl[5]} {axi_lite_drv/irq_ctrl[6]} {axi_lite_drv/irq_ctrl[7]} {axi_lite_drv/irq_ctrl[8]} {axi_lite_drv/irq_ctrl[9]} {axi_lite_drv/irq_ctrl[10]} {axi_lite_drv/irq_ctrl[11]} {axi_lite_drv/irq_ctrl[12]} {axi_lite_drv/irq_ctrl[13]} {axi_lite_drv/irq_ctrl[14]} {axi_lite_drv/irq_ctrl[15]} {axi_lite_drv/irq_ctrl[16]} {axi_lite_drv/irq_ctrl[17]} {axi_lite_drv/irq_ctrl[18]} {axi_lite_drv/irq_ctrl[19]} {axi_lite_drv/irq_ctrl[20]} {axi_lite_drv/irq_ctrl[21]} {axi_lite_drv/irq_ctrl[22]} {axi_lite_drv/irq_ctrl[23]} {axi_lite_drv/irq_ctrl[24]} {axi_lite_drv/irq_ctrl[25]} {axi_lite_drv/irq_ctrl[26]} {axi_lite_drv/irq_ctrl[27]} {axi_lite_drv/irq_ctrl[28]} {axi_lite_drv/irq_ctrl[29]} {axi_lite_drv/irq_ctrl[30]} {axi_lite_drv/irq_ctrl[31]}]]
#create_debug_port u_ila_0 probe
#set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
#set_property port_width 1 [get_debug_ports u_ila_0/probe1]
#connect_debug_port u_ila_0/probe1 [get_nets [list axi_lite_drv/interrupt_set]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets data_clk1]
