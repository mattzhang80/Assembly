//-------------------------------------------------------------------
// mywc.s
// Authors: Matthew Zhang and Alexander Delisthathis
//---------------------------------------------------------------------
EOF EQU -1
TAB EQU 9 ; tab ASCII
NEWLINE EQU 10 ; newline ASCII
VTAB EQU 11 ; vertical tab ASCII
FF EQU 12 ; form feed ASCII
CR EQU 13 ; carriage return ASCII
SPACE EQU 32 ; space ASCII
//---------------------------------------------------------------------
    .section .rodata

printfFormatStr:
    .string "%7ld %7ld %7ld\n"
//----------------------------------------------------------------------
    .section .data
//----------------------------------------------------------------------
    .section .bss
.align 8

lLineCount:
    .skip 8

lWordCount:
    .skip 8

lCharCount:
    .skip 8

.align 4

iChar: 
    .skip 4

iInWord: 
    .skip 4

//----------------------------------------------------------------------
    .section .text
    //------------------------------------------------------------------
    // Write to stdout counts of how many lines, words, and characters
    // are in stdin. A word is a sequence of non-whitespace characters.
    // Whitespace is defined by the isspace() function. Return 0. 
    //------------------------------------------------------------------
    
    // Must be a multiple of 16
    .equ    MAIN_STACK_BYTECOUNT, 16

// replicate isspace() function
isspace: 
    cmp x0, TAB
    beq isspace_return  
    cmp x0, NEWLINE
    beq isspace_return
    cmp x0, VTAB
    beq isspace_return
    cmp x0, FF
    beq isspace_return
    cmp x0, CR
    beq isspace_return
    cmp x0, SPACE
    beq isspace_return

    // if not whitespace, return 0
    mov x0, #0
    ret

// if whitespace, return 1
isspace_return:
    mov     x0, #1
    ret

.global main
main: 
    // Function prologue
    sub     sp, sp, MAIN_STACK_BYTECOUNT
    str     x30, [sp]

    //main loop
loop_start: 

    // while ((iChar = getchar()) != EOF)
    bl getchar
    mov iChar, x0
    cmp x0, EOF
    beq loop_end

    // lCharCount++
    adr x0, lCharCount
    ldr x1, [x0]
    add x1, x1, 1
    str x1, [x0]

    // check for whitespace and update lWordCount and iInWord
    bl isspace
    cmp x0, #1
    bne not_whitespace
    //unfinished section

    // Check for '\n' for newline
    cmp x0, NEWLINE
    bne loop_start ; if not newline, continue loop
    adr x0, lLineCount ; if newline, increment line count process
    ldr x1, [x0]
    add x1, x1, 1
    str x1, [x0]
    b loop_start ; unconditional branch to continue loop 

not_whitespace:
    //unfinished section

loop_end:
        // print out counts
        adr x0, lLineCount
        ldr x0, [x0]
        adr x1, lWordCount
        ldr x1, [x1]
        adr x2, lCharCount
        ldr x2, [x2]
        bl printf
    
        // Function epilogue
        mov w0, 0
        ldr x30, [sp]
        add sp, sp, MAIN_STACK_BYTECOUNT
        ret