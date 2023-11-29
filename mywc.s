.section .rodata
printfFormatStr:
    .string "%7ld %7ld %7ld\n"

.section .bss
.align 8
lLineCount:
    .space 8
lWordCount:
    .space 8
lCharCount:
    .space 8

.section .text
.global main
main:
    sub sp, sp, 16  // Set up stack frame
    str x30, [sp]   // Save return address

loop:
    bl getchar
    mov w1, w0      // Store character in w1
    cmp w1, -1
    beq endloop     // Check for EOF

    ldr x1, =lCharCount
    ldr x2, [x1]
    add x2, x2, 1
    str x2, [x1]    // Increment lCharCount

    bl isspace
    cmp w0, 1
    beq char_is_space

    cmp w2, 0
    bne not_first_word
    ldr x1, =lWordCount
    ldr x2, [x1]
    add x2, x2, 1
    str x2, [x1]
    mov w2, 1       // Set iInWord to TRUE
    b loop

char_is_space:
    mov w2, 0       // Set iInWord to FALSE
    cmp w1, 10
    bne loop
    ldr x1, =lLineCount
    ldr x2, [x1]
    add x2, x2, 1
    str x2, [x1]    // Increment lLineCount
    b loop

not_first_word:
    b loop          // Continue the loop

endloop:
    cmp w2, 1
    bne end
    ldr x1, =lWordCount
    ldr x2, [x1]
    add x2, x2, 1
    str x2, [x1]    // Increment lWordCount

end:
    ldr x0, =printfFormatStr
    ldr x1, =lLineCount
    ldr x1, [x1]
    ldr x2, =lWordCount
    ldr x2, [x2]
    ldr x3, =lCharCount
    ldr x3, [x3]
    bl printf       // Print results

    mov w0, 0
    ldr x30, [sp]
    add sp, sp, 16  // Restore stack frame
    ret

isspace:
    // Simplified isspace function
    cmp w0, 32
    cset w0, eq
    cmp w0, 10
    cset w0, eq
    ret
