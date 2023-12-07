// bigintadd.s
// Authors: Alex Delistathis, Matthew Zhang

.section .rodata
// ...

.section .data
// ...

.section .bss
// ...

.section .text
// Constants
.equ    TRUE, 1
.equ    FALSE, 0
.equ    MAX_DIGITS, 32768
.equ    SIZE_OF_UL, 8

//--------------------------------------------------------------
// Assign the sum of oAddend1 and oAddend2 to oSum. oSum should
// be distinct from oAddend1 and oAddend2. Return 0 (FALSE) if
// an overflow occurred, and 1 (TRUE) otherwise.
//
// int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2,
//                BigInt_T oSum)
//--------------------------------------------------------------

// Stack Bytecount
.equ    ADD_STACK_BYTECOUNT, 80

// Store Local Variables in Callee-Saved Registers
ULSUM .req x20
LINDEX .req x21
LSUMLENGTH .req x22

// Store Parameters in Callee-Saved Registers
OADDEND1 .req x23
OADDEND2 .req x24
OSUM .req x25

// Larger Inlined Variable
LLARGER .req x26

// Store Parameters in Callee-Saved Registers
LLENGTH1 .req x27
LLENGTH2 .req x28

// BigIntAdd Function
.global BigInt_add

BigInt_add: 
    // Prologue
    sub     sp, sp, ADD_STACK_BYTECOUNT
    str     x30, [sp]
    str     x20, [sp, 16]
    str     x21, [sp, 24]
    str     x22, [sp, 32]
    str     x23, [sp, 40]
    str     x24, [sp, 48]
    str     x25, [sp, 56]
    str     x26, [sp, 64]
    str     x27, [sp, 72]
    str     x28, [sp, 80]

    // Initialize Parameters
    mov     OADDEND1, x0
    mov     OADDEND2, x1
    mov     OSUM, x2

    // Load in the lengths of both BigInt ADTs
    ldr     x0, [OADDEND1]
    ldr     x1, [OADDEND2]

    // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength)
    // initialize parameters
    mov     LLENGTH1, x0
    mov     LLENGTH2, x1

    // if (LLENGTH1 <= LLENGTH2) goto larger_if1;
    cmp     LLENGTH1, LLENGTH2
    ble     larger_if1

    // LLARGER = LLENGTH1;
    mov     LLARGER, LLENGTH1
    mov     LSUMLENGTH, LLARGER
    b       before_memset

larger_if1: 
    // LLARGER = LLENGTH2;
    mov     LLARGER, LLENGTH2
    mov     LSUMLENGTH, LLARGER

before_memset: 
    // if (oSum->lLength <= lSumLength) goto after_memset;
    ldr     x0, [OSUM]
    cmp     x0, LSUMLENGTH
    ble     after_memset

    // STORE oSum->aulDigits in a register
    add     x0, OSUM, SIZE_OF_UL

    // Multiply MAX_DIGITS by sizeof(unsigned long) and store in x2
    mov     x1, MAX_DIGITS
    mov     x2, SIZE_OF_UL
    mul     x2, x1, x2

    // Store #0 in x1
    mov     x1, #0

    // Execute the memset() function
    bl      memset

after_memset:
    // lIndex = 0;
    mov     LINDEX, #0

    // Clear the carry flag before starting the loop
    mov     ULSUM, #0              // Use ULSUM temporarily to clear the carry
    adds    ULSUM, ULSUM, #0       // Perform an addition that clears the carry flag

loop_cond_check: 
    // if (lIndex >= lSumLength) goto loop_end;
    cmp     LINDEX, LSUMLENGTH
    bge     loop_end

loop_start:
    // Load oAddend1's digit
    add     x1, OADDEND1, SIZE_OF_UL
    lsl     x2, LINDEX, #3
    add     x1, x1, x2
    ldr     x1, [x1]

    // Load oAddend2's digit and add with carry
    add     x2, OADDEND2, SIZE_OF_UL
    lsl     x3, LINDEX, #3
    add     x2, x2, x3
    ldr     x2, [x2]
    adcs    ULSUM, x1, x2       // Add both digits and the carry flag

    // Check if the addition caused an overflow
    bcs     overflow_occurred   // Branch to overflow handling if carry set

    // Store the result
    add     x1, OSUM, SIZE_OF_UL
    lsl     x2, LINDEX, #3
    add     x1, x1, x2
    str     ULSUM, [x1]

    // Prepare for next iteration
    add     LINDEX, LINDEX, #1
    b       loop_cond_check


loop_end:
    // Check if carry flag is set after the final loop iteration
    // (This checks for any overflow in the last iteration)
    bcs     overflow_occurred   // Branch to overflow handling if carry set

    // Set the length of the result BigInt to lSumLength
    mov     x0, OSUM            // Load the address of oSum
    str     LSUMLENGTH, [x0]    // Store lSumLength in oSum->lLength

    // Set the return value to TRUE (indicating no overflow)
    mov     x0, TRUE            // TRUE typically equals 1

    // Jump to the function epilogue
    b       add_end

set_sumlength:
    // oSum->lLength = lSumLength;
    mov     x0, OSUM
    str     LSUMLENGTH, [x0]

    // Store TRUE in x0
    mov     x0, TRUE
    b       add_end

overflow_occurred:
    // Handle overflow and return FALSE
    mov     x0, FALSE
    b       add_end

add_end:
    // Epilogue and return
    ldr     x30, [sp]
    ldr     x20, [sp, 16]
    ldr     x21, [sp, 24]
    ldr     x22, [sp, 32]
    ldr     x23, [sp, 40]
    ldr     x24, [sp, 48]
    ldr     x25, [sp, 56]
    ldr     x26, [sp, 64]
    ldr     x27, [sp, 72]
    ldr     x28, [sp, 80]
    add     sp, sp, ADD_STACK_BYTECOUNT
    ret

.size   BigInt_add, (. - BigInt_add)
