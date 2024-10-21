// SPDX-License-Identifier: 0BSD

///////////////////////////////////////////////////////////////////////////////
//
/// \file       armthumb.c
/// \brief      Filter for ARM-Thumb binaries
///
//  Authors:    Igor Pavlov
//              Lasse Collin
//
///////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include "armthumb.h"

#include <zephyr/kernel.h>
#include <zephyr/logging/log.h>

LOG_MODULE_REGISTER(thumb, CONFIG_NRF_COMPRESS_LOG_LEVEL);

void arm_thumb_filter(uint8_t *buf, uint32_t buf_size, uint32_t pos, bool compress,
		      bool *end_part_match)
{
	uint32_t i = 0;
uint32_t last_update_address = 0;

LOG_ERR("start %x", (pos + i));

if (pos <= 0x7f0)
{
LOG_ERR("wtf %02x %02x %02x %02x", buf[0x7f0], buf[0x7f1], buf[0x7f2], buf[0x7f3]);
}

	while ((i + 4) <= buf_size) {
if (i == 0 && *end_part_match == true && (buf[i + 1] & 0xF8) == 0xF0)
{
LOG_ERR("hay, puchunino! %02x %02x %02x %02x", buf[i + 0], buf[i + 1], buf[i + 2], buf[i + 3]);
}

if ((pos + i) == 16380)
{
LOG_ERR("PRE: %02x %02x %02x %02x", buf[i + 0], buf[i + 1], buf[i + 2], buf[i + 3]);
}
else if ((pos + i) == 16382)
{
LOG_ERR("ACTUAL: %02x %02x %02x %02x", buf[i + 0], buf[i + 1], buf[i + 2], buf[i + 3]);
}
		if ((buf[i + 1] & 0xF8) == 0xF0 && (buf[i + 3] & 0xF8) == 0xF8) {
LOG_ERR("pos: %x", (pos + i));
			uint32_t dest;
			uint32_t src = (((uint32_t)(buf[i + 1]) & 7) << 19)
			| ((uint32_t)(buf[i + 0]) << 11)
			| (((uint32_t)(buf[i + 3]) & 7) << 8)
			| (uint32_t)(buf[i + 2]);

			src <<= 1;

//LOG_ERR("hay, puchunino! %02x %02x %02x %02x", buf[i + 0], buf[i + 1], buf[i + 2], buf[i + 3]);
last_update_address = i;

			if (compress) {
				dest = pos + (uint32_t)(i) + 4 + src;
			} else {
				dest = src - (pos + (uint32_t)(i) + 4);
			}

			dest >>= 1;
			buf[i + 1] = 0xF0 | ((dest >> 19) & 0x7);
			buf[i + 0] = (dest >> 11);
			buf[i + 3] = 0xF8 | ((dest >> 8) & 0x7);
			buf[i + 2] = (dest);

if (i == 0)
{
LOG_ERR("now %02x %02x %02x %02x", buf[i + 0], buf[i + 1], buf[i + 2], buf[i + 3]);
}
			i += 2;
		}

		i += 2;
	}

LOG_ERR("end %x", (pos + i));

LOG_ERR("%d vs %d = %02x %02x %02x %02x", i, buf_size, buf[buf_size - 4], buf[buf_size - 3], buf[buf_size - 2], buf[buf_size - 1]);
	if (i == (buf_size - 2))
{
LOG_ERR("in heir: %d vs %d and %02x", i, last_update_address, (buf[i + 1] & 0xF8));
	if (i > last_update_address && (buf[i + 1] & 0xF8) == 0xF0) {
LOG_ERR("here %02x %02x at %p, pos is %d", buf[i + 0], buf[i + 1], &buf[i + 0], (pos + i));
		*end_part_match = true;
	} else {
		*end_part_match = false;
	}
}
}
