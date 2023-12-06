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
        .equ    MAX_DIGITS, 32768
        .equ    SIZE_OF_UL, 8
        
        //--------------------------------------------------------------
        // Return the larger of lLength1 and lLength2.
        //
        // static long BigInt_larger(long lLength1, long lLength2)
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    LARGER_STACK_BYTECOUNT, 32 

        // Store Local Variables in Callee-Saved Registers
        LLARGER .req x19
        
        // Store Parameters in Callee-Saved Registers
        LLENGTH1 .req x20
        LLENGTH2 .req x21
        
BigInt_larger:
        // Prologue
        sub     sp, sp, LARGER_STACK_BYTECOUNT
        str     x30, [sp]
        str     x19, [sp, 8]
        str     x20, [sp, 16]
        str     x21, [sp, 24]

        // Initialize parameters
        mov     LLENGTH1, x0
        mov     LLENGTH2, x1
        
        // if (LLENGTH1 <= LLENGTH2) goto larger_if1;
        cmp     LLENGTH1, LLENGTH2
        ble     larger_if1

        // LLARGER = LLENGTH1;
        mov     LLENGTH1, LLARGER

        // goto larger_end;
        b       larger_end
        
larger_if1:
        // LLARGER = LLENGTH2;
        mov     LLENGTH2, LLARGER

larger_end:
        // Epilogue and return LLARGER
        mov     x0, LLARGER
        ldr     x30, [sp]
        ldr     x19, [sp, 8]
        ldr     x20, [sp, 16]
        ldr     x21, [sp, 24]
        add     sp, sp, LARGER_STACK_BYTECOUNT
        ret

        .size   BigInt_larger, (. - BigInt_larger)
        
        //--------------------------------------------------------------
        // Assign the sum of oAddend1 and oAddend2 to oSum. oSum should
        // be distinct from oAddend1 and oAddend2. Return 0 (FALSE) if
        // an overflow occurred, and 1 (TRUE) otherwise.
        //
        // int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2,
        //                BigInt_T oSum)
        //--------------------------------------------------------------
        
        // Must be a multiple of 16
        .equ    ADD_STACK_BYTECOUNT, 64

        // Store Local Variables in Callee-Saved Registers
        LLENGTH .req x19
        ULCARRY .req x20 
        ULSUM .req x21
        LINDEX .req x22
        LSUMLENGTH .req x23

        // Store Parameters in Callee-Saved Registers
        OADDEND1 .req x24
        OADDEND2 .req x25
        OSUM .req x26
        
        // BigIntAdd Function
        .global BigInt_add

BigInt_add: 
    	// Prologue
    	sub     sp, sp, ADD_STACK_BYTECOUNT
    	str     x30, [sp]
        str     x19, [sp, 8]
        str     x20, [sp, 16]
        str     x21, [sp, 24]
        str     x22, [sp, 32]
        str     x23, [sp, 40]
        str     x24, [sp, 48]
        str     x25, [sp, 56]
        str     x26, [sp, 64] 

    	// Initialize Parameters
    	mov     OADDEND1, x0
        mov     OADDEND2, x1
        mov     OSUM, x2

    	// lSumLength = BigInt_larger(oAddend1->lLength, 
		// oAddend2->lLength);
    	bl      BigInt_larger
    	mov     LSUMLENGTH, x0
        
        // if (oSum->lLength <= lSumLength) goto after_memset;
        cmp     x2, x0
        ble     after_memset

	//memset(oSum->aulDigits,0, MAX_DIGITS * sizeof(unsigned long));

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
        // ulCarry = 0;
        mov     ULCARRY, #0     
        
        // lIndex = 0;
        mov     LINDEX, #0

loop_start:
        // if (lIndex >= lSumLength) goto loop_end;
        cmp     LINDEX, LSUMLENGTH
        bge     loop_end

        // ulSum = ulCarry;
        mov     ULCARRY, ULSUM

        // ulCarry = 0;
        mov     ULCARRY, #0

        // ulSum += oAddend1->aulDigits[lIndex];
        add     x1, OADDEND1, SIZE_OF_UL
        lsl     x2, LINDEX, #3
        add     x1, x1, x2
        ldr     x1, [x1]
        add     ULSUM, ULSUM, x1

        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto add_if1;
        cmp     ULSUM, x1
        bhs     add_if1

        // ULCARRY = 1;
        mov     ULCARRY, #1

add_if1:
        // ulSum += oAddend2->aulDigits[lIndex];
        add     x1, OADDEND2, SIZE_OF_UL
        lsl     x2, LINDEX, #3
        add     x1, x1, x2
        ldr     x1, [x1]
        add     ULSUM, ULSUM, x1

        // if (ulSum >= oAddend2->aulDigits[Index]) goto add_if2;
        cmp     ULSUM, x1
        bhs     add_if2

        // ulCarry = 1;
        mov     ULCARRY, #1

add_if2:
        // oSum->aulDigits[lIndex] = ulSum;
        add     x1, OSUM, SIZE_OF_UL
        lsl     x2, LINDEX, #3
        add     x1, x1, x2
        str     ULSUM, [x1]

        // lIndex++;
        add     LINDEX, LINDEX, #1
        
        // goto loop_start;
        b       loop_start

loop_end:
        // if (ulCarry != 1) goto set_sumlength;
        cmp     ULCARRY, #1
        bne     set_sumlength

   	// if (lSumLength == MAX_DIGITS) return FALSE;
        cmp     LSUMLENGTH, MAX_DIGITS
        beq     ret_false

        // oSum->aulDigits[lSumLength] = 1;
        add     x0, OSUM, SIZE_OF_UL
        lsl     x1, LSUMLENGTH, #3
        add     x0, x0, x1
        mov     x2, #1
        mov     x0, x2
        
        // lSumLength++;
        add     LSUMLENGTH, LSUMLENGTH, #1

        // goto set_sumlength;
        b       set_sumlength

set_sumlength:
	// oSum->lLength = lSumLength;
        mov     LSUMLENGTH, OSUM

        // Store TRUE in x0
        mov     x0, TRUE
        
        // goto add_end;
        b       add_end

ret_false:
        // Store FALSE in x0
	mov 	x0, FALSE

        // goto add_end;
        b       add_end

add_end:
        // Epilogue and return TRUE
        ldr     x30, [sp]
        ldr     x19, [sp, 8]
        ldr     x20, [sp, 16]
        ldr     x21, [sp, 24]
        ldr     x22, [sp, 32]
        ldr     x23, [sp, 40]
        ldr     x24, [sp, 48]
        ldr     x25, [sp, 56]
        ldr     x26, [sp, 64]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret
        
        .size   BigInt_add, (. - BigInt_add)
		