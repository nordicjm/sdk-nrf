/*
 * Copyright (c) 2021 Nordic Semiconductor ASA
 *
 * SPDX-License-Identifier: LicenseRef-Nordic-5-Clause
 */

#include <zephyr/storage/flash_map.h>
#include <zephyr/device.h>
#include <zephyr/devicetree.h>
#include <pm_config.h>
#include <zephyr/sys/util_macro.h>

#define FLASH_MAP_PM_DEV(i) UTIL_CAT(i, _DEV)
/* I maybe either DTS node or DTS node label, so we have to figure out by existence */
#define FLASH_MAP_DEV(i)						\
	COND_CODE_1(DT_NODE_EXISTS(FLASH_MAP_PM_DEV(i)),		\
	(DEVICE_DT_GET_OR_NULL(FLASH_MAP_PM_DEV(i))),			\
	(DEVICE_DT_GET_OR_NULL(DT_NODELABEL(FLASH_MAP_PM_DEV(i)))))

#define FLASH_MAP_PM_DRIVER_KCONFIG(x) UTIL_CAT(x, _DRIVER_KCONFIG)

#define FLASH_MAP_ID(i) UTIL_CAT(i, _ID)
#define FLASH_MAP_OFFSET(i) UTIL_CAT(i, _OFFSET)
#define FLASH_MAP_SIZE(i)   UTIL_CAT(i, _SIZE)
#define FLASH_MAP_NUM       PM_NUM

/* FOR_EACH below needs list of PM_<partition>_LABEL to work with; this list
 * is generated for all paritions that have been defined by partition
 * manager, whether used by an application or not.
 */
#define FLASH_MAP_PM_SINGLE(x, _) UTIL_CAT(PM_, UTIL_CAT(PM_##x##_LABEL))
#define FLASH_MAP_PM_LIST LISTIFY(FLASH_MAP_NUM, FLASH_MAP_PM_SINGLE, (,))

/* The full list of partitions will be here cut down to partitions that
 * are defined over devices with drivers enabled in Kconfig.
 */

#define FLASH_MAP_PM_ENTRY(x)				\
	COND_CODE_1(FLASH_MAP_PM_DRIVER_KCONFIG(x),	\
		(FLASH_AREA_FOO(x)), ())

#define FLASH_AREA_FOO(i) \
	{						\
		.fa_id       = FLASH_MAP_ID(i),		\
		.fa_off      = FLASH_MAP_OFFSET(i),	\
		.fa_dev	     = FLASH_MAP_DEV(i),	\
		.fa_size     = FLASH_MAP_SIZE(i)	\
	}

const struct flash_area default_flash_map[] = {
	FOR_EACH(FLASH_MAP_PM_ENTRY, (,), FLASH_MAP_PM_LIST)
};

const int flash_map_entries = ARRAY_SIZE(default_flash_map);
const struct flash_area *flash_map = default_flash_map;
