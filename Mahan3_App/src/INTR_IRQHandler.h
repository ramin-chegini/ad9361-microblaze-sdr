/*
 * INTR_IRQHandler.h
 *
 *  Created on: 2018Äê1ÔÂ24ÈÕ
 *      Author: liche
 */

#ifndef SRC_INTR_IRQHANDLER_H_
#define SRC_INTR_IRQHANDLER_H_

#include "platform.h"
uint32_t val_out;


extern intr_cmd intr_cmd_param;
extern uint32_t axi_lite_addr;
extern uint32_t axi_lite_intr_id;
extern fsm_status fsm;

int interrupt_setup(void);
void INTR_IRQHandler();

//void INTR_IRQHandler() {
//	val_out = AXI_REG_READ(axi_lite_addr, 54 * 4);
//	intr_cmd_param.ad9361_id = val_out >> 12 & 0xF;
//	intr_cmd_param.wr_rdn = val_out >> 8 & 0xF;
//	intr_cmd_param.cmd_num = val_out & 0xFF;
//	val_out = AXI_REG_READ(axi_lite_addr, 55 * 4);
//	intr_cmd_param.cmd_infowr = (uint64_t)AXI_REG_READ(axi_lite_addr, 56 * 4) <<32 | val_out;
//	fsm=CMD_IRQ;
//
//}

#endif /* SRC_INTR_IRQHANDLER_H_ */
