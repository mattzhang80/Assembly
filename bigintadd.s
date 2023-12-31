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
        TRUE .req 1
        FALSE .req 0
        MAX_DIGITS .req 32768
        SIZE_OF_UL .req 8
        
        //--------------------------------------------------------------
        // Return the larger of lLength1 and lLength2.
        //
        // static long BigInt_larger(long lLength1, long lLength2)
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    LARGER_STACK_BYTECOUNT, 32 

        // Local Variable Stack Offsets
        .equ    LLARGER .req x19
        
        // Parameter Stack Offsets
        .equ    LLENGTH1 .req x20
        .equ    LLENGTH2 .req x21

BigInt_larger:
        // Prologue
        sub     sp, sp, LARGER_STACK_BYTECOUNT
        str     x30, [sp]

        // Initialize parameters
        str     x0, [sp, LLENGTH1]
        str     x1, [sp, LLENGTH2]
        
        // if (LLENGTH1 <= LLENGTH2) goto larger_if1;
        ldr     x0, [sp, LLENGTH1]
        ldr     x1, [sp, LLENGTH2]
        cmp     x0, x1
        ble     larger_if1

        // LLARGER = LLENGTH1;
        ldr     x0, [sp, LLENGTH1]
        str     x0, [sp, LLARGER]

        // goto larger_end;
        b       larger_end
        
larger_if1:
        // LLARGER = LLENGTH2;
        ldr     x0, [sp, LLENGTH2]
        str     x0, [sp, LLARGER]

larger_end:
        // Epilogue and return LLARGER
        ldr     x0, [sp, LLARGER]
        ldr     x30, [sp]
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

        // Local Variable Stack Offsets
        LLENGTH .req x19
        ULCARRY .req x20
        LSUM .req x21
        LINDEX .req x22
        LSUMLENGTH .req x23

        // Parameter Stack Offsets
        OADDEND1 .req x24
        OADDEND2 .req x25
        OSUM .req x26
        
        // BigIntAdd Function
        .global BigInt_add

BigInt_add: 
    	// Prologue
    	sub     sp, sp, ADD_STACK_BYTECOUNT
    	str     x30, [sp]

    	// Initialize Parameters
    	str     x0, [sp, OADDEND1]
    	str     x1, [sp, OADDEND2]
    	str     x2, [sp, OSUM]
    
    	// Load in length of OADDEND1
    	ldr     x0, [x0, LLENGTH]

    	// Load in length of OADDEND2
    	ldr     x1, [x1, LLENGTH]

    	// lSumLength = BigInt_larger(oAddend1->lLength, 
		// oAddend2->lLength);
    	bl      BigInt_larger
    	str     x0, [sp, LSUMLENGTH]
        
        // if (oSum->lLength <= lSumLength) goto after_memset;
        ldr     x0, [sp, OSUM]
        ldr     x0, [x0, LLENGTH]
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x0, x1
        ble     after_memset

	//memset(oSum->aulDigits,0, MAX_DIGITS * sizeof(unsigned long));
	// STORE oSum->aulDigits in a register
        ldr     x0, [sp, OSUM]
        add     x0, x0, SIZE_OF_UL

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
        mov     x0, #0     
        str     x0, [sp, ULCARRY]
        
        // lIndex = 0;
        str     x0, [sp, LINDEX]

loop_start:
        // if (lIndex >= lSumLength) goto loop_end;
        ldr     x0, [sp, LINDEX]
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x0, x1
        bge     loop_end

        // ulSum = ulCarry;
        ldr     x0, [sp, ULCARRY]
        str     x0, [sp, ULSUM]

        // ulCarry = 0;
        mov     x0, #0
        str     x0, [sp, ULCARRY]

        // ulSum += oAddend1->aulDigits[lIndex];
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OADDEND1]
        add     x1, x1, SIZE_OF_UL
        ldr     x2, [sp, LINDEX]
        lsl     x2, x2, #3
        add     x1, x1, x2
        ldr     x1, [x1]
        add     x0, x0, x1
        str     x0, [sp, ULSUM]

        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto add_if1;
        cmp     x0, x1
        bhs     add_if1

        // ULCARRY = 1;
        mov     x0, #1
        str     x0, [sp, ULCARRY]

add_if1:
        // ulSum += oAddend2->aulDigits[lIndex];
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OADDEND2]
        add     x1, x1, #8
        ldr     x2, [sp, LINDEX]
        lsl     x2, x2, #3
        add     x1, x1, x2
        ldr     x1, [x1]
        add     x0, x0, x1
        str     x0, [sp, ULSUM]

        // if (ulSum >= oAddend2->aulDigits[Index]) goto add_if2;
        cmp     x0, x1
        bhs     add_if2

        // ulCarry = 1;
        mov     x0, #1
        str     x0, [sp, ULCARRY]

add_if2:
        // oSum->aulDigits[lIndex] = ulSum;
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OSUM]
        add     x1, x1, #8
        ldr     x2, [sp, LINDEX]
        lsl     x2, x2, #3
        add     x1, x1, x2
        str     x0, [x1]

        // lIndex++;
        ldr     x0, [sp, LINDEX]
        add     x0, x0, #1
        str     x0, [sp, LINDEX]
        
        // goto loop_start;
        b       loop_start

loop_end:
        // if (ulCarry != 1) goto set_sumlength;
        ldr     x0, [sp, ULCARRY]
        cmp     x0, #1
        bne     set_sumlength

   	// if (lSumLength == MAX_DIGITS) return FALSE;
        ldr     x0, [sp, LSUMLENGTH]
        cmp     x0, MAX_DIGITS
        beq     ret_false

        // oSum->aulDigits[lSumLength] = 1;
        ldr     x0, [sp, OSUM]
        add     x0, x0, SIZE_OF_UL
        ldr     x1, [sp, LSUMLENGTH]
        lsl     x1, x1, #3
        add     x0, x0, x1
        mov     x2, #1
        str     x2, [x0]
        
        // lSumLength++;
        ldr     x0, [sp, LSUMLENGTH]
        mov     x1, #1
        add     x0, x0, x1
        str     x0, [sp, LSUMLENGTH]

set_sumlength:
	// oSum->lLength = lSumLength;
        ldr     x0, [sp, OSUM]
        ldr     x1, [sp, LSUMLENGTH]
        str     x1, [x0]

        // goto add_end;
        b       add_end

ret_false:
        // Epilogue and return FALSE
	mov 	x0, FALSE
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)

add_end:
        // Epilogue and return TRUE
        mov     x0, TRUE
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret
        
        .size   BigInt_add, (. - BigInt_add)
		