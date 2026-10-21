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
	case 1:
		if (wr_rdn)
			ad9361_spi_write(ad9361_phy->spi,
					(uint32_t) (cmd_infowr & 0xFFFFFFFF),
					(uint32_t) (cmd_infowr >> 32 & 0xFFFFFFFF));
		cmd_inford2 = ad9361_spi_read(ad9361_phy->spi,
				(uint32_t) (cmd_infowr & 0xFFFFFFFF));
		cmd_inford = (uint64_t) cmd_inford2;
//		printf("id_no%d,reg[%lx]=%d\n", ad9361_phy->spi->id_no,
//				(uint32_t) cmd_infowr, cmd_inford2);
		break;
	case 2:
		if (wr_rdn) {
			ad9361_set_tx_lo_freq(ad9361_phy, cmd_infowr);
		}
		ad9361_get_tx_lo_freq(ad9361_phy, &cmd_inford);
//		printf("id_no%d,tx_lo_freq=%lluHz\n", ad9361_phy->spi->id_no,
//				cmd_inford);
		break;
	case 3:
		if (wr_rdn) {
			sample_rate = (uint32_t) cmd_infowr;
			ad9361_set_sample(ad9361_phy, &sample_rate);
			AXI_REG_WRITE(axi_lite_addr, 3 * 4, sample_rate); 	//sample_1pps
			AXI_REG_WRITE(axi_lite_addr, 29 * 4, sample_rate << 2);	//clock_1pps
		}
		ad9361_get_tx_sampling_freq(ad9361_phy, &cmd_inford1);
		cmd_inford = (uint64_t) sample_rate;
//		printf("id_no%d,sample_freq=%lluHz\n", ad9361_phy->spi->id_no,
//				cmd_inford);
		break;
	case 4:
		if (wr_rdn){
			ad9361_set_tx_rf_bandwidth(ad9361_phy, (uint32_t) cmd_infowr);
		}
		ad9361_get_tx_rf_bandwidth(ad9361_phy, &cmd_inford1);
		cmd_inford = (uint64_t) cmd_inford1;
//		printf("id_no%d,tx_rf_bandwidth=%luHz\n", ad9361_phy->spi->id_no,
//				cmd_inford1);
		break;
	case 5:
		if (wr_rdn)
			ad9361_set_tx_attenuation(ad9361_phy, 0, (uint32_t) cmd_infowr);
		ad9361_get_tx_attenuation(ad9361_phy, 0, &cmd_inford1);
		cmd_inford = (uint64_t) cmd_inford1;
//		printf("id_no%d,tx_tx_att1=%ludB\n", ad9361_phy->spi->id_no,
//				cmd_inford1 / 1000);
		break;
	case 6:
		if (wr_rdn)
			ad9361_set_tx_attenuation(ad9361_phy, 1, (uint32_t) cmd_infowr);
		ad9361_get_tx_attenuation(ad9361_phy, 1, &cmd_inford1);
		cmd_inford = (uint64_t) cmd_inford1;
//		printf("id_no%d,tx_tx_att2=%ludB\n", ad9361_phy->spi->id_no,
//				cmd_inford1 / 1000);
		break;
	case 7:
//		if (wr_rdn){
//			ad9361_set_trx_fir_en_dis(ad9361_phy, (uint8_t) cmd_infowr);
//		}
		ad9361_get_tx_fir_en_dis(ad9361_phy, &cmd_inford2);
		cmd_inford = (uint64_t) cmd_inford2;
//		printf("id_no%d,tx_fir_en=%d\n", ad9361_phy->spi->id_no, cmd_inford2);
		break;
	case 8:
		if (wr_rdn) {
			ad9361_set_rx_lo_freq(ad9361_phy, cmd_infowr);
		}
		ad9361_get_rx_lo_freq(ad9361_phy, &cmd_inford);
//		printf("id_no%d,rx_lo_freq=%lluHz\n", ad9361_phy->spi->id_no,
//				cmd_inford);
		break;
	case 9:
		if (wr_rdn){
			ad9361_set_rx_rf_bandwidth(ad9361_phy, (uint32_t) cmd_infowr);
		}
		ad9361_get_rx_rf_bandwidth(ad9361_phy, &cmd_inford1);
		cmd_inford = (uint64_t) cmd_inford1;
//		printf("id_no%d,rx_rf_bandwidth=%luHz\n", ad9361_phy->spi->id_no,
//				cmd_inford1);
		break;
	case 10:
		if (wr_rdn)
			ad9361_set_rx_gain_control_mode(ad9361_phy, 0,
					(uint8_t) cmd_infowr);
		ad9361_get_rx_gain_control_mode(ad9361_phy, 0, &cmd_inford2);
		cmd_inford = (uint64_t) cmd_inford2;
//		printf("id_no%d,rx1_gain_control_mode=%d\n", ad9361_phy->spi->id_no,
//				cmd_inford2);
		break;
	case 11:
		if (wr_rdn)
			ad9361_set_rx_gain_control_mode(ad9361_phy, 1,
					(uint8_t) cmd_infowr);
		ad9361_get_rx_gain_control_mode(ad9361_phy, 1, &cmd_inford2);
		cmd_inford = (uint64_t) cmd_inford2;
//		printf("id_no%d,rx2_gain_control_mode=%d\n", ad9361_phy->spi->id_no,
//				cmd_inford2);
		break;
	case 12:
		if (wr_rdn)
			ad9361_set_rx_rf_gain(ad9361_phy, 0, (int32_t) cmd_infowr);
		ad9361_get_rx_rf_gain(ad9361_phy, 0, &cmd_inford3);
		cmd_inford = (uint64_t) cmd_inford3;
//		printf("id_no%d,rx1_rf_gain=%lddB\n", ad9361_phy->spi->id_no,
//				cmd_inford3);
		break;
	case 13:
		if (wr_rdn)
			ad9361_set_rx_rf_gain(ad9361_phy, 1, (int32_t) cmd_infowr);
		ad9361_get_rx_rf_gain(ad9361_phy, 1, &cmd_inford3);
		cmd_inford = (uint64_t) cmd_inford3;
//		printf("id_no%d,rx2_rf_gain=%lddB\n", ad9361_phy->spi->id_no,
//				cmd_inford3);
		break;
	case 14:
		if (wr_rdn){
			AXI_REG_WRITE(axi_lite_addr, 10 * 4, 0x00);		//idly_en_vtc
			AXI_REG_WRITE(axi_lite_addr, 12 * 4, cmd_infowr);//idly_d
			AXI_REG_WRITE(axi_lite_addr, 11 * 4, 0x7F);		//idly_load
			AXI_REG_WRITE(axi_lite_addr, 11 * 4, 0x00);		//idly_load
			AXI_REG_WRITE(axi_lite_addr, 10 * 4, 0x7F);		//idly_en_vtc
//			ad9361_set_trx_fir_en_dis(ad9361_phy, (uint8_t) cmd_infowr);
		}
//		ad9361_get_rx_fir_en_dis(ad9361_phy, &cmd_inford2);
		cmd_inford = AXI_REG_READ(axi_lite_addr, 12 * 4);
//		printf("id_no%d,rx_fir_en=%d\n", ad9361_phy->spi->id_no, cmd_inford2);
//		printf("idly_d=%lld\n", cmd_inford);
		break;
	case 15:
		if (wr_rdn)
			AXI_REG_WRITE(axi_lite_addr, 27 * 4, cmd_infowr); 	//rx_ramp
		//printf("ad9371 doesn't support set tx_lo_int_ext!\n");
		cmd_inford = AXI_REG_READ(axi_lite_addr, 27 * 4);
		//printf("id_no%d,tx_lo_int_ext=%lld\n", ad9361_id, cmd_inford);
//		printf("rx_ramp=%lld\n", cmd_inford);
		break;
	case 16:
		if (wr_rdn)
			ad9361_set_rx_lo_int_ext(ad9361_phy, (uint8_t) cmd_infowr);
		cmd_inford = ad9361_phy->pdata->use_ext_rx_lo;
//		printf("id_no%d,rx_lo_int_ext=%d\n", ad9361_phy->spi->id_no,
//				(uint8_t) cmd_inford);
		break;
	case 17:
		if (wr_rdn)
//			printf("ad9371 doesn't support set ext_lo_freq!\n");
		cmd_inford = 0;
		break;
	case 19:
		gpio_set_value(TRX_SW, (int) cmd_infowr);
		cmd_inford = cmd_infowr;
//		printf("TRX_SW=%d\n", (uint8_t) cmd_inford);
		break;
	case 22:
		if (wr_rdn)
			AXI_REG_WRITE(axi_lite_addr, 2 * 4, (uint32_t ) cmd_infowr);//PPS mode
		cmd_inford = AXI_REG_READ(axi_lite_addr, 2 * 4);
//		printf(
//				"PPS mode=%d(0=internal logic gen pps; 1=GPS pps;)\n",
//				(uint8_t) cmd_inford);
		break;
	case 23:
		if (wr_rdn) {
			AXI_REG_WRITE(axi_lite_addr, 1 * 4, (uint32_t ) cmd_infowr); //mtime_start
			if ((cmd_infowr & 0x1) == 0) {
				cmd_inford1 = AXI_REG_READ(axi_lite_addr, 4 * 4); //rx_chan_en
//				AXI_REG_WRITE(axi_lite_addr, 4 * 4, 0); //rx_chan_en
//				AXI_REG_WRITE(axi_lite_addr, 7 * 4, 0); //rx_reset
//				mdelay(1);
//				AXI_REG_WRITE(axi_lite_addr, 4 * 4, cmd_inford1); //rx_chan_en
//				AXI_REG_WRITE(axi_lite_addr, 7 * 4, 1); //rx_reset
//				printf("mtime_start=0,rx_chan_en=%lx\n", cmd_inford1);
			}
		}
		cmd_inford = AXI_REG_READ(axi_lite_addr, 1 * 4);
//		printf("mtime_start=%d\n", (uint8_t) cmd_inford);
		break;
	case 24:
		if (wr_rdn)
			AXI_REG_WRITE(axi_lite_addr, 51 * 4, (uint32_t ) cmd_infowr); //tx_cyclic
		cmd_inford = AXI_REG_READ(axi_lite_addr, 51 * 4);
//		printf("yunsdr_tx_cyclic_enable=%d\n", (uint8_t) cmd_inford);
		break;
	case 25:
		if (wr_rdn)
			ad9361_set_auxdac1(ad9361_phy, (uint32_t) cmd_infowr);
		cmd_inford = ad9361_phy->auxdac1_value;
//		printf("id_no%d,auxdac1_value=%ld\n", ad9361_phy->spi->id_no,
//				(uint32_t) cmd_inford);
		break;
	case 26:
		if (wr_rdn)
//			printf("ad9371 doesn't support set ext_lo_freq!\n");
		cmd_inford = 0;
//		printf("ext lo=%d\n", (uint8_t) cmd_inford);
		break;
	case 27:
		if (wr_rdn)
			gpio_set_value(FDD_TDD_SEL, (int) cmd_infowr);
		cmd_inford = cmd_infowr;
//		printf("FDD_TDD_SEL=%d(1=FDD;0=TDD RX SMA disable)\n",
//				(uint8_t) cmd_inford);
		break;
	case 28:
		cmd_inford = (uint64_t) AXI_REG_READ(axi_lite_addr, 17 * 4)
				<< 32 | AXI_REG_READ(axi_lite_addr, 16 * 4);
		//printf("mtime=%llu\n", cmd_inford);
		break;
	case 29:
		cmd_inford1 = AXI_REG_READ(axi_lite_addr, (18 + ad9361_id * 2) * 4);
//		printf("tx%d overtime cycls=%ld\n", ad9361_id * 2, cmd_inford1);
		cmd_inford = AXI_REG_READ(axi_lite_addr, (18 + ad9361_id * 2 + 1) * 4);
//		printf("tx%d overtime cycls=%ld\n", ad9361_id * 2 + 1, (uint32_t) cmd_inford);
		cmd_inford = cmd_inford << 32 | cmd_inford1;
		break;
	case 31:
		cmd_inford1 = AXI_REG_READ(axi_lite_addr, (32 + ad9361_id * 2) * 4);
//		printf("tx%d underflow cycls=%ld\n", ad9361_id * 2, cmd_inford1);
		cmd_inford = AXI_REG_READ(axi_lite_addr, (32 + ad9361_id * 2 + 1) * 4);
//		printf("tx%d underflow cycls=%ld\n", ad9361_id * 2 + 1, (uint32_t) cmd_inford);
		cmd_inford = cmd_inford << 32 | cmd_inford1;
	case 32:
		cmd_inford1 = AXI_REG_READ(axi_lite_addr, 36 * 4);
//		printf("rx%d overflow cycls=%ld\n", ad9361_id * 2, (uint32_t) cmd_inford1);
		cmd_inford = AXI_REG_READ(axi_lite_addr, 36 * 4);
//		printf("rx%d overflow cycls=%ld\n", ad9361_id * 2 + 1, (uint32_t) cmd_inford);
		cmd_inford = cmd_inford << 32 | cmd_inford1;
		break;
	case 33:
		cmd_inford1 = AXI_REG_READ(axi_lite_addr, (40 + ad9361_id * 2) * 4);
//		printf("tx%d fifo_rdcnt cycls=%ld\n", ad9361_id * 2, cmd_inford1);
		cmd_inford = AXI_REG_READ(axi_lite_addr, (40 + ad9361_id * 2 + 1) * 4);
//		printf("tx%d fifo_rdcnt cycls=%ld\n", ad9361_id * 2 + 1, (uint32_t) cmd_inford);
		cmd_inford = cmd_inford << 32 | cmd_inford1;
		break;
	case 34:
		cmd_inford1 = AXI_REG_READ(axi_lite_addr, 44 * 4);
//		printf("rx%d fifo_rdcnt cycls=%ld\n", ad9361_id * 2, (uint32_t) cmd_inford1);
		cmd_inford = AXI_REG_READ(axi_lite_addr, 44 * 4);
//		printf("rx%d fifo_rdcnt cycls=%ld\n", ad9361_id * 2 + 1, (uint32_t) cmd_inford);
		cmd_inford = cmd_inford << 32 | cmd_inford1;
		break;
	case 38:
		cmd_inford = AXI_REG_READ(axi_lite_addr, 101 * 4)
		| ((uint64_t) AXI_REG_READ(axi_lite_addr, 102 * 4)) << 32;
//		printf("The time value is %llx\n", cmd_inford);
		break;
	case 39:
		cmd_inford = AXI_REG_READ(axi_lite_addr, 105 * 4)
		| ((uint64_t) AXI_REG_READ(axi_lite_addr, 106 * 4)) << 32;
//		printf("The longitude value is %llx\n", cmd_inford);
		break;
	case 40:
		cmd_inford = AXI_REG_READ(axi_lite_addr, 103 * 4)
		| ((uint64_t) AXI_REG_READ(axi_lite_addr, 104 * 4)) << 32;
//		printf("The latitude value is %llx\n", cmd_inford);
		break;
	case 41:
		cmd_inford = AXI_REG_READ(axi_lite_addr, 107 * 4)
		| ((uint64_t) AXI_REG_READ(axi_lite_addr, 108 * 4)) << 32;
//		printf("The altitude value is %llx\n", cmd_inford);
		break;
	case 42:
		cmd_inford = AXI_REG_READ(axi_lite_addr, 109 * 4)
		| ((uint64_t) AXI_REG_READ(axi_lite_addr, 110 * 4)) << 32;
//		printf("The status value is %llx\n", cmd_inford);
		break;
	case 43:
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
//		printf("The dev=%ld, yunsdr_set_rx_chan_en=%d\n", dev_id,
//				(uint8_t) cmd_inford);
		break;
	case 44:
		if (wr_rdn)
			AXI_REG_WRITE(axi_lite_addr, 6 * 4, (uint32_t ) cmd_infowr); //rx_length
		cmd_inford = AXI_REG_READ(axi_lite_addr, 6 * 4);
//		printf("yunsdr_set_rx_length=%ld\n", (uint32_t) cmd_inford);
		break;
	case 64:
		if (wr_rdn)
			AXI_REG_WRITE(axi_lite_addr, 61 * 4, (uint32_t) cmd_infowr); //trxsw_enable
		cmd_inford = AXI_REG_READ(axi_lite_addr, 61 * 4);
//		printf("yunsdr_set_trxsw_fpga_enable=%d\n", (uint8_t) cmd_inford);
		break;
	case 65:
		if (wr_rdn)
			AXI_REG_WRITE(axi_lite_addr, 52 * 4, (uint32_t) cmd_infowr); //tx_on_delay
		cmd_inford = AXI_REG_READ(axi_lite_addr, 52 * 4);
//		printf("yunsdr_set_tx_on_ahead=%ld\n", (uint32_t) cmd_inford);
		break;
	case 66:
		if (wr_rdn)
			AXI_REG_WRITE(axi_lite_addr, 60 * 4, (uint32_t) cmd_infowr); //tx_off_delay
		cmd_inford = AXI_REG_READ(axi_lite_addr, 60 * 4);
//		printf("yunsdr_set_tx_off_delay=%ld\n", (uint32_t) cmd_inford);
		break;
	case 70:
		if (wr_rdn){
			uint32_t rxfifo_pfull = (uint32_t) cmd_infowr;
			if (rxfifo_pfull >= 1020*1024*1024)
				rxfifo_pfull = 1020*1024*1024;
			else if(rxfifo_pfull < 30000)
				rxfifo_pfull = 30000;
			AXI_REG_WRITE(axi_lite_addr, 48 * 4, rxfifo_pfull); 	//rxfifo_pfull
		}
		cmd_inford = AXI_REG_READ(axi_lite_addr, 48 * 4);
//		printf("rx buffer depth=%ld\n", (uint32_t) cmd_inford);
		break;
	case 71:
		cmd_inford = 550000;
//		printf("min bb_samp_freq=%lluHz\n", cmd_inford);
		break;
	case 72:
		cmd_inford = 61440000;
//		printf("max bb_samp_freq=%lluHz\n", cmd_inford);
		break;
	case 73:
		cmd_inford = 70e6;
//		printf("min rf_lo_freq %lluHz\n", cmd_inford);
		break;
	case 74:
		cmd_inford = 6000e6;
//		printf("max rf_lo_freq %lluHz\n", cmd_inford);
		break;
	case 75:
		cmd_inford = 70e6;
//		printf("min rf_lo_freq %lluHz\n", cmd_inford);
		break;
	case 76:
		cmd_inford = 6000e6;
//		printf("max rf_lo_freq %lluHz\n", cmd_inford);
		break;
	case 77:
		cmd_inford = 0;
//		printf("min tx_tx_att %lluHz\n", cmd_inford);
		break;
	case 78:
		cmd_inford = 89000;
//		printf("max tx_tx_att %lluHz\n", cmd_inford);
		break;
	case 79:
		cmd_inford = 0;
//		printf("min rx_rf_gain %lluHz\n", cmd_inford);
		break;
	case 80:
		cmd_inford = 73;
//		printf("max rx_rf_gain %lluHz\n", cmd_inford);
		break;
	case 81:
		tempa = ad9361_get_temp(ad9361_phy);
		cmd_inford = (uint64_t) tempa;
//		printf("rf1_ad9361 temp=%ld,\n", tempa);
	case 100:
		cmd_inford = AXI_REG_READ(axi_lite_addr, 100 * 4);
//		printf("The FPGA firmware version=0x%llx\n", cmd_inford);
		break;
	case 101:
		cmd_inford = sw_ver;
//		printf("The Software firmware version=0x%2lx\n", sw_ver);
		break;
	case 102:
		cmd_inford = 7050;
//		printf("The SDR model is %d\n", (uint16_t) cmd_inford);
		break;
	case 103:
		cmd_inford = 2;
//		printf("The max RF channel is %llu\n", cmd_inford);
		break;
	case 128:
		cmd_inford = 0;
//		printf("ACC card version=0x%llx\n", cmd_inford);
		break;
	case 129:
		cmd_inford = 1;
//		printf("The num of devices=%llu\n", cmd_inford);
		break;
	case 130:
		cmd_inford = AXI_REG_READ(axi_lite_addr, 79 * 4);
//		printf("PCIE width=%d,rate=%d\n", (uint16_t) (cmd_inford >> 16 & 0xf),
//				(uint16_t) (cmd_inford & 0x3));
		break;
	case 131:
		cmd_inford = 0x20220525;
//		printf("ACC card firmware coding date=%llx\n", cmd_inford);
		break;
	case 255:
		cmd_inford = cmd_infowr;
//		printf("ad9361_id=%d,wr_rdn=%d,cmd_num=%d\n", ad9361_id, wr_rdn, cmd_num);
//		printf("error:IQX7050 only contain one RFchip,RFchipID must=0 !!!\n");
		break;
	default:
		cmd_inford = cmd_infowr;
//		printf("ad9361_id=%d,wr_rdn=%d,cmd_num=%d\n", ad9361_id, wr_rdn, cmd_num);
//		printf("error:This cmd is reserved for future use!\n");
		break;
	}
	*fsm = IDEL;
	AXI_REG_WRITE(axi_lite_addr, 58 * 4, (uint32_t )(cmd_inford & 0xFFFFFFFF));
	AXI_REG_WRITE(axi_lite_addr, 59 * 4,
			(uint32_t )(cmd_inford >> 32 & 0xFFFFFFFF));
	AXI_REG_WRITE(axi_lite_addr, 57 * 4, 1);
	AXI_REG_WRITE(axi_lite_addr, 57 * 4, 0);
	return 0;
}


