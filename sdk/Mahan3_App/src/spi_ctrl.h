/**
 * @file spi_ctrl.h
 * @brief CDCM6208 clock control and board AD9361 AUXDAC1 helpers.
 *
 * Original board SPI helper author: liche.
 */
#ifndef SRC_SPI_CTRL_H_
#define SRC_SPI_CTRL_H_

#include "util.h"

int32_t spi_write32(struct spi_device *spi, uint32_t val);
int32_t cdcm6208_init(struct spi_device *spi);
int32_t cdcm6208_y5_internal(struct spi_device *spi);
int32_t cdcm6208_y5_external(struct spi_device *spi);
int32_t cdcm6208_spi_read(struct spi_device *spi, uint32_t reg);

/* AUXDAC1 target voltage is expressed in millivolts. */
int32_t ad9361_set_auxdac1(struct ad9361_rf_phy *phy, uint32_t val_mV);

#endif /* SRC_SPI_CTRL_H_ */
