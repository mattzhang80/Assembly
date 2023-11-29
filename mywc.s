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
iInWord:
    .space 4

.section .text
.global main
main:
    sub sp, sp, 16  // Stack frame setup
    str x30, [sp]   // Save return address

    // Initialize iInWord to FALSE (0)
    mov w2, 0
    str w2, [sp, 12]

loop:
    bl getchar
    cmp w0, -1  // Check for EOF
    beq endloop

    // Increment lCharCount
    ldr x1, =lCharCount
    ldr x2, [x1]
    add x2, x2, 1
    str x2, [x1]

    // Check if character is whitespace
    bl isspace
    cmp w0, 0
    beq char_is_space

    // Character is not a space
    ldr w2, [sp, 12]
    cmp w2, 0
    bne not_first_word
    ldr x1, =lWordCount
    ldr x2, [x1]
    add x2, x2, 1
    str x2, [x1]
    mov w2, 1  // Set iInWord to TRUE
    str w2, [sp, 12]
    b loop

char_is_space:
    // Character is a space, set iInWord to FALSE
    mov w2, 0
    str w2, [sp, 12]
    cmp w0, 10  // Check if newline
    bne loop

    // Increment lLineCount
    ldr x1, =lLineCount
    ldr x2, [x1]
    add x2, x2, 1
    str x2, [x1]
    b loop

not_first_word:
    b loop  // Continue the loop

endloop:
    // Check iInWord for last word
    ldr w2, [sp, 12]
    cmp w2, 0
    beq end

    // Increment lWordCount
    ldr x1, =lWordCount
    ldr x2, [x1]
    add x2, x2, 1
    str x2, [x1]

end:
    // Print results
    ldr x0, =printfFormatStr
    ldr x1, =lLineCount
    ldr x1, [x1]
    ldr x2, =lWordCount
    ldr x2, [x2]
    ldr x3, =lCharCount
    ldr x3, [x3]
    bl printf

    // Epilogue
    mov w0, 0
    ldr x30, [sp]
    add sp, sp, 16
    ret

isspace:
    // Simplified isspace function
    cmp w0, 32  // Space
    cset w0, eq
    cmp w0, 10  // Newline
    cset w0, eq
    ret
