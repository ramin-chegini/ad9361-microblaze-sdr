/* //////////////// Ramin: BEGIN verified TX LO command ////////////////// */
#ifndef CALIBRATOR_VERIFY_H
#define CALIBRATOR_VERIFY_H
#define CAL_LO_TOLERANCE_HZ 100ULL
#define CAL_LOCK_POLLS 2000
#define CAL_LOCK_STABLE_READS 4
/* Internal result codes: 0 OK, 6 setter, 7 frequency, 8 unlock,
 * 9 controller timeout, 10 SPI/readback, 11 unsupported external/fastlock LO. */
static int32_t calibrator_verify_tx_lo(struct ad9361_rf_phy *phy,
                                      uint64_t target, uint64_t *actual)
{
    uint8_t b[5];
    int32_t ret, divider, lock;
    uint32_t stable=0, n, integer, fraction;
    uint64_t parent, rate, difference;
    *actual=0;
    if (phy->pdata->use_ext_tx_lo || phy->fastlock.current_profile[1]) return 11;
    /* Ramin: clk_set_rate skips an unchanged cached rate. Clear only the
     * software TX rate cache so retry really reprograms the SAME RF frequency. */
    phy->clks[TX_RFPLL]->rate=0;
    ret=ad9361_set_tx_lo_freq(phy,target);
    if (ret<0) return 6;
    ret=ad9361_spi_readm(phy->spi,REG_TX_FRACT_BYTE_2,b,5);
    if (ret<0) return 10;
    divider=ad9361_spi_read(phy->spi,REG_RFPLL_DIVIDERS);
    if (divider<0) return 10;
    fraction=((uint32_t)SYNTH_FRACT_WORD(b[0])<<16)|((uint32_t)b[1]<<8)|b[2];
    integer=((uint32_t)SYNTH_INTEGER_WORD(b[3])<<8)|b[4];
    parent=phy->clks[TX_REFCLK]->rate;
    if (!parent) return 10;
    rate=parent*fraction/RFPLL_MODULUS+parent*integer;
    *actual=rate>>((((uint32_t)divider>>4)&15)+1);
    difference=*actual>target ? *actual-target : target-*actual;
    if (difference>CAL_LO_TOLERANCE_HZ) return 7;
    for (n=0;n<CAL_LOCK_POLLS;n++) {
        lock=ad9361_spi_read(phy->spi,REG_TX_CP_OVERRANGE_VCO_LOCK);
        if (lock<0) return 10;
        if (lock & VCO_LOCK) {
            if (++stable==CAL_LOCK_STABLE_READS) return 0;
        } else stable=0;
        udelay(10);
    }
    return 8;
}
#endif
/* //////////////// Ramin: END verified TX LO command ////////////////// */
