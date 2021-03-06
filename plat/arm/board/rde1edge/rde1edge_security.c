/*
 * Copyright (c) 2019-2021, Arm Limited. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <platform_def.h>

#include <common/debug.h>
#include <sgi_dmc620_tzc_regions.h>

uintptr_t rde1edge_dmc_base[] = {
	RDE1EDGE_DMC620_BASE0,
	RDE1EDGE_DMC620_BASE1
};

static const tzc_dmc620_driver_data_t rde1edge_plat_driver_data = {
	.dmc_base = rde1edge_dmc_base,
	.dmc_count = ARRAY_SIZE(rde1edge_dmc_base)
};

static const tzc_dmc620_acc_addr_data_t rde1edge_acc_addr_data[] = {
	CSS_SGI_DMC620_TZC_REGIONS_DEF
};

static const tzc_dmc620_config_data_t rde1edge_plat_config_data = {
	.plat_drv_data = &rde1edge_plat_driver_data,
	.plat_acc_addr_data = rde1edge_acc_addr_data,
	.acc_addr_count = ARRAY_SIZE(rde1edge_acc_addr_data)
};

/* Initialize the secure environment */
void plat_arm_security_setup(void)
{
	arm_tzc_dmc620_setup(&rde1edge_plat_config_data);
}
