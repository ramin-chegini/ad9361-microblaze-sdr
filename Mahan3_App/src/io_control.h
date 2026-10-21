/**
 * @file io_control.h
 * @brief Access 32-bit registers in the custom FPGA AXI-Lite peripheral.
 *
 * Original board control author: liche.
 */
#ifndef SRC_IO_CONTROL_H_
#define SRC_IO_CONTROL_H_

#include "xil_io.h"

/* RegOffset is a byte offset; board register indices are multiplied by four. */
#define AXI_REG_WRITE(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define AXI_REG_READ(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

#endif /* SRC_IO_CONTROL_H_ */
