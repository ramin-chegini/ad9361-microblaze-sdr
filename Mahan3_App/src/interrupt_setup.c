/***************************** Include Files *********************************/

#include "xparameters.h"
#include "xstatus.h"
#include "xintc.h"
#include "xil_exception.h"
#include "xil_printf.h"

#include "INTR_IRQHandler.h"

#define INTC_DEVICE_ID		  XPAR_INTC_0_DEVICE_ID

/************************** Variable Definitions *****************************/

static XIntc InterruptController; /* Instance of the Interrupt Controller */

/*
 * Create a shared variable to be used by the main thread of processing and
 * the interrupt processing
 */
volatile static int InterruptProcessed = FALSE;

/*****************************************************************************/
/**
 *
 * This is the main function for the Interrupt Controller example.
 *
 * @param	None.
 *
 * @return	XST_SUCCESS to indicate success, otherwise XST_FAILURE.
 *
 * @note		None.
 *
 ****************************************************************************/
int interrupt_setup(void) {
	int Status;

	/*
	 * Initialize the interrupt controller driver so that it is ready to
	 * use.
	 */
	Status = XIntc_Initialize(&InterruptController, INTC_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Perform a self-test to ensure that the hardware was built
	 * correctly.
	 */
	Status = XIntc_SelfTest(&InterruptController);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Connect a device driver handler that will be called when an interrupt
	 * for the device occurs, the device driver handler performs the
	 * specific interrupt processing for the device.
	 */
	Status = XIntc_Connect(&InterruptController, axi_lite_intr_id,
			(XInterruptHandler) INTR_IRQHandler, (void *) 0);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Start the interrupt controller such that interrupts are enabled for
	 * all devices that cause interrupts, specify simulation mode so that
	 * an interrupt can be caused by software rather than a real hardware
	 * interrupt.
	 */
	Status = XIntc_Start(&InterruptController, XIN_REAL_MODE);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Enable the interrupt for the device and then cause (simulate) an
	 * interrupt so the handlers will be called.
	 */
	XIntc_Enable(&InterruptController, axi_lite_intr_id);

	/*
	 * Initialize the exception table.
	 */
	Xil_ExceptionInit();

	/*
	 * Register the interrupt controller handler with the exception table.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			(Xil_ExceptionHandler) XIntc_InterruptHandler,
			&InterruptController);

	/*
	 * Enable exceptions.
	 */
	Xil_ExceptionEnable();

	xil_printf("Successful Setup\r\n");
	return XST_SUCCESS;

}

void INTR_IRQHandler() {
	val_out = AXI_REG_READ(axi_lite_addr, 54 * 4);
	intr_cmd_param.ad9361_id = val_out >> 12 & 0xF;
	intr_cmd_param.wr_rdn = val_out >> 8 & 0xF;
	intr_cmd_param.cmd_num = val_out & 0xFF;
	val_out = AXI_REG_READ(axi_lite_addr, 55 * 4);
	intr_cmd_param.cmd_infowr = (uint64_t) AXI_REG_READ(axi_lite_addr, 56 * 4) << 32 | val_out;
	fsm = CMD_IRQ;

	// interrupt clear routine must be written here ...

	AXI_REG_WRITE(axi_lite_addr, 52 * 4, 1); // irq_ctrl in hdl
	mdelay(1);
	AXI_REG_WRITE(axi_lite_addr, 52 * 4, 0); // irq_ctrl in hdl

	printf(" Interrupt ");

}
