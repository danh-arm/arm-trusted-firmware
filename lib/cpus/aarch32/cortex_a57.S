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
#include <arch.h>
#include <asm_macros.S>
#include <assert_macros.S>
#include <cortex_a57.h>
#include <cpu_macros.S>
#include <debug.h>

	/* ---------------------------------------------
	 * Disable intra-cluster coherency
	 * Clobbers: r0-r1
	 * ---------------------------------------------
	 */
func cortex_a57_disable_smp
	ldcopr16	r0, r1, CPUECTLR
	bic	r0, r0, #CPUECTLR_SMP_BIT
	stcopr16	r0, r1, CPUECTLR
	isb
	dsb	sy
	bx	lr
endfunc cortex_a57_disable_smp

	/* ---------------------------------------------
	 * Disable all types of L2 prefetches.
	 * Clobbers: r0-r2
	 * ---------------------------------------------
	 */
func cortex_a57_disable_l2_prefetch
	ldcopr16	r0, r1, CPUECTLR
	orr	r1, r1, #CPUECTLR_DIS_TWD_ACC_PFTCH_BIT
	mov	r2, #CPUECTLR_L2_IPFTCH_DIST_MASK
	orr	r2, r2, #CPUECTLR_L2_DPFTCH_DIST_MASK
	bic	r1, r1, r2
	stcopr16	r0, r1, CPUECTLR
	isb
	dsb	ish
	bx	lr
endfunc cortex_a57_disable_l2_prefetch

	/* ---------------------------------------------
	 * Disable debug interfaces
	 * ---------------------------------------------
	 */
func cortex_a57_disable_ext_debug
	mov	r0, #1
	stcopr	r0, DBGOSDLR
	isb
	dsb	sy
	bx	lr
endfunc cortex_a57_disable_ext_debug

	/* --------------------------------------------------
	 * Errata Workaround for Cortex A57 Errata #806969.
	 * This applies only to revision r0p0 of Cortex A57.
	 * Inputs:
	 * r0: variant[4:7] and revision[0:3] of current cpu.
	 * Clobbers : r0 - r5
	 * --------------------------------------------------
	 */
func errata_a57_806969_wa
	/*
	 * Compare r0 against revision r0p0
	 */
	cmp	r0, #0
	beq	apply_806969
#if LOG_LEVEL >= LOG_LEVEL_VERBOSE
	b	print_revision_warning
#else
	bx	lr
#endif
apply_806969:
	ldcopr16	r0, r1, CPUACTLR
	orr	r1, r1, #CPUACTLR_NO_ALLOC_WBWA
	stcopr16	r0, r1, CPUACTLR
	bx	lr
endfunc errata_a57_806969_wa


	/* ---------------------------------------------------
	 * Errata Workaround for Cortex A57 Errata #813420.
	 * This applies only to revision r0p0 of Cortex A57.
	 * Inputs:
	 * r0: variant[4:7] and revision[0:3] of current cpu.
	 * Clobbers : r0 - r5
	 * ---------------------------------------------------
	 */
func errata_a57_813420_wa
	/*
	 * Compare r0 against revision r0p0
	 */
	cmp	r0, #0
	beq	apply_813420
#if LOG_LEVEL >= LOG_LEVEL_VERBOSE
	b	print_revision_warning
#else
	bx	lr
#endif
apply_813420:
	ldcopr16	r0, r1, CPUACTLR
	orr	r1, r1, #CPUACTLR_DCC_AS_DCCI
	stcopr16	r0, r1, CPUACTLR
	bx	lr
endfunc errata_a57_813420_wa

	/* --------------------------------------------------------------------
	 * Disable the over-read from the LDNP instruction.
	 *
	 * This applies to all revisions <= r1p2. The performance degradation
	 * observed with LDNP/STNP has been fixed on r1p3 and onwards.
	 *
	 * Inputs:
	 * r0: variant[4:7] and revision[0:3] of current cpu.
	 * Clobbers : r0 - r5, r10
	 * ---------------------------------------------------------------------
	 */
func a57_disable_ldnp_overread
	/*
	 * Compare r0 against revision r1p2
	 */
	cmp	r0, #0x12
	bls	disable_hint
#if LOG_LEVEL >= LOG_LEVEL_VERBOSE
	b	print_revision_warning
#else
	bx	lr
#endif
disable_hint:
	ldcopr16	r0, r1, CPUACTLR
	orr	r1, r1, #CPUACTLR_DIS_OVERREAD
	stcopr16	r0, r1, CPUACTLR
	bx	lr
endfunc a57_disable_ldnp_overread

	/* ---------------------------------------------------
	 * Errata Workaround for Cortex A57 Errata #826974.
	 * This applies only to revision <= r1p1 of Cortex A57.
	 * Inputs:
	 * r0: variant[4:7] and revision[0:3] of current cpu.
	 * Clobbers : r0 - r5
	 * ---------------------------------------------------
	 */
func errata_a57_826974_wa
	/*
	 * Compare x0 against revision r1p1
	 */
	cmp	r0, #0x11
	bls	apply_826974
#if LOG_LEVEL >= LOG_LEVEL_VERBOSE
	b	print_revision_warning
#else
	bx	lr
#endif
apply_826974:
	ldcopr16	r0, r1, CPUACTLR
	orr	r1, r1, #CPUACTLR_DIS_LOAD_PASS_DMB
	stcopr16	r0, r1, CPUACTLR
	bx	lr
endfunc errata_a57_826974_wa

	/* ---------------------------------------------------
	 * Errata Workaround for Cortex A57 Errata #826977.
	 * This applies only to revision <= r1p1 of Cortex A57.
	 * Inputs:
	 * r0: variant[4:7] and revision[0:3] of current cpu.
	 * Clobbers : r0 - r5
	 * ---------------------------------------------------
	 */
func errata_a57_826977_wa
	/*
	 * Compare x0 against revision r1p1
	 */
	cmp	r0, #0x11
	bls	apply_826977
#if LOG_LEVEL >= LOG_LEVEL_VERBOSE
	b	print_revision_warning
#else
	bx	lr
#endif
apply_826977:
	ldcopr16	r0, r1, CPUACTLR
	orr	r1, r1, #CPUACTLR_GRE_NGRE_AS_NGNRE
	stcopr16	r0, r1, CPUACTLR
	bx	lr
endfunc errata_a57_826977_wa

	/* ---------------------------------------------------
	 * Errata Workaround for Cortex A57 Errata #828024.
	 * This applies only to revision <= r1p1 of Cortex A57.
	 * Inputs:
	 * r0: variant[4:7] and revision[0:3] of current cpu.
	 * Clobbers : r0 - r5
	 * ---------------------------------------------------
	 */
func errata_a57_828024_wa
	/*
	 * Compare x0 against revision r1p1
	 */
	cmp	r0, #0x11
	bls	apply_828024
#if LOG_LEVEL >= LOG_LEVEL_VERBOSE
	b	print_revision_warning
#else
	bx	lr
#endif
apply_828024:
	ldcopr16	r0, r1, CPUACTLR
	/*
	 * Setting the relevant bits in CPUACTLR has to be done in 2
	 * instructions here because the resulting bitmask doesn't fit in a
	 * 16-bit value so it cannot be encoded in a single instruction.
	 */
	orr	r1, r1, #CPUACTLR_NO_ALLOC_WBWA
	orr	r0, r0, #(CPUACTLR_DIS_L1_STREAMING | CPUACTLR_DIS_STREAMING)
	stcopr16	r0, r1, CPUACTLR
	bx	lr
endfunc errata_a57_828024_wa

	/* ---------------------------------------------------
	 * Errata Workaround for Cortex A57 Errata #829520.
	 * This applies only to revision <= r1p2 of Cortex A57.
	 * Inputs:
	 * x0: variant[4:7] and revision[0:3] of current cpu.
	 * Clobbers : x0 - x5
	 * ---------------------------------------------------
	 */
func errata_a57_829520_wa
	/*
	 * Compare x0 against revision r1p2
	 */
	cmp	r0, #0x12
	bls	apply_829520
#if LOG_LEVEL >= LOG_LEVEL_VERBOSE
	b	print_revision_warning
#else
	bx	lr
#endif
apply_829520:
	ldcopr16	r0, r1, CPUACTLR
	orr	r0, r0, #CPUACTLR_DIS_INDIRECT_PREDICTOR
	stcopr16	r0, r1, CPUACTLR
	bx	lr
endfunc errata_a57_829520_wa

	/* ---------------------------------------------------
	 * Errata Workaround for Cortex A57 Errata #833471.
	 * This applies only to revision <= r1p2 of Cortex A57.
	 * Inputs:
	 * r0: variant[4:7] and revision[0:3] of current cpu.
	 * Clobbers : r0 - r5
	 * ---------------------------------------------------
	 */
func errata_a57_833471_wa
	/*
	 * Compare r0 against revision r1p2
	 */
	cmp	r0, #0x12
	bls	apply_833471
#if LOG_LEVEL >= LOG_LEVEL_VERBOSE
	b	print_revision_warning
#else
	bx	lr
#endif
apply_833471:
	ldcopr16	r0, r1, CPUACTLR
	orr	r1, r1, #CPUACTLR_FORCE_FPSCR_FLUSH
	stcopr16	r0, r1, CPUACTLR
	bx	lr
endfunc errata_a57_833471_wa

	/* -------------------------------------------------
	 * The CPU Ops reset function for Cortex-A57.
	 * -------------------------------------------------
	 */
func cortex_a57_reset_func
	mov	r10, lr
	ldcopr	r0, MIDR

	/*
	 * Extract the variant[20:23] and revision[0:3] from r0
	 * and pack it in r11[0:7] as variant[4:7] and revision[0:3].
	 * First extract r0[16:23] to r11[0:7] and zero fill the rest.
	 * Then extract r0[0:3] into r11[0:3] retaining other bits.
	 */
	ubfx	r11, r0, #(MIDR_VAR_SHIFT - MIDR_REV_BITS), #(MIDR_REV_BITS + MIDR_VAR_BITS)
	bfi	r11, r0, #MIDR_REV_SHIFT, #MIDR_REV_BITS

#if ERRATA_A57_806969
	mov	r0, r11
	bl	errata_a57_806969_wa
#endif

#if ERRATA_A57_813420
	mov	r0, r11
	bl	errata_a57_813420_wa
#endif

#if A57_DISABLE_NON_TEMPORAL_HINT
	mov	r0, r11
	bl	a57_disable_ldnp_overread
#endif

#if ERRATA_A57_826974
	mov	r0, r11
	bl	errata_a57_826974_wa
#endif

#if ERRATA_A57_826977
	mov	r0, r11
	bl	errata_a57_826977_wa
#endif

#if ERRATA_A57_828024
	mov	r0, r11
	bl	errata_a57_828024_wa
#endif

#if ERRATA_A57_829520
	mov	r0, r11
	bl	errata_a57_829520_wa
#endif

#if ERRATA_A57_833471
	mov	r0, r11
	bl	errata_a57_833471_wa
#endif

	/* ---------------------------------------------
	 * Enable the SMP bit.
	 * ---------------------------------------------
	 */
	ldcopr16	r0, r1, CPUECTLR
	orr	r0, r0, #CPUECTLR_SMP_BIT
	stcopr16	r0, r1,	CPUECTLR
	isb
	bx	r10
endfunc cortex_a57_reset_func

	/* ----------------------------------------------------
	 * The CPU Ops core power down function for Cortex-A57.
	 * ----------------------------------------------------
	 */
func cortex_a57_core_pwr_dwn
	push	{lr}

	/* Assert if cache is enabled */
#if ASM_ASSERTION
	ldcopr	r0, SCTLR
	tst	r0, #SCTLR_C_BIT
	ASM_ASSERT(eq)
#endif

	/* ---------------------------------------------
	 * Flush L1 caches.
	 * ---------------------------------------------
	 */
	mov	r0, #DC_OP_CISW
	bl	dcsw_op_level1

	/* ---------------------------------------------
	 * Come out of intra cluster coherency
	 * ---------------------------------------------
	 */
	bl	cortex_a57_disable_smp

	/* ---------------------------------------------
	 * Force the debug interfaces to be quiescent
	 * ---------------------------------------------
	 */
	pop	{lr}
	b	cortex_a57_disable_ext_debug
endfunc cortex_a57_core_pwr_dwn

	/* -------------------------------------------------------
	 * The CPU Ops cluster power down function for Cortex-A57.
	 * Clobbers: r0-r3
	 * -------------------------------------------------------
	 */
func cortex_a57_cluster_pwr_dwn
	push	{lr}

	/* Assert if cache is enabled */
#if ASM_ASSERTION
	ldcopr	r0, SCTLR
	tst	r0, #SCTLR_C_BIT
	ASM_ASSERT(eq)
#endif

	/* ---------------------------------------------
	 * Flush L1 cache.
	 * ---------------------------------------------
	 */
	mov	r0, #DC_OP_CISW
	bl	dcsw_op_level1

	/* ---------------------------------------------
	 * Disable the optional ACP.
	 * ---------------------------------------------
	 */
	bl	plat_disable_acp

	/* ---------------------------------------------
	 * Flush L2 cache.
	 * ---------------------------------------------
	 */
	mov	r0, #DC_OP_CISW
	bl	dcsw_op_level2

	/* ---------------------------------------------
	 * Come out of intra cluster coherency
	 * ---------------------------------------------
	 */
	bl	cortex_a57_disable_smp

	/* ---------------------------------------------
	 * Force the debug interfaces to be quiescent
	 * ---------------------------------------------
	 */
	pop	{lr}
	b	cortex_a57_disable_ext_debug
endfunc cortex_a57_cluster_pwr_dwn

declare_cpu_ops cortex_a57, CORTEX_A57_MIDR, \
	cortex_a57_reset_func, \
	cortex_a57_core_pwr_dwn, \
	cortex_a57_cluster_pwr_dwn
