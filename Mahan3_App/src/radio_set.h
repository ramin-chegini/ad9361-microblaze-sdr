/**
 * @file radio_set.h
 * @brief Board AD9361 defaults and FIR profiles defined in radio_set.c.
 *
 * Original board configuration author: liche.
 */
#ifndef SRC_RADIO_SET_H_
#define SRC_RADIO_SET_H_

#include "ad9361_api.h"

extern AD9361_InitParam default_init_param;

/* Suffixes identify interpolation/decimation factor and coefficient count. */
extern AD9361_RXFIRConfig rx_fir_config_4_128;
extern AD9361_TXFIRConfig tx_fir_config_4_128;
extern AD9361_RXFIRConfig rx_fir_config_2_128;
extern AD9361_TXFIRConfig tx_fir_config_2_128;
extern AD9361_RXFIRConfig rx_fir_config_2_96;
extern AD9361_TXFIRConfig tx_fir_config_2_96;
extern AD9361_RXFIRConfig rx_fir_config_2_64;
extern AD9361_TXFIRConfig tx_fir_config_2_64;

#endif /* SRC_RADIO_SET_H_ */
