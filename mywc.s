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
        .skip   4
 
//----------------------------------------------------------------------
        .section .text

        //--------------------------------------------------------------
        // Enumerate and count how many lines, words, and characters
        // are in stdin. A word is a sequence of non-whitespace
        // characters. Whitespace is defined by the isspace() function.
        // Return 0.
        // int main(void)
        //--------------------------------------------------------------

        // EOF
        .equ    EOF, -1

        // EOL
        .equ    EOL, '\n'
        
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
        adr     x1, iChar
        str     w0, [x1]
        cmp     w0, EOF
        beq     endloop

        // lCharCount++;
        adr     x0, lCharCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

if1:
        // if (isspace(iChar) == FALSE) goto elseif1;
        adr     x1, iChar
        ldr     w0, [x1]
        bl      isspace
        cmp     w0, 0
        beq     elseif1

        // if (iInWord == FALSE) goto elseif2;
        adr     x0, iInWord
        ldr     w1, [x0]
        cmp     w1, 0
        beq     elseif2

        // lWordCount++;
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

        // iInWord = FALSE;
        adr     x0, iInWord
        mov     w1, 0
        str     w1, [x0]
        
        // goto elseif2;
        b       elseif2

elseif1:
        // if (iInWord == TRUE) goto elseif2;
        adr     x0, iInWord
        ldr     w1, [x0]
        cmp     w1, 1
        beq     elseif2

        // iInWord = TRUE;
        adr     x0, iInWord
        mov     w1, 1
        str     w1, [x0]

elseif2:
        // if (iChar != '\n') goto loop;
        adr     x1, iChar
        ldr     w0, [x1]
        cmp     w0, EOL
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
        adr     x0, iInWord
        ldr     w1, [x0]
        cmp     w1, 0
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
        adr     x1, lLineCount
        ldr     x1, [x1]
        adr     x2, lWordCount
        ldr     x2, [x2]
        adr     x3, lCharCount
        ldr     x3, [x3]
        bl      printf

        // Epilogue and return 0
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)