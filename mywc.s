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
    sub sp, sp, 16    // Stack frame setup
    str x30, [sp]     // Save return address

    // Initialize iInWord to FALSE (0)
    mov w1, 0
    str w1, [sp, 12]

loop:
    bl getchar        // Call getchar
    cmp w0, -1        // Check for EOF
    beq endloop
    mov w1, w0        // Store character in w1

    // Increment lCharCount
    ldr x2, =lCharCount
    ldr x3, [x2]
    add x3, x3, 1
    str x3, [x2]

    // Check if character is a whitespace
    bl isspace
    cmp w0, 1
    beq char_is_space

    // Character is not a space
    ldr w2, [sp, 12]
    cmp w2, 0
    bne loop          // Continue if already in a word

    // Starting a new word
    ldr x2, =lWordCount
    ldr x3, [x2]
    add x3, x3, 1
    str x3, [x2]
    mov w2, 1         // Set iInWord to TRUE
    str w2, [sp, 12]
    b loop

char_is_space:
    // Character is a space, set iInWord to FALSE
    mov w2, 0
    str w2, [sp, 12]
    cmp w1, 10        // Check if newline
    bne loop

    // Increment lLineCount for newline
    ldr x2, =lLineCount
    ldr x3, [x2]
    add x3, x3, 1
    str x3, [x2]
    b loop

endloop:
    // Check iInWord for last word
    ldr w2, [sp, 12]
    cmp w2, 1
    bne end

    // Increment lWordCount for last word
    ldr x2, =lWordCount
    ldr x3, [x2]
    add x3, x3, 1
    str x3, [x2]

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
