/*
 * Copyright (c) 2016, ARM Limited and Contributors. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * Neither the name of ARM nor the names of its contributors may be used
 * to endorse or promote products derived from this software without specific
 * prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef __CORTEX_A72_H__
#define __CORTEX_A72_H__

/* Cortex-A72 midr for revision 0 */
#define CORTEX_A72_MIDR 0x410FD080

#define AARCH32_BIT_OFFSET(x)	(x - 32)
/*******************************************************************************
 * CPU Extended Control register specific definitions.
 ******************************************************************************/
#define CPUECTLR			p15, 1, c15	/* Instruction def. */

#define CPUECTLR_SMP_BIT		(1 << 6)
#define CPUECTLR_DIS_TWD_ACC_PFTCH_BIT	(1 << AARCH32_BIT_OFFSET(38))
#define CPUECTLR_L2_IPFTCH_DIST_MASK	(0x3 << AARCH32_BIT_OFFSET(35))
#define CPUECTLR_L2_DPFTCH_DIST_MASK	(0x3 << AARCH32_BIT_OFFSET(32))

/*******************************************************************************
 * CPU Memory Error Syndrome register specific definitions.
 ******************************************************************************/
#define CPUMERRSR			p15, 2, c15 /* Instruction def. */

/*******************************************************************************
 * CPU Auxiliary Control register specific definitions.
 ******************************************************************************/
#define CPUACTLR			p15, 0, c15 /* Instruction def. */

#define CPUACTLR_DISABLE_L1_DCACHE_HW_PFTCH	(1 << AARCH32_BIT_OFFSET(56))
#define CPUACTLR_NO_ALLOC_WBWA         (1 << AARCH32_BIT_OFFSET(49))
#define CPUACTLR_DCC_AS_DCCI           (1 << AARCH32_BIT_OFFSET(44))

/*******************************************************************************
 * L2 Control register specific definitions.
 ******************************************************************************/
#define L2CTLR			p15, 1, c9, c0, 3 /* Instruction def. */

#define L2CTLR_DATA_RAM_LATENCY_SHIFT	0
#define L2CTLR_TAG_RAM_LATENCY_SHIFT	6

#define L2_DATA_RAM_LATENCY_3_CYCLES	0x2
#define L2_TAG_RAM_LATENCY_2_CYCLES	0x1
#define L2_TAG_RAM_LATENCY_3_CYCLES	0x2

/*******************************************************************************
 * L2 Memory Error Syndrome register specific definitions.
 ******************************************************************************/
#define L2MERRSR			p15, 3, c15 /* Instruction def. */

#endif /* __CORTEX_A72_H__ */
