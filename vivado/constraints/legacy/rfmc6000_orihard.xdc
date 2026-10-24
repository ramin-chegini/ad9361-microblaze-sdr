
# ORIHARD + RFMC6000

# -------------------------------------------------------------------
# CLOCK
# -------------------------------------------------------------------

set_property -dict {PACKAGE_PIN K26 IOSTANDARD LVDS} [get_ports sys_clk_p]
create_clock -period 10.000 -name sys_clk_p [get_ports sys_clk_p]
set_clock_groups -asynchronous -group [get_clocks sys_clk_p -include_generated_clocks]

#set_property -dict {PACKAGE_PIN AH31 IOSTANDARD LVCMOS18} [get_ports reset_n]

# -------------------------------------------------------------------
# SPI
# -------------------------------------------------------------------

set_property PACKAGE_PIN K17 [get_ports spi_csn]
set_property IOSTANDARD LVCMOS18 [get_ports spi_csn]
set_property PULLUP true [get_ports spi_csn]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS18} [get_ports spi_clk]
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS18} [get_ports spi_mosi]
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS18} [get_ports spi_miso]

# -------------------------------------------------------------------
# CTRL
# -------------------------------------------------------------------

# AD9361 Ctrl signal

set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS18} [get_ports sync_in]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS18} [get_ports en_agc]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS18} [get_ports enable]
set_property -dict {PACKAGE_PIN L23 IOSTANDARD LVCMOS18} [get_ports resetb]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS18} [get_ports txnrx]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS18} [get_ports clk_out]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS18} [get_ports {ctrl_in[0]}]
set_property -dict {PACKAGE_PIN M22 IOSTANDARD LVCMOS18} [get_ports {ctrl_in[1]}]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS18} [get_ports {ctrl_in[2]}]
set_property -dict {PACKAGE_PIN R21 IOSTANDARD LVCMOS18} [get_ports {ctrl_in[3]}]
set_property -dict {PACKAGE_PIN P21 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[0]}]
set_property -dict {PACKAGE_PIN M16 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[1]}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[2]}]
set_property -dict {PACKAGE_PIN N22 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[3]}]
set_property -dict {PACKAGE_PIN K23 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[4]}]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[5]}]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[6]}]
set_property -dict {PACKAGE_PIN D16 IOSTANDARD LVCMOS18} [get_ports {ctrl_out[7]}]

# -------------------------------------------------------------------
# Y520_50
# -------------------------------------------------------------------

set_property PACKAGE_PIN P20 [get_ports cdcm_spi_cs]
set_property IOSTANDARD LVCMOS18 [get_ports cdcm_spi_cs]
set_property PULLUP true [get_ports cdcm_spi_cs]
set_property SLEW SLOW [get_ports cdcm_spi_cs]
set_property -dict {PACKAGE_PIN R23 IOSTANDARD LVCMOS18} [get_ports cdcm_spi_clk]
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS18} [get_ports cdcm_spi_miso]
set_property -dict {PACKAGE_PIN N20 IOSTANDARD LVCMOS18} [get_ports cdcm_spi_mosi]
set_property -dict {PACKAGE_PIN R22 IOSTANDARD LVCMOS18} [get_ports cdcm_sync]

set_property -dict {PACKAGE_PIN T23 IOSTANDARD LVCMOS18} [get_ports ref_select]
set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVCMOS18} [get_ports ref_select2]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS18} [get_ports fdd_tdd_sel]
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS18} [get_ports trx_sw]

#set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS18} [get_ports gpio_scl]; #FMC3_SCL connected to XC3S200AN-4FTG256I
#set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS18} [get_ports gpio_sda]; #FMC3_SDA connected to XC3S200AN-4FTG256I

set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS18} [get_ports gpio_scl]
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS18} [get_ports gpio_sda]

set_property -dict {PACKAGE_PIN M23 IOSTANDARD LVCMOS18} [get_ports pps_1s]
#set_property -dict {PACKAGE_PIN P22 IOSTANDARD LVCMOS18} [get_ports rxd_gps]; #FMC3_LA33_N
#set_property -dict {PACKAGE_PIN N23 IOSTANDARD LVCMOS18} [get_ports txd_gps]; #FMC3_LA32_P

# -------------------------------------------------------------------
# TX
# -------------------------------------------------------------------

set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVDS} [get_ports tx_clk_out_p]
set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVDS} [get_ports tx_clk_out_n]

set_property -dict {PACKAGE_PIN M21 IOSTANDARD LVDS} [get_ports tx_frame_out_p]
set_property -dict {PACKAGE_PIN L21 IOSTANDARD LVDS} [get_ports tx_frame_out_n]

set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVDS} [get_ports {tx_data_out_p[0]}]
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVDS} [get_ports {tx_data_out_n[0]}]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVDS} [get_ports {tx_data_out_p[1]}]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVDS} [get_ports {tx_data_out_n[1]}]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVDS} [get_ports {tx_data_out_p[2]}]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVDS} [get_ports {tx_data_out_n[2]}]
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVDS} [get_ports {tx_data_out_p[3]}]
set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVDS} [get_ports {tx_data_out_n[3]}]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVDS} [get_ports {tx_data_out_p[4]}]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVDS} [get_ports {tx_data_out_n[4]}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVDS} [get_ports {tx_data_out_p[5]}]
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVDS} [get_ports {tx_data_out_n[5]}]

# -------------------------------------------------------------------
# RX
# -------------------------------------------------------------------

set_property -dict {PACKAGE_PIN H23 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx_clk_in_p]
set_property -dict {PACKAGE_PIN H22 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx_clk_in_n]

create_clock -period 4.000 -name rx_clk_in_p [get_ports rx_clk_in_p]

set_property -dict {PACKAGE_PIN E23 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx_frame_in_p]
set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx_frame_in_n]

set_property -dict {PACKAGE_PIN F24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_p[0]}]
set_property -dict {PACKAGE_PIN F23 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_n[0]}]
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_p[1]}]
set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_n[1]}]
set_property -dict {PACKAGE_PIN E24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_p[2]}]
set_property -dict {PACKAGE_PIN D24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_n[2]}]
set_property -dict {PACKAGE_PIN H24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_p[3]}]
set_property -dict {PACKAGE_PIN G23 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_n[3]}]
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_p[4]}]
set_property -dict {PACKAGE_PIN E21 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_n[4]}]
set_property -dict {PACKAGE_PIN K24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_p[5]}]
set_property -dict {PACKAGE_PIN J24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports {rx_data_in_n[5]}]

# -------------------------------------------------------------------
# 66505 - UltraScale Component - I/O located in Bitslice [0]
# not available during delay calibration
# -------------------------------------------------------------------

set_property UNAVAILABLE_DURING_CALIBRATION true [get_ports resetb]
set_property UNAVAILABLE_DURING_CALIBRATION true [get_ports {tx_data_out_p[4]}]

# -------------------------------------------------------------------
# timing
# -------------------------------------------------------------------

set_false_path -from [get_clocks -of_objects [get_pins system_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT0]] -to [get_clocks rx_clk_in_p]
set_false_path -from [get_clocks rx_clk_in_p] -to [get_clocks -of_objects [get_pins system_i/clk_wiz_0/inst/mmcme4_adv_inst/CLKOUT0]]

set_property IOB FALSE [get_cells system_i/axi_quad_spi_0/U0/NO_DUAL_QUAD_MODE.QSPI_NORMAL/IO1_I_REG]

#set_clock_groups -asynchronous -group [get_clocks rx1_clk_in_p] #                                 -group [get_clocks -of_objects [get_pins system_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]]


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list system_i/clk_wiz_0/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {axi_lite_drv/irq_ctrl[0]} {axi_lite_drv/irq_ctrl[1]} {axi_lite_drv/irq_ctrl[2]} {axi_lite_drv/irq_ctrl[3]} {axi_lite_drv/irq_ctrl[4]} {axi_lite_drv/irq_ctrl[5]} {axi_lite_drv/irq_ctrl[6]} {axi_lite_drv/irq_ctrl[7]} {axi_lite_drv/irq_ctrl[8]} {axi_lite_drv/irq_ctrl[9]} {axi_lite_drv/irq_ctrl[10]} {axi_lite_drv/irq_ctrl[11]} {axi_lite_drv/irq_ctrl[12]} {axi_lite_drv/irq_ctrl[13]} {axi_lite_drv/irq_ctrl[14]} {axi_lite_drv/irq_ctrl[15]} {axi_lite_drv/irq_ctrl[16]} {axi_lite_drv/irq_ctrl[17]} {axi_lite_drv/irq_ctrl[18]} {axi_lite_drv/irq_ctrl[19]} {axi_lite_drv/irq_ctrl[20]} {axi_lite_drv/irq_ctrl[21]} {axi_lite_drv/irq_ctrl[22]} {axi_lite_drv/irq_ctrl[23]} {axi_lite_drv/irq_ctrl[24]} {axi_lite_drv/irq_ctrl[25]} {axi_lite_drv/irq_ctrl[26]} {axi_lite_drv/irq_ctrl[27]} {axi_lite_drv/irq_ctrl[28]} {axi_lite_drv/irq_ctrl[29]} {axi_lite_drv/irq_ctrl[30]} {axi_lite_drv/irq_ctrl[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 1 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list axi_lite_drv/interrupt_set]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets data_clk1]
