/**
 * @file ad9361_config.h
 * @brief Apply board RF settings and select sample-rate-dependent FIR profiles.
 *
 * Original board configuration author: liche.
 */
#ifndef SRC_AD9361_CONFIG_H_
#define SRC_AD9361_CONFIG_H_

#include "ad9361.h"

/* Apply startup settings and return the selected AD9361 register readback. */
int32_t ad9361_config(struct ad9361_rf_phy *ad9361_phy);

/* sample_freq is in Hz and receives the actual TX sampling frequency. */
int32_t ad9361_set_sample(struct ad9361_rf_phy *ad9361_phy,
        uint32_t *sample_freq);

#endif /* SRC_AD9361_CONFIG_H_ */
