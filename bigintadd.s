	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0	sdk_version 13, 3
	.globl	_BigInt_add                     ; -- Begin function BigInt_add
	.p2align	2
_BigInt_add:                            ; @BigInt_add
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #80
	.cfi_def_cfa_offset 80
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x0, [x29, #-16]
	stur	x1, [x29, #-24]
	str	x2, [sp, #32]
	ldur	x8, [x29, #-16]
	subs	x8, x8, #0
	cset	w9, eq
                                        ; implicit-def: $x8
	mov	x8, x9
	ands	x8, x8, #0x1
	cset	w8, eq
	tbnz	w8, #0, LBB0_2
	b	LBB0_1
LBB0_1:
	adrp	x0, l___func__.BigInt_add@PAGE
	add	x0, x0, l___func__.BigInt_add@PAGEOFF
	adrp	x1, l_.str@PAGE
	add	x1, x1, l_.str@PAGEOFF
	mov	w2, #41
	adrp	x3, l_.str.1@PAGE
	add	x3, x3, l_.str.1@PAGEOFF
	bl	___assert_rtn
LBB0_2:
	b	LBB0_3
LBB0_3:
	ldur	x8, [x29, #-24]
	subs	x8, x8, #0
	cset	w9, eq
                                        ; implicit-def: $x8
	mov	x8, x9
	ands	x8, x8, #0x1
	cset	w8, eq
	tbnz	w8, #0, LBB0_5
	b	LBB0_4
LBB0_4:
	adrp	x0, l___func__.BigInt_add@PAGE
	add	x0, x0, l___func__.BigInt_add@PAGEOFF
	adrp	x1, l_.str@PAGE
	add	x1, x1, l_.str@PAGEOFF
	mov	w2, #42
	adrp	x3, l_.str.2@PAGE
	add	x3, x3, l_.str.2@PAGEOFF
	bl	___assert_rtn
LBB0_5:
	b	LBB0_6
LBB0_6:
	ldr	x8, [sp, #32]
	subs	x8, x8, #0
	cset	w9, eq
                                        ; implicit-def: $x8
	mov	x8, x9
	ands	x8, x8, #0x1
	cset	w8, eq
	tbnz	w8, #0, LBB0_8
	b	LBB0_7
LBB0_7:
	adrp	x0, l___func__.BigInt_add@PAGE
	add	x0, x0, l___func__.BigInt_add@PAGEOFF
	adrp	x1, l_.str@PAGE
	add	x1, x1, l_.str@PAGEOFF
	mov	w2, #43
	adrp	x3, l_.str.3@PAGE
	add	x3, x3, l_.str.3@PAGEOFF
	bl	___assert_rtn
LBB0_8:
	b	LBB0_9
LBB0_9:
	ldr	x8, [sp, #32]
	ldur	x9, [x29, #-16]
	subs	x8, x8, x9
	cset	w9, eq
                                        ; implicit-def: $x8
	mov	x8, x9
	ands	x8, x8, #0x1
	cset	w8, eq
	tbnz	w8, #0, LBB0_11
	b	LBB0_10
LBB0_10:
	adrp	x0, l___func__.BigInt_add@PAGE
	add	x0, x0, l___func__.BigInt_add@PAGEOFF
	adrp	x1, l_.str@PAGE
	add	x1, x1, l_.str@PAGEOFF
	mov	w2, #44
	adrp	x3, l_.str.4@PAGE
	add	x3, x3, l_.str.4@PAGEOFF
	bl	___assert_rtn
LBB0_11:
	b	LBB0_12
LBB0_12:
	ldr	x8, [sp, #32]
	ldur	x9, [x29, #-24]
	subs	x8, x8, x9
	cset	w9, eq
                                        ; implicit-def: $x8
	mov	x8, x9
	ands	x8, x8, #0x1
	cset	w8, eq
	tbnz	w8, #0, LBB0_14
	b	LBB0_13
LBB0_13:
	adrp	x0, l___func__.BigInt_add@PAGE
	add	x0, x0, l___func__.BigInt_add@PAGEOFF
	adrp	x1, l_.str@PAGE
	add	x1, x1, l_.str@PAGEOFF
	mov	w2, #45
	adrp	x3, l_.str.5@PAGE
	add	x3, x3, l_.str.5@PAGEOFF
	bl	___assert_rtn
LBB0_14:
	b	LBB0_15
LBB0_15:
	ldur	x8, [x29, #-16]
	ldr	x0, [x8]
	ldur	x8, [x29, #-24]
	ldr	x1, [x8]
	bl	_BigInt_larger
	str	x0, [sp]
	ldr	x8, [sp, #32]
	ldr	x8, [x8]
	ldr	x9, [sp]
	subs	x8, x8, x9
	cset	w8, le
	tbnz	w8, #0, LBB0_17
	b	LBB0_16
LBB0_16:
	ldr	x8, [sp, #32]
	add	x0, x8, #8
	mov	w1, #0
	mov	x2, #262144
	mov	x3, #-1
	bl	___memset_chk
	b	LBB0_17
LBB0_17:
	str	xzr, [sp, #24]
	str	xzr, [sp, #8]
	b	LBB0_18
LBB0_18:                                ; =>This Inner Loop Header: Depth=1
	ldr	x8, [sp, #8]
	ldr	x9, [sp]
	subs	x8, x8, x9
	cset	w8, ge
	tbnz	w8, #0, LBB0_25
	b	LBB0_19
LBB0_19:                                ;   in Loop: Header=BB0_18 Depth=1
	ldr	x8, [sp, #24]
	str	x8, [sp, #16]
	str	xzr, [sp, #24]
	ldur	x8, [x29, #-16]
	add	x8, x8, #8
	ldr	x9, [sp, #8]
	ldr	x9, [x8, x9, lsl #3]
	ldr	x8, [sp, #16]
	add	x8, x8, x9
	str	x8, [sp, #16]
	ldr	x8, [sp, #16]
	ldur	x9, [x29, #-16]
	add	x9, x9, #8
	ldr	x10, [sp, #8]
	ldr	x9, [x9, x10, lsl #3]
	subs	x8, x8, x9
	cset	w8, hs
	tbnz	w8, #0, LBB0_21
	b	LBB0_20
LBB0_20:                                ;   in Loop: Header=BB0_18 Depth=1
	mov	x8, #1
	str	x8, [sp, #24]
	b	LBB0_21
LBB0_21:                                ;   in Loop: Header=BB0_18 Depth=1
	ldur	x8, [x29, #-24]
	add	x8, x8, #8
	ldr	x9, [sp, #8]
	ldr	x9, [x8, x9, lsl #3]
	ldr	x8, [sp, #16]
	add	x8, x8, x9
	str	x8, [sp, #16]
	ldr	x8, [sp, #16]
	ldur	x9, [x29, #-24]
	add	x9, x9, #8
	ldr	x10, [sp, #8]
	ldr	x9, [x9, x10, lsl #3]
	subs	x8, x8, x9
	cset	w8, hs
	tbnz	w8, #0, LBB0_23
	b	LBB0_22
LBB0_22:                                ;   in Loop: Header=BB0_18 Depth=1
	mov	x8, #1
	str	x8, [sp, #24]
	b	LBB0_23
LBB0_23:                                ;   in Loop: Header=BB0_18 Depth=1
	ldr	x8, [sp, #16]
	ldr	x9, [sp, #32]
	add	x9, x9, #8
	ldr	x10, [sp, #8]
	str	x8, [x9, x10, lsl #3]
	b	LBB0_24
LBB0_24:                                ;   in Loop: Header=BB0_18 Depth=1
	ldr	x8, [sp, #8]
	add	x8, x8, #1
	str	x8, [sp, #8]
	b	LBB0_18
LBB0_25:
	ldr	x8, [sp, #24]
	subs	x8, x8, #1
	cset	w8, ne
	tbnz	w8, #0, LBB0_29
	b	LBB0_26
LBB0_26:
	ldr	x8, [sp]
	subs	x8, x8, #8, lsl #12             ; =32768
	cset	w8, ne
	tbnz	w8, #0, LBB0_28
	b	LBB0_27
LBB0_27:
	stur	wzr, [x29, #-4]
	b	LBB0_30
LBB0_28:
	ldr	x8, [sp, #32]
	add	x9, x8, #8
	ldr	x10, [sp]
	mov	x8, #1
	str	x8, [x9, x10, lsl #3]
	ldr	x8, [sp]
	add	x8, x8, #1
	str	x8, [sp]
	b	LBB0_29
LBB0_29:
	ldr	x8, [sp]
	ldr	x9, [sp, #32]
	str	x8, [x9]
	mov	w8, #1
	stur	w8, [x29, #-4]
	b	LBB0_30
LBB0_30:
	ldur	w0, [x29, #-4]
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	add	sp, sp, #80
	ret
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function BigInt_larger
_BigInt_larger:                         ; @BigInt_larger
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	str	x0, [sp, #24]
	str	x1, [sp, #16]
	ldr	x8, [sp, #24]
	ldr	x9, [sp, #16]
	subs	x8, x8, x9
	cset	w8, le
	tbnz	w8, #0, LBB1_2
	b	LBB1_1
LBB1_1:
	ldr	x8, [sp, #24]
	str	x8, [sp, #8]
	b	LBB1_3
LBB1_2:
	ldr	x8, [sp, #16]
	str	x8, [sp, #8]
	b	LBB1_3
LBB1_3:
	ldr	x0, [sp, #8]
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l___func__.BigInt_add:                  ; @__func__.BigInt_add
	.asciz	"BigInt_add"

l_.str:                                 ; @.str
	.asciz	"bigintadd.c"

l_.str.1:                               ; @.str.1
	.asciz	"oAddend1 != NULL"

l_.str.2:                               ; @.str.2
	.asciz	"oAddend2 != NULL"

l_.str.3:                               ; @.str.3
	.asciz	"oSum != NULL"

l_.str.4:                               ; @.str.4
	.asciz	"oSum != oAddend1"

l_.str.5:                               ; @.str.5
	.asciz	"oSum != oAddend2"

.subsections_via_symbols
