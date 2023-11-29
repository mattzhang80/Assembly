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
iChar:
    .space 4

.section .text
.global main
main:
    // Prologue
    sub sp, sp, #48
    stp x29, x30, [sp, #32]
    add x29, sp, #32

    // Initialize iInWord to FALSE (0)
    mov w8, 0
    str w8, [sp, #12]

    // Main loop
loop:
    bl getchar
    str w0, [sp, #16]      // Store character in iChar
    cmp w0, #-1
    beq endloop

    // Increment lCharCount
    ldr x8, [sp, #24]
    add x8, x8, #1
    str x8, [sp, #24]

    // Check if character is whitespace
    bl _isspace
    cmp w0, #1
    beq char_is_whitespace

    // Character is not whitespace
    ldr w8, [sp, #12]
    cmp w8, #0
    bne char_is_not_whitespace

    // Found start of a new word
    ldr x8, [sp, #32]
    add x8, x8, #1
    str x8, [sp, #32]
    mov w8, #1
    str w8, [sp, #12]
    b loop

char_is_whitespace:
    // Character is a whitespace
    ldr w8, [sp, #12]
    cmp w8, #1
    bne check_newline

    // Set iInWord to FALSE
    mov w8, #0
    str w8, [sp, #12]

check_newline:
    ldr w8, [sp, #16]
    cmp w8, #10
    bne loop

    // Increment lLineCount
    ldr x8, [sp, #40]
    add x8, x8, #1
    str x8, [sp, #40]
    b loop

char_is_not_whitespace:
    b loop

endloop:
    // Check if last character was part of a word
    ldr w8, [sp, #12]
    cmp w8, #1
    bne end

    // Increment lWordCount for last word
    ldr x8, [sp, #32]
    add x8, x8, #1
    str x8, [sp, #32]

end:
    // Print results
    ldr x0, [sp, #40]
    ldr x1, [sp, #32]
    ldr x2, [sp, #24]
    ldr x3, printfFormatStr
    bl printf

    // Epilogue
    mov w0, #0
    ldp x29, x30, [sp, #32]
    add sp, sp, #48
    ret

_isspace:
    // Check if character is a space or newline
    // Character to check is passed in w0

    // Compare with space (ASCII 32)
    cmp w0, #32
    beq is_space

    // Compare with newline (ASCII 10)
    cmp w0, #10
    beq is_space

    // Not a whitespace character, return 0
    mov w0, #0
    ret

is_space:
    // It's a whitespace character, return 1
    mov w0, #1
    ret
