/**
 * @file gps_read.c
 * @brief Decode the FPGA GPS register snapshot into time and location fields.
 */
#include "gps_read.h"
#include <stdio.h>
#include <math.h>
extern uint32_t axi_lite_addr;

/* Reverse the FPGA byte order to reconstruct a MicroBlaze double. */
double ntohlf(uint64_t p) {
	DOUBLEType tmpf;
	tmpf.b.llo1 = p >> 56 & 0xff;
	tmpf.b.lo1 = p >> 48 & 0xff;
	tmpf.b.hi1 = p >> 40 & 0xff;
	tmpf.b.hhi1 = p >> 32 & 0xff;
	tmpf.b.llo2 = p >> 24 & 0xff;
	tmpf.b.lo2 = p >> 16 & 0xff;
	tmpf.b.hi2 = p >> 8 & 0xff;
	tmpf.b.hhi2 = p & 0xff;

	return tmpf.f;
}
uint32_t gps_read_info(gps_info *info) {

	uint64_t time = AXI_REG_READ(axi_lite_addr, 101 * 4)
			| ((uint64_t) AXI_REG_READ(axi_lite_addr, 102 * 4)) << 32;
	uint64_t latitude = AXI_REG_READ(axi_lite_addr, 103 * 4)
			| ((uint64_t) AXI_REG_READ(axi_lite_addr, 104 * 4)) << 32;
	uint64_t longitude = AXI_REG_READ(axi_lite_addr, 105 * 4)
			| ((uint64_t) AXI_REG_READ(axi_lite_addr, 106 * 4)) << 32;
	uint64_t altitude = AXI_REG_READ(axi_lite_addr, 107 * 4)
			| ((uint64_t) AXI_REG_READ(axi_lite_addr, 108 * 4)) << 32;

	info->g_location.time = time;
	info->g_location.latitude= latitude;
	info->g_location.longitude= longitude;
	info->g_location.altitude=altitude;

	info->g_location.time_24h.second = time & 0xff;
	info->g_location.time_24h.minute = (time >> 8) & 0xff;
	/* Legacy display offset: UTC+8 without date rollover normalization. */
	info->g_location.time_24h.hour = ((time >> 16) & 0xff) + 8;
	info->g_location.time_24h.day = (time >> 24) & 0xff;
	info->g_location.time_24h.month = (time >> 32) & 0xff;
	uint32_t year1 = (((uint32_t) PP_HTONL_v3(time >> 40) >> 16) & 0xffff);
	info->g_location.time_24h.year = year1;

	info->g_location.longitude_f = ntohlf(longitude) * 180 / M_PI;
	info->g_location.latitude_f = ntohlf(latitude) * 180 / M_PI;
	info->g_location.altitude_f = ntohlf(altitude);

	uint64_t status = AXI_REG_READ(axi_lite_addr, 109 * 4)
			| ((uint64_t) AXI_REG_READ(axi_lite_addr, 110 * 4)) << 32;
	info->g_status.receiver_mode = status & 0xff;
	info->g_status.disciplining_mode = (status >> 8) & 0xff;
	info->g_status.minor_alarms = (status >> 16) & 0xff;
	info->g_status.gnss_decoding_status = (status >> 32) & 0xff;
	info->g_status.disciplining_activity = (status >> 40) & 0xff;
	info->g_status.pps_indication = (status >> 48) & 0xff;
	info->g_status.pps_reference = (status >> 56) & 0xff;

	return info->g_status.gnss_decoding_status;
}
