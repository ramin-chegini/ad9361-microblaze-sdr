/***************************************************************************//**
 *   @file   main.c
 *   @brief  Implementation of Main Function.
 *   @author DBogdan (dragos.bogdan@analog.com)
 ********************************************************************************
 * Copyright 2013(c) Analog Devices, Inc.
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *  - Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  - Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *  - Neither the name of Analog Devices, Inc. nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *  - The use of this software may or may not infringe the patent rights
 *    of one or more patent holders.  This license does not release you
 *    from the requirement that you obtain separate licenses from these
 *    patent holders to use this software.
 *  - Use of the software either in source or binary form, must be run
 *    on or directly connected to an Analog Devices Inc. component.
 *
 * THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT,
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, INTELLECTUAL PROPERTY RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *******************************************************************************/

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include "config.h"
#include "ad9361_api.h"
#include "parameters.h"
#include "platform.h"
#include "spi_ctrl.h"
#include "io_control.h"
#include "xil_exception.h"
#include "gpio_initial.h"
#include "radio_set.h"
#include "ad9361_config.h"
#include "platform.h"
#include "gps_read.h"
#include "xadc.h"

/******************************************************************************/
/************************ Variables Definitions *******************************/
/******************************************************************************/

uint32_t axi_lite_addr = XPAR_UP_AXI_0_BASEADDR;
uint32_t axi_lite_intr_id = XPAR_AXI_INTC_0_SYSTEM_INTERRUPT_INTR;
intr_cmd intr_cmd_param;
uint32_t fpga_ver = 0xa4;
uint32_t sw_ver = 0xa2;
uint32_t config_done = 0;
uint32_t sample_rate = 61.44e6;
uint64_t tx_lo_freq = 100e6;
uint64_t rx_lo_freq = 80e6;//80e6;
uint32_t bandwidth = 56e6;
int32_t gain = 1;
uint32_t txatt = 0e3;
uint32_t auxdac1 = 1482;
uint32_t phase = 128;
uint32_t reconfig = 0;
uint32_t regr = REG_PRODUCT_ID;
int32_t tempa;
fsm_status fsm = IDEL;
extern int intr_irq_proc();
extern uint8_t dev_id;
struct ad9361_rf_phy *ad9361_phy;
struct spi_device cdcm6208_spi = { .id_no = 1 };

/***************************************************************************//**
 * @brief main
 *******************************************************************************/

int main(void) {
	print("**************************************************\n\r");
	print("**********     RFMC6000 NO-OS Test     ***********\n\r");
	print("**************************************************\n\r");

	// NOTE: The user has to choose the GPIO numbers according to desired
	// carrier board.
	gpio_initial();
	spi_init(SPI_DEVICE_ID, 0, 0);
	cdcm6208_init(&cdcm6208_spi);
	cdcm6208_y5_internal(&cdcm6208_spi);
	uint32_t lock_rf1 = -1;
	while (lock_rf1 != 0) {
		lock_rf1 = cdcm6208_spi_read(&cdcm6208_spi, 21) & 0xF;
		printf("read from CDCM6208_RF1 reg21=0x%lx\n", lock_rf1);
	}

	printf("read from CDCM6208_RF1 reg21=0x%lx\n", lock_rf1);

	mdelay(10);
	gpio_set_value(CDCM_SYNC, 1);
	mdelay(10);
	gpio_set_value(CDCM_SYNC, 0);
	mdelay(10);
	gpio_set_value(CDCM_SYNC, 1);
	mdelay(500);

	//configure RF1

	default_init_param.gpio_resetb = RF1_RESETB;
	default_init_param.gpio_sync = -1;
	default_init_param.gpio_cal_sw1 = -1;
	default_init_param.gpio_cal_sw2 = -1;
	spi_init(SPI_DEVICE_ID, 1, 0);

	//__________________________________________
	//Set the index to 0 to read the PLL status
	default_init_param.ctrl_outs_index = 0x01;
	//Enable CTRL_OUT pin number 7 and 6 (0xc0)
	default_init_param.ctrl_outs_enable_mask = 0xc0;
	//__________________________________________

	ad9361_init(&ad9361_phy, &default_init_param);
	ad9361_spi_write(ad9361_phy->spi, REG_TX_CLOCK_DATA_DELAY, 0x40);
	int32_t val;
	val = ad9361_config(ad9361_phy);
	printf("ad9361_phy,REG_PRODUCT_ID=%ld\n", val);
	ad9361_set_auxdac1(ad9361_phy, auxdac1);
	printf("ad9361_phy,auxdac1=%ld\n", auxdac1);

	//set yunsdr axi lite

	uint32_t val_out = AXI_REG_READ(axi_lite_addr, 0);
	printf("register addr=0x0 read out = %ld\n\r", val_out & 0xFFFF);
	val_out = AXI_REG_READ(axi_lite_addr, 100 * 4);
	printf("The FPGA firmware version=0x%2lx\n", val_out);
	printf("The Software firmware version=0x%2lx\n", sw_ver);
	printf("The lasted build at 20220525_PM1\n");
	printf("The lasted build at %s %s\n", __TIME__, __DATE__);

	// interrupt setup

	interrupt_setup();

	//set axi lite

	AXI_REG_WRITE(axi_lite_addr, 2 * 4, 0);				//pps_disable
	AXI_REG_WRITE(axi_lite_addr, 3 * 4, phase);	//phase
	AXI_REG_WRITE(axi_lite_addr, 4 * 4, 1);	//rfmode

	AXI_REG_WRITE(axi_lite_addr, 20 * 4, 0x00);			//idly_en_vtc
	AXI_REG_WRITE(axi_lite_addr, 22 * 4, 120);			//idly_d
	AXI_REG_WRITE(axi_lite_addr, 21 * 4, 0x20);			//idly_load
	AXI_REG_WRITE(axi_lite_addr, 21 * 4, 0x00);			//idly_load
	AXI_REG_WRITE(axi_lite_addr, 20 * 4, 0x7F);			//idly_en_vtc

	//initial interrupt controller
	val = xadc_initial(XPAR_SYSMON_0_DEVICE_ID);
	if (val == 0) {
		printf("Xadc Setup PASSED\r\n");
	}
	spi_init(SPI_DEVICE_ID, 0, 0);
	val = cdcm6208_spi_read(&cdcm6208_spi, 21) & 0xF;
	if (val == 0)
		printf("CDCM6208 use internal 10MHz VCTCXO lock successful!\n");
	else if (val == 1)
		printf("CDCM6208 use external 10MHz VCTCXO lock successful!\n");
	else
		printf("Warning:CDCM6208 failed!\n");

	AXI_REG_WRITE(axi_lite_addr, 26 * 4, 1); 	//bufg_ce
	AXI_REG_WRITE(axi_lite_addr, 1 * 4, 1); 	//mtime_start

	float temp;
	xadc_read_temp(&temp);
	printf("fpga temperature=%lf\n", temp);
	spi_init(SPI_DEVICE_ID, 1, 0);
	tempa = ad9361_get_temp(ad9361_phy);
	printf("rf1_ad9361 temp=%ld,\n", tempa);
	gps_info info;
	val = gps_read_info(&info);
	if (val != 0)
		printf("warning: gps is unlocked!\n");
	else {
		printf("gps is locked successful!\n");
		printf("gps_info,%2d:%2d:%2d,%2d-%2d-%4ld,%6f,%6f,%6f\n",
				info.g_location.time_24h.hour, info.g_location.time_24h.minute,
				info.g_location.time_24h.second, info.g_location.time_24h.day,
				info.g_location.time_24h.month, info.g_location.time_24h.year,
				info.g_location.longitude_f, info.g_location.latitude_f,
				info.g_location.altitude_f);
	}



//	ad9361_bist_tone(ad9361_phy, BIST_INJ_TX, 960000, 0, 1);		//960000
//	uint32_t mode, ch, en, pd;
//	uint32_t rx_path[6],tx_path[6];

	while (1) {
//		ad9361_bist_tone(ad9361_phy, BIST_DISABLE, 3840000, 0, 0);
//		ad9361_bist_tone(ad9361_phy, BIST_INJ_RX, 3840000, 0, 0);
//		ad9361_bist_tone(ad9361_phy, BIST_INJ_RX, 3840000, 0, 1);
//		ad9361_bist_tone(ad9361_phy, BIST_INJ_RX, 3840000, 0, 2);
//		ad9361_bist_tone(ad9361_phy, BIST_INJ_RX, 3840000, 0, 3);
//		ad9361_bist_tone(ad9361_phy, BIST_INJ_TX, 1, 0, 1);		//960000
//		ad9361_bist_tone(ad9361_phy, BIST_INJ_TX, 1, 0, 2);
//		ad9361_bist_tone(ad9361_phy, BIST_INJ_TX, 1, 0, 3);
//		ad9361_bist_tone(ad9361_phy, BIST_INJ_TX, 1, 0, 4);
//		ad9361_bist_tone(ad9361_phy, BIST_INJ_TX, 2, 0, 4);
//		ad9361_bist_tone(ad9361_phy, BIST_INJ_TX, 3, 0, 4);
//		ad9361_bist_tone(ad9361_phy, BIST_INJ_TX, 4, 0, 4);


//		ad9361_en_dis_tx(ad9361_phy,1,1);
//		ad9361_en_dis_tx(ad9361_phy,2,1);
////		ad9361_set_tx_rf_port_output(ad9361_phy,mode);
//		ad9361_get_tx_rf_port_output(ad9361_phy,&mode);

//		ad9361_get_tx_sampling_freq(ad9361_phy, &sample_rate);
//		ad9361_get_tx_lo_freq(ad9361_phy, &tx_lo_freq);
//		ad9361_get_rx_lo_freq(ad9361_phy, &rx_lo_freq);
//		printf("sample_freq=%ldHz\n", sample_rate);
//		printf("tx_lo_freq=%ldHz\n", tx_lo_freq);
//		printf("rx_lo_freq=%ldHz\n", rx_lo_freq);
//		ad9361_get_trx_clock_chain(ad9361_phy,&rx_path[0],&tx_path[0]);

//		ad9361_get_tx_lo_powerdown(ad9361_phy,&pd);
//		printf("pd status=%ld\n", pd);

		AXI_REG_WRITE(axi_lite_addr, 20 * 4, 0x00);			//idly_en_vtc
		AXI_REG_WRITE(axi_lite_addr, 22 * 4, 0x7F);			//idly_d
		AXI_REG_WRITE(axi_lite_addr, 21 * 4, 0x20);			//idly_load
		AXI_REG_WRITE(axi_lite_addr, 21 * 4, 0x00);			//idly_load
		AXI_REG_WRITE(axi_lite_addr, 20 * 4, 0x7F);			//idly_en_vtc
//		if (reconfig) {
//			//reconfig = 0;
//			val = ad9361_config(ad9361_phy);
//			AXI_REG_WRITE(axi_lite_addr, 3 * 4, phase);	//phase
//		}

		if (fsm == CMD_IRQ) {
		    intr_irq_proc(intr_cmd_param, &fsm);
		}

	}
}
