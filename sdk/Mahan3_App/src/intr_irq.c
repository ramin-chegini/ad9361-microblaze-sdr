/**
 * @file intr_irq.c
 * @brief Execute FPGA mailbox commands in the bare-metal foreground loop.
 *
 * Command numbers and response packing form the existing host/FPGA protocol.
 */
#include "INTR_IRQHandler.h"
#include "spi_ctrl.h"
#include "platform.h"
#include "ad9361_api.h"
#include "ad9361_config.h"
#include "ad9361.h"
#include "parameters.h"
#include "io_control.h"
uint64_t cmd_inford;
uint32_t cmd_inford1;
uint8_t cmd_inford2;
int32_t cmd_inford3;
extern uint32_t axi_lite_addr;
extern struct ad9361_rf_phy *ad9361_phy;
extern struct spi_device cdcm6208_spi;
extern uint32_t fpga_ver;
extern uint32_t sw_ver;
extern int32_t tempa;
extern uint32_t sample_rate;
uint32_t dev_id = 0;
uint32_t rf_id;
int32_t val;
uint32_t timeout;
int intr_irq_proc(intr_cmd intr_cmd_param, fsm_status *fsm) {
	uint64_t cmd_infowr;
	uint8_t ad9361_id;
	uint8_t wr_rdn;
	uint8_t cmd_num;
	cmd_infowr = intr_cmd_param.cmd_infowr;
	ad9361_id = intr_cmd_param.ad9361_id & 0x1;
	rf_id = intr_cmd_param.ad9361_id >> 1 & 0x1;
	wr_rdn = intr_cmd_param.wr_rdn;
	if (ad9361_id == 0)
		cmd_num = intr_cmd_param.cmd_num;
	else
		cmd_num = 255;
	spi_init(SPI_DEVICE_ID, 1, 0);
	switch (cmd_num) {
	case 1: /* Raw AD9361 register access */
		if (wr_rdn)
			ad9361_spi_write(ad9361_phy->spi,
					(uint32_t) (cmd_infowr & 0xFFFFFFFF),
					(uint32_t) (cmd_infowr >> 32 & 0xFFFFFFFF));
		cmd_inford2 = ad9361_spi_read(ad9361_phy->spi,
				(uint32_t) (cmd_infowr & 0xFFFFFFFF));
		cmd_inford = (uint64_t) cmd_inford2;
		break;
	case 2: /* TX local oscillator frequency (Hz) */
		if (wr_rdn) {
			ad9361_set_tx_lo_freq(ad9361_phy, cmd_infowr);
		}
		ad9361_get_tx_lo_freq(ad9361_phy, &cmd_inford);
		break;
	case 3: /* Sample rate and FPGA PPS counters */
		if (wr_rdn) {
			sample_rate = (uint32_t) cmd_infowr;
			ad9361_set_sample(ad9361_phy, &sample_rate);
			AXI_REG_WRITE(axi_lite_addr, 3 * 4, sample_rate); 	//sample_1pps
			AXI_REG_WRITE(axi_lite_addr, 29 * 4, sample_rate << 2);	//clock_1pps
		}
		ad9361_get_tx_sampling_freq(ad9361_phy, &cmd_inford1);
		cmd_inford = (uint64_t) sample_rate;
		break;
	case 4: /* TX RF bandwidth (Hz) */
		if (wr_rdn){
			ad9361_set_tx_rf_bandwidth(ad9361_phy, (uint32_t) cmd_infowr);
		}
		ad9361_get_tx_rf_bandwidth(ad9361_phy, &cmd_inford1);
		cmd_inford = (uint64_t) cmd_inford1;
		break;
	case 5: /* TX1 attenuation (millidecibels) */
		if (wr_rdn)
			ad9361_set_tx_attenuation(ad9361_phy, 0, (uint32_t) cmd_infowr);
		ad9361_get_tx_attenuation(ad9361_phy, 0, &cmd_inford1);
		cmd_inford = (uint64_t) cmd_inford1;
		break;
	case 6: /* TX2 attenuation (millidecibels) */
		if (wr_rdn)
			ad9361_set_tx_attenuation(ad9361_phy, 1, (uint32_t) cmd_infowr);
		ad9361_get_tx_attenuation(ad9361_phy, 1, &cmd_inford1);
		cmd_inford = (uint64_t) cmd_inford1;
		break;
	case 7: /* TX FIR enable readback */
		ad9361_get_tx_fir_en_dis(ad9361_phy, &cmd_inford2);
		cmd_inford = (uint64_t) cmd_inford2;
		break;
	case 8: /* RX local oscillator frequency (Hz) */
		if (wr_rdn) {
			ad9361_set_rx_lo_freq(ad9361_phy, cmd_infowr);
		}
		ad9361_get_rx_lo_freq(ad9361_phy, &cmd_inford);
		break;
	case 9: /* RX RF bandwidth (Hz) */
		if (wr_rdn){
			ad9361_set_rx_rf_bandwidth(ad9361_phy, (uint32_t) cmd_infowr);
		}
		ad9361_get_rx_rf_bandwidth(ad9361_phy, &cmd_inford1);
		cmd_inford = (uint64_t) cmd_inford1;
		break;
	case 10: /* RX1 gain control mode */
		if (wr_rdn)
			ad9361_set_rx_gain_control_mode(ad9361_phy, 0,
					(uint8_t) cmd_infowr);
		ad9361_get_rx_gain_control_mode(ad9361_phy, 0, &cmd_inford2);
		cmd_inford = (uint64_t) cmd_inford2;
		break;
	case 11: /* RX2 gain control mode */
		if (wr_rdn)
			ad9361_set_rx_gain_control_mode(ad9361_phy, 1,
					(uint8_t) cmd_infowr);
		ad9361_get_rx_gain_control_mode(ad9361_phy, 1, &cmd_inford2);
		cmd_inford = (uint64_t) cmd_inford2;
		break;
	case 12: /* RX1 manual gain (dB) */
		if (wr_rdn)
			ad9361_set_rx_rf_gain(ad9361_phy, 0, (int32_t) cmd_infowr);
		ad9361_get_rx_rf_gain(ad9361_phy, 0, &cmd_inford3);
		cmd_inford = (uint64_t) cmd_inford3;
		break;
	case 13: /* RX2 manual gain (dB) */
		if (wr_rdn)
			ad9361_set_rx_rf_gain(ad9361_phy, 1, (int32_t) cmd_infowr);
		ad9361_get_rx_rf_gain(ad9361_phy, 1, &cmd_inford3);
		cmd_inford = (uint64_t) cmd_inford3;
		break;
	case 14: /* FPGA input-delay load */
		if (wr_rdn){
			AXI_REG_WRITE(axi_lite_addr, 10 * 4, 0x00);		//idly_en_vtc
			AXI_REG_WRITE(axi_lite_addr, 12 * 4, cmd_infowr);//idly_d
			AXI_REG_WRITE(axi_lite_addr, 11 * 4, 0x7F);		//idly_load
			AXI_REG_WRITE(axi_lite_addr, 11 * 4, 0x00);		//idly_load
			AXI_REG_WRITE(axi_lite_addr, 10 * 4, 0x7F);		//idly_en_vtc
		}
		cmd_inford = AXI_REG_READ(axi_lite_addr, 12 * 4);
		break;
	case 15: /* FPGA RX ramp control */
		if (wr_rdn)
			AXI_REG_WRITE(axi_lite_addr, 27 * 4, cmd_infowr); 	//rx_ramp
		cmd_inford = AXI_REG_READ(axi_lite_addr, 27 * 4);
		break;
	case 16: /* RX external LO selection */
		if (wr_rdn)
			ad9361_set_rx_lo_int_ext(ad9361_phy, (uint8_t) cmd_infowr);
		cmd_inford = ad9361_phy->pdata->use_ext_rx_lo;
		break;
	case 17: /* Reserved legacy command */
		if (wr_rdn)
		cmd_inford = 0;
		break;
	case 19: /* Board TX/RX switch */
		gpio_set_value(TRX_SW, (int) cmd_infowr);
		cmd_inford = cmd_infowr;
		break;
	case 22: /* PPS source selection */
		if (wr_rdn)
			AXI_REG_WRITE(axi_lite_addr, 2 * 4, (uint32_t ) cmd_infowr);//PPS mode
		cmd_inford = AXI_REG_READ(axi_lite_addr, 2 * 4);
		break;
	case 23: /* FPGA master time start */
		if (wr_rdn) {
			AXI_REG_WRITE(axi_lite_addr, 1 * 4, (uint32_t ) cmd_infowr); //mtime_start
			if ((cmd_infowr & 0x1) == 0) {
				cmd_inford1 = AXI_REG_READ(axi_lite_addr, 4 * 4); //rx_chan_en
			}
		}
		cmd_inford = AXI_REG_READ(axi_lite_addr, 1 * 4);
		break;
	case 24: /* TX cyclic mode */
		if (wr_rdn)
			AXI_REG_WRITE(axi_lite_addr, 51 * 4, (uint32_t ) cmd_infowr); //tx_cyclic
		cmd_inford = AXI_REG_READ(axi_lite_addr, 51 * 4);
		break;
	case 25: /* AUXDAC1 voltage (mV) */
		if (wr_rdn)
			ad9361_set_auxdac1(ad9361_phy, (uint32_t) cmd_infowr);
		cmd_inford = ad9361_phy->auxdac1_value;
		break;
	case 26: /* Reserved legacy command */
		if (wr_rdn)
		cmd_inford = 0;
		break;
	case 27: /* Board FDD/TDD selection */
		if (wr_rdn)
			gpio_set_value(FDD_TDD_SEL, (int) cmd_infowr);
		cmd_inford = cmd_infowr;
		break;
	case 28: /* FPGA master time readback */
		cmd_inford = (uint64_t) AXI_REG_READ(axi_lite_addr, 17 * 4)
				<< 32 | AXI_REG_READ(axi_lite_addr, 16 * 4);
		break;
	case 29: /* TX overtime counters */
		cmd_inford1 = AXI_REG_READ(axi_lite_addr, (18 + ad9361_id * 2) * 4);
		cmd_inford = AXI_REG_READ(axi_lite_addr, (18 + ad9361_id * 2 + 1) * 4);
		cmd_inford = cmd_inford << 32 | cmd_inford1;
		break;
	case 31: /* TX underflow counters; legacy fall-through into case 32 */
		cmd_inford1 = AXI_REG_READ(axi_lite_addr, (32 + ad9361_id * 2) * 4);
		cmd_inford = AXI_REG_READ(axi_lite_addr, (32 + ad9361_id * 2 + 1) * 4);
		cmd_inford = cmd_inford << 32 | cmd_inford1;
		/* Legacy behavior: fall through and overwrite the response. */
	case 32: /* RX overflow counters */
		cmd_inford1 = AXI_REG_READ(axi_lite_addr, 36 * 4);
		cmd_inford = AXI_REG_READ(axi_lite_addr, 36 * 4);
		cmd_inford = cmd_inford << 32 | cmd_inford1;
		break;
	case 33: /* TX FIFO read counters */
		cmd_inford1 = AXI_REG_READ(axi_lite_addr, (40 + ad9361_id * 2) * 4);
		cmd_inford = AXI_REG_READ(axi_lite_addr, (40 + ad9361_id * 2 + 1) * 4);
		cmd_inford = cmd_inford << 32 | cmd_inford1;
		break;
	case 34: /* RX FIFO read counters */
		cmd_inford1 = AXI_REG_READ(axi_lite_addr, 44 * 4);
		cmd_inford = AXI_REG_READ(axi_lite_addr, 44 * 4);
		cmd_inford = cmd_inford << 32 | cmd_inford1;
		break;
	case 38: /* Raw GPS time */
		cmd_inford = AXI_REG_READ(axi_lite_addr, 101 * 4)
		| ((uint64_t) AXI_REG_READ(axi_lite_addr, 102 * 4)) << 32;
		break;
	case 39: /* Raw GPS longitude */
		cmd_inford = AXI_REG_READ(axi_lite_addr, 105 * 4)
		| ((uint64_t) AXI_REG_READ(axi_lite_addr, 106 * 4)) << 32;
		break;
	case 40: /* Raw GPS latitude */
		cmd_inford = AXI_REG_READ(axi_lite_addr, 103 * 4)
		| ((uint64_t) AXI_REG_READ(axi_lite_addr, 104 * 4)) << 32;
		break;
	case 41: /* Raw GPS altitude */
		cmd_inford = AXI_REG_READ(axi_lite_addr, 107 * 4)
		| ((uint64_t) AXI_REG_READ(axi_lite_addr, 108 * 4)) << 32;
		break;
	case 42: /* Raw GPS status */
		cmd_inford = AXI_REG_READ(axi_lite_addr, 109 * 4)
		| ((uint64_t) AXI_REG_READ(axi_lite_addr, 110 * 4)) << 32;
		break;
	case 43: /* RX channel selection and reset */
		if (wr_rdn) {
			if ((uint32_t) cmd_infowr >= 16)
				dev_id = 1;
			if (dev_id == rf_id) {
				cmd_infowr = cmd_infowr >> (dev_id * 4) & 0xf;
				AXI_REG_WRITE(axi_lite_addr, 4 * 4, (uint32_t ) cmd_infowr); //rx_chan_en
				AXI_REG_WRITE(axi_lite_addr, 5 * 4, dev_id); //mod_index
				if (cmd_infowr == 0)
					AXI_REG_WRITE(axi_lite_addr, 7 * 4, 0); 	//rx_reset
				else
					AXI_REG_WRITE(axi_lite_addr, 7 * 4, 1); 	//rx_reset
			}
		}
		cmd_inford = AXI_REG_READ(axi_lite_addr, 4 * 4);
		break;
	case 44: /* RX length */
		if (wr_rdn)
			AXI_REG_WRITE(axi_lite_addr, 6 * 4, (uint32_t ) cmd_infowr); //rx_length
		cmd_inford = AXI_REG_READ(axi_lite_addr, 6 * 4);
		break;
	case 64: /* FPGA TX/RX switch enable */
		if (wr_rdn)
			AXI_REG_WRITE(axi_lite_addr, 61 * 4, (uint32_t) cmd_infowr); //trxsw_enable
		cmd_inford = AXI_REG_READ(axi_lite_addr, 61 * 4);
		break;
	case 65: /* TX on delay */
		if (wr_rdn)
			AXI_REG_WRITE(axi_lite_addr, 52 * 4, (uint32_t) cmd_infowr); //tx_on_delay
		cmd_inford = AXI_REG_READ(axi_lite_addr, 52 * 4);
		break;
	case 66: /* TX off delay */
		if (wr_rdn)
			AXI_REG_WRITE(axi_lite_addr, 60 * 4, (uint32_t) cmd_infowr); //tx_off_delay
		cmd_inford = AXI_REG_READ(axi_lite_addr, 60 * 4);
		break;
	case 70: /* RX FIFO threshold with existing bounds */
		if (wr_rdn){
			uint32_t rxfifo_pfull = (uint32_t) cmd_infowr;
			if (rxfifo_pfull >= 1020*1024*1024)
				rxfifo_pfull = 1020*1024*1024;
			else if(rxfifo_pfull < 30000)
				rxfifo_pfull = 30000;
			AXI_REG_WRITE(axi_lite_addr, 48 * 4, rxfifo_pfull); 	//rxfifo_pfull
		}
		cmd_inford = AXI_REG_READ(axi_lite_addr, 48 * 4);
		break;
	case 71: /* Reported minimum sample rate */
		cmd_inford = 550000;
		break;
	case 72: /* Reported maximum sample rate */
		cmd_inford = 61440000;
		break;
	case 73: /* Reported minimum TX LO frequency */
		cmd_inford = 70e6;
		break;
	case 74: /* Reported maximum TX LO frequency */
		cmd_inford = 6000e6;
		break;
	case 75: /* Reported minimum RX LO frequency */
		cmd_inford = 70e6;
		break;
	case 76: /* Reported maximum RX LO frequency */
		cmd_inford = 6000e6;
		break;
	case 77: /* Reported minimum TX attenuation */
		cmd_inford = 0;
		break;
	case 78: /* Reported maximum TX attenuation */
		cmd_inford = 89000;
		break;
	case 79: /* Reported minimum RX gain */
		cmd_inford = 0;
		break;
	case 80: /* Reported maximum RX gain */
		cmd_inford = 73;
		break;
	case 81: /* AD9361 temperature; legacy fall-through below */
		tempa = ad9361_get_temp(ad9361_phy);
		cmd_inford = (uint64_t) tempa;
		/* Legacy behavior: fall through and overwrite the response. */
	case 100: /* FPGA firmware version */
		cmd_inford = AXI_REG_READ(axi_lite_addr, 100 * 4);
		break;
	case 101: /* Software version */
		cmd_inford = sw_ver;
		break;
	case 102: /* Legacy model identifier */
		cmd_inford = 7050;
		break;
	case 103: /* Reported RF channel count */
		cmd_inford = 2;
		break;
	case 128: /* Legacy accessory version */
		cmd_inford = 0;
		break;
	case 129: /* Reported device count */
		cmd_inford = 1;
		break;
	case 130: /* FPGA link status */
		cmd_inford = AXI_REG_READ(axi_lite_addr, 79 * 4);
		break;
	case 131: /* Legacy firmware date identifier */
		cmd_inford = 0x20220525;
		break;
	case 255: /* Unsupported RF chip ID echo */
		cmd_inford = cmd_infowr;
		break;
	default:
		cmd_inford = cmd_infowr;
		break;
	}
	/* Publish low/high response words, then pulse command-complete. */
	*fsm = IDEL;
	AXI_REG_WRITE(axi_lite_addr, 58 * 4, (uint32_t )(cmd_inford & 0xFFFFFFFF));
	AXI_REG_WRITE(axi_lite_addr, 59 * 4,
			(uint32_t )(cmd_inford >> 32 & 0xFFFFFFFF));
	AXI_REG_WRITE(axi_lite_addr, 57 * 4, 1);
	AXI_REG_WRITE(axi_lite_addr, 57 * 4, 0);
	return 0;
}

