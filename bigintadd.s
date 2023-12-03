//----------------------------------------------------------------------
// bigintadd.s
// Authors: Alex Delistathis, Matthew Zhang
//----------------------------------------------------------------------
.section .rodata

.section .data

.section .bss

.section .text
    // Constants and Offsets
    .equ TRUE, 1
    .equ FALSE, 0
    .equ MAX_DIGITS, 100
    .equ LLENGTH_OFFSET, 0
    .equ DIGITS_OFFSET, 8

    // BigInt_Add Function
    .global bigint_add
    bigint_add: 
        // Prologue
        stp x29, x30, [sp, #-16]!
        mov x29, sp

        // Load in lengths of both bigints
        ldr w3, [x0, LLENGTH_OFFSET]
        ldr w4, [x1, LLENGTH_OFFSET]

        cmp w3, w4
        blt len_w4_greater
        mov w5, w3
        b continue

    len_w4_greater:
        mov w5, w4
    
    continue:
        // Initialize lIndex and ulCarry respectively
        mov w6, #0
        mov w7, #0

    loop_start:
        // Loop through each digit of both bigints
        cmp w6, w5
        bge loop_end

        // Load in digit of bigint x0
        add x10, x0, DIGITS_OFFSET
        lsl x10, x10, #3
        ldr x8, [x10]

        // Load in digit of bigint x1
        add x11, x1, DIGITS_OFFSET
        lsl x11, x11, #3
        ldr x9, [x11]

        // Add digits together
        adds x8, x8, x9
        adc w7, wzr, wzr  // Use wzr for the third operand

        // Store digit in x2
        add x12, x2, DIGITS_OFFSET
        lsl x12, x12, #3
        str x8, [x12]

        // Increment lIndex
        add w6, w6, #1

        b loop_start

    loop_end:
        // Check for a carry out of the last "column" of the addition
        cmp w7, #1
        bne end
        cmp w5, #MAX_DIGITS
        beq overflow
        mov x8, #1
        add x13, x2, DIGITS_OFFSET
        add x13, x13, w5
        lsl x13, x13, #3
        str x8, [x13]
        add w5, w5, #1

    end:
        str w5, [x2, LLENGTH_OFFSET]
        mov w0, TRUE
        b epilogue

    overflow:
        mov w0, FALSE

    epilogue:
        ldp x29, x30, [sp], #16
        ret
