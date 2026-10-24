/**
 * @file INTR_IRQHandler.h
 * @brief AXI-Lite command interrupt setup and foreground dispatch.
 *
 * Original board interrupt author: liche.
 */
#ifndef SRC_INTR_IRQHANDLER_H_
#define SRC_INTR_IRQHANDLER_H_

#include "platform.h"

extern intr_cmd intr_cmd_param;
extern uint32_t axi_lite_addr;
extern uint32_t axi_lite_intr_id;
extern fsm_status fsm;

int interrupt_setup(void);
void INTR_IRQHandler(void);

/* Run in the main loop after the interrupt captures a command. */
int intr_irq_proc(intr_cmd intr_cmd_param, fsm_status *fsm);

#endif /* SRC_INTR_IRQHANDLER_H_ */
