//----------------------------------------------------------------------
// bigintadd.s
// Authors: Alex Delistathis, Matthew Zhang
//----------------------------------------------------------------------

        .section .rodata

//----------------------------------------------------------------------
        .section .data

//----------------------------------------------------------------------
        .section .bss

//----------------------------------------------------------------------
.section .text
    // Constants
    .equ    TRUE, 1
    .equ    FALSE, 0
    .equ    MAX_DIGITS, 100
    .equ    SIZE_OF_UL, 8
        
    // Local Variable Stack Offsets
    .equ    ULCARRY, 8 
    .equ    ULSUM, 16
    .equ    LINDEX, 24
    .equ    LSUMLENGTH, 32

    // Parameter Stack Offsets
    .equ    OADDEND1, 40
    .equ    OADDEND2, 48
    .equ    OSUM, 56

.global BigInt_add
    .type BigInt_add, @function
    
BigInt_add: 
    // Prologue
    sub     sp, sp, ADD_STACK_BYTECOUNT
    str     x30, [sp]

    // Initialize Parameters
    str     x0, [sp, OADDEND1]
    str     x1, [sp, OADDEND2]
    str     x2, [sp, OSUM]

    // Load in length of OADDEND1
    ldr     x3, [x0, #16]  // Assuming the length is at offset 16 of the struct

    // Load in length of OADDEND2
    ldr     x4, [x1, #16]  // Assuming the length is at offset 16 of the struct

    // Compare lengths and store the larger one
    cmp     x3, x4
    b.gt    use_first_length
    mov     x3, x4

use_first_length:
    str     x3, [sp, LSUMLENGTH]

    // Check if the larger length is 0, which means both are zero
    cmp     x3, #0
    beq     handle_zero_case

    // Here starts the new code for clearing oSum's array if necessary
    // Load lSumLength from the stack
    ldr     x3, [sp, LSUMLENGTH]

    // Load oSum pointer
    ldr     x5, [sp, OSUM]

    // Load oSum->lLength
    ldr     x6, [x5, #16]  // Assuming lLength is at offset 16

    // Compare oSum->lLength with lSumLength
    cmp     x6, x3
    ble    skip_clear  // If oSum->lLength <= lSumLength, skip the clearing

    // Clear oSum's array
    // Assuming aulDigits is at some offset, e.g., #24, in the struct
    add     x5, x5, #24  // Address of oSum->aulDigits
    mov     x7, #0       // Zero value to clear the array
    mov     x8, #MAX_DIGITS

handle_zero_case:
    	// If both inputs are zero, set the length of oSum to 0 and return TRUE
    	mov     x0, sp
    	add     x0, x0, OSUM
    	mov     x1, #0
    	str     x1, [x0, #16]  // Assuming the length is at offset 16 of the struct
    	mov     x0, TRUE
    	b       add_end

clear_loop:
    str     x7, [x5], #8  // Store 0 and post-increment address by 8
    subs    x8, x8, #1    // Decrement counter
    b.ne    clear_loop    // If counter not zero, continue loop

skip_clear:
    // ulCarry = 0;
    mov     x0, #0     
    str     x0, [sp, ULCARRY]
        
    // lIndex = 0;
    str     x0, [sp, LINDEX]
    b loop1

loop1:
    // Load lIndex and lSumLength
    ldr     x4, [sp, LINDEX]       // x4 = lIndex
    ldr     x5, [sp, LSUMLENGTH]   // x5 = lSumLength

    // Check if lIndex < lSumLength
    cmp     x4, x5
    bge    endloop1               // Exit loop if lIndex >= lSumLength

    // Load ulCarry
    ldr     x6, [sp, ULCARRY]      // x6 = ulCarry

    // Calculate address offset for array indexing (x4 * 8)
    mov     x7, x4
    lsl     x7, x7, #3             // x7 = lIndex * 8 (shift left by 3 is equivalent to multiply by 8)

    // Load oAddend1->aulDigits[lIndex]
    ldr     x8, [sp, OADDEND1]     // Load oAddend1 pointer
    ldr     x8, [x8, x7]           // Load oAddend1->aulDigits[lIndex]

    // Load oAddend2->aulDigits[lIndex]
    ldr     x9, [sp, OADDEND2]     // Load oAddend2 pointer
    ldr     x9, [x9, x7]           // Load oAddend2->aulDigits[lIndex]

    // ulSum = ulCarry + oAddend1->aulDigits[lIndex] + oAddend2->aulDigits[lIndex]
    add     x10, x6, x8            // x10 = ulCarry + oAddend1->aulDigits[lIndex]
    add     x10, x10, x9           // x10 = ulSum + oAddend2->aulDigits[lIndex]
    str     x10, [sp, ULSUM]       // Store ulSum

    // Check for carry from oAddend1
    cmp     x10, x8
    bl      set_carry              // If ulSum < oAddend1->aulDigits[lIndex], set carry
    mov     x6, #0                 // Otherwise, clear carry

check_carry_oaddend2:
    // Check for carry from oAddend2
    cmp     x10, x9
    blo    set_carry              // If ulSum < oAddend2->aulDigits[lIndex], set carry
    b       continue_loop

set_carry:
    mov     x6, #1                 // Set carry

continue_loop:
    // Store ulSum into oSum->aulDigits[lIndex]
    ldr     x11, [sp, OSUM]        // Load oSum pointer
    str     x10, [x11, x7]         // Store ulSum at oSum->aulDigits[lIndex]

    // Increment lIndex
    add     x4, x4, #1
    str     x4, [sp, LINDEX]
    b       loop1

endloop1:
    ldr     x6, [sp, ULCARRY]        // Load ulCarry
    cmp     x6, #1
    bne     endif1

    ldr     x5, [sp, LSUMLENGTH]     // Load lSumLength
    cmp     x5, #MAX_DIGITS
    beq     return_false

    ldr     x8, [sp, OSUM]           // Load oSum pointer
    add     x5, x5, #1
    str     x5, [sp, LSUMLENGTH]

    lsl     x9, x5, #3
    sub     x9, x9, #8
    mov     x10, #1
    str     x10, [x8, x9]            // Store 1 at oSum->aulDigits[lSumLength - 1]

    b       endif1

endif1:
    ldr     x5, [sp, LSUMLENGTH]     // Load lSumLength
    ldr     x8, [sp, OSUM]           // Load oSum pointer
    str     x5, [x8, #16]            // Store lSumLength at oSum->lLength

    mov     x0, #TRUE
    b       func_end

return_false:
    mov     x0, #FALSE

func_end:
    // Function epilogue
    ldr     x30, [sp]
    add     sp, sp, ADD_STACK_BYTECOUNT
    ret
    .size BigInt_add, (. - BigInt_add)
