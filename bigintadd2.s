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
        
        //--------------------------------------------------------------
        // Return the larger of lLength1 and lLength2.
        //
        // static long BigInt_larger(long lLength1, long lLength2)
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    LARGER_STACK_BYTECOUNT, 32 

        // Local Variable Stack Offsets
        .equ    LLARGER, 8
        
        // Parameter Stack Offsets
        .equ    LLENGTH1, 16
        .equ    LLENGTH2, 24
