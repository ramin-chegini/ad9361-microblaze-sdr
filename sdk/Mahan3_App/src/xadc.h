/** @file xadc.h
 *  @brief FPGA temperature monitoring through the BSP XSysMon driver.
 */
#ifndef SRC_XADC_H_
#define SRC_XADC_H_

#include <stdint.h>
#include "xil_types.h"
#include "xsysmon.h"
int xadc_initial(u16 XAdcDeviceId);
/* Call after successful initialization; the output is in degrees Celsius. */
int xadc_read_temp(float *Temp);

#endif /* SRC_XADC_H_ */
