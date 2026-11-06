/*
 * xadc.c
 *
 *  Created on: 2020Äê1ÔÂ22ÈÕ
 *      Author: lichen
 */
#include "xadc.h"

#include <stdio.h>
static XSysMon SysMonInst;
int xadc_initial(u16 XAdcDeviceId) {
	int Status;
	XSysMon_Config *ConfigPtr;
	ConfigPtr = XSysMon_LookupConfig(XAdcDeviceId);
	if (ConfigPtr == NULL) {
		return XST_FAILURE;
	}
	XSysMon_CfgInitialize(&SysMonInst, ConfigPtr, ConfigPtr->BaseAddress);
	XSysMon_SetSequencerMode(&SysMonInst, XSM_SEQ_MODE_SAFE);
	XSysMon_SetSeqChEnables(&SysMonInst, XSM_SEQ_CH_TEMP);
	XSysMon_SetSequencerMode(&SysMonInst,XSM_SEQ_MODE_CONTINPASS);
	return XST_SUCCESS;
}
int xadc_read_temp(float *Temp) {
	u32 TempRawData;
	float TempData;
	TempRawData = XSysMon_GetAdcData(&SysMonInst, XSM_CH_TEMP);
	TempData = XSysMon_RawToTemperature(TempRawData);
	*Temp = TempData;
	return XST_SUCCESS;
}
