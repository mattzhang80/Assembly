//----------------------------------------------------------------------
// mywc.s
// Authors: Alex Delistathis, Matthew Zhang
//----------------------------------------------------------------------

        .section .rodata
        
printfFormatStr:
        .string "%7ld %7ld %7ld\n"
        
//----------------------------------------------------------------------
        .section .data

lLineCount:
        .8byte   0
lWordCount:
        .8byte   0
lCharCount:
        .8byte   0
iInWord:
        .4byte   0

//----------------------------------------------------------------------
        .section .bss

iChar:
        .skip   8
 
//----------------------------------------------------------------------
        .section .text

        //--------------------------------------------------------------
        // Enumerate and count how many lines, words, and characters
        // are in stdin. A word is a sequence of non-whitespace
        // characters. Whitespace is defined by the isspace() function.
        // Return 0.
        // int main(void)
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    MAIN_STACK_BYTECOUNT, 16

        .global main

main:
        // Prologue
        sub sp, sp, MAIN_STACK_BYTECOUNT
        str x30, [sp]

loop:
        // if ((iChar = getchar()) == EOF) goto endLoop;
        bl      getchar
        str     w0, [sp, iChar]
        cmp     w0, -1
        beq     endloop

        // lCharCount++;
        adr     x0, lCharCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

if1:
        // if (isspace(iChar) == FALSE) goto elseif1;
        ldr     w0, iChar
        bl      isspace
        cmp     w0, -1
        beq     elseif1

        // if (iInWord == FALSE) goto elseif2;
        ldr     w0, iInWord
        cmp     w0, 0
        beq     elseif2

        // lWordCount++;
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

        // iInWord = FALSE;
        mov     w0, 0
        str     w0, [sp, iInWord]

        // goto elseif2;
        b       elseif2

elseif1:
        // if (iInWord == TRUE) goto elseif2;
        ldr     w0, iInWord
        cmp     w0, 1
        beq     elseif2

        // iInWord = TRUE;
        mov     w0, 1
        str     w0, [sp, iInWord]

elseif2:
        // if (iChar != '\n') goto loop;
        ldr     w0, [sp, iChar]
        cmp     w0, 10
        bne     loop

        // lLineCount++;
        adr     x0, lLineCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

        // goto loop;
        b       loop
        
endloop:        
        // if (iInWord == FALSE) goto end;
        ldr     w0, iInWord
        cmp     w0, 0
        beq     end

        // lWordCount++;
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

        // goto end;
        b       end

end:
        // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
        adr     x0, printfFormatStr
        mov     x1, lLineCount
        mov     x2, lWordCount
        mov     x3, lCharCount
        bl      printf

        // Epilogue and return 0
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)
        
