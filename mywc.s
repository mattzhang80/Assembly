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
    sub sp, sp, 16
    str x30, [sp]

    ; Initialize iInWord in w2 to FALSE (0)
    mov w2, 0

loop:
    bl getchar
    mov w1, w0           ; Store character in w1
    cmp w1, -1
    beq endloop

    ; Increment lCharCount
    ldr x1, =lCharCount
    ldr x2, [x1]
    add x2, x2, 1
    str x2, [x1]

    ; Check if character is whitespace
    bl isspace
    cmp w0, 1
    beq char_is_space

    ; Character is not a space
    cmp w2, 0
    bne not_first_word
    ; First word character
    ldr x1, =lWordCount
    ldr x2, [x1]
    add x2, x2, 1
    str x2, [x1]
    mov w2, 1
    b loop

char_is_space:
    ; Character is a space, set iInWord to FALSE
    mov w2, 0
    cmp w1, 10           ; Check if newline
    bne loop
    ; Increment lLineCount
    ldr x1, =lLineCount
    ldr x2, [x1]
    add x2, x2, 1
    str x2, [x1]
    b loop

not_first_word:
    ; Logic for non-first word character
    b loop

endloop:
    ; Check iInWord for last word
    cmp w2, 1
    bne end
    ; Increment lWordCount
    ldr x1, =lWordCount
    ldr x2, [x1]
    add x2, x2, 1
    str x2, [x1]

end:
    ; Print results
    ldr x0, =printfFormatStr
    ldr x1, =lLineCount
    ldr x1, [x1]
    ldr x2, =lWordCount
    ldr x2, [x2]
    ldr x3, =lCharCount
    ldr x3, [x3]
    bl printf

    ; Epilogue and return 0
    mov w0, 0
    ldr x30, [sp]
    add sp, sp, 16
    ret

isspace:
    ; Simplified isspace function
    cmp w0, 32  ; Space
    cset w0, eq
    cmp w0, 10  ; Newline
    cset w0, eq
    ret
