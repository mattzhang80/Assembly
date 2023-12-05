// This code assumes that the function arguments are stored in the following registers:
// oAddend1: rdi
// oAddend2: rsi
// oSum: rdx

// Prologue
push rbp
mov rbp, rsp

; Initialize variables
mov ulCarry, 0
mov ulSum, 0
mov lIndex, 0
mov lSumLength, 0

// Check for NULL pointers
cmp oAddend1, rax
je error1
cmp oAddend2, rax
je error2
cmp oSum, rax
je error3
cmp oSum, oAddend1
je error4
cmp oSum, oAddend2
je error5

// Determine the larger length
cmp oAddend1->lLength, oAddend2->lLength
jl greater_oAddend2
mov lSumLength, oAddend1->lLength
jmp done_length_comparison

greater_oAddend2:
mov lSumLength, oAddend2->lLength

done_length_comparison:

// Clear oSum's array if necessary
cmp oSum->lLength, lSumLength
jl skip_clear_oSum
mov rcx, MAX_DIGITS
xor rax, rax
lea rdi, [oSum->aulDigits]
rep stosb

skip_clear_oSum:

// Perform the addition
loop1:
cmp lIndex, lSumLength
jge endloop1

mov rax, [oAddend1->aulDigits + lIndex * 8]
add ulSum, rax
mov rcx, [oAddend2->aulDigits + lIndex * 8]
add ulSum, rcx
cmp ulSum, rax
jge no_carry
cmp ulSum, rcx
jge no_carry
inc ulCarry

no_carry:
mov [oSum->aulDigits + lIndex * 8], ulSum
inc lIndex
jmp loop1

endloop1:

// Check for a carry out of the last "column" of the addition
cmp ulCarry, 1
jne endif1

cmp lSumLength, MAX_DIGITS
je return_false

mov [oSum->aulDigits + lSumLength * 8], 1
inc lSumLength

endif1:

// Set the length of the sum
mov oSum->lLength, lSumLength

// Return TRUE
mov rax, 1
leave
ret

error1:
mov rax, -1
mov rsp, rbp
pop rbp
ret

error2:
mov rax, -2
mov rsp, rbp
pop rbp
ret

error3:
mov rax, -3
mov rsp, rbp
pop rbp
ret

error4:
mov rax, -4
mov rsp, rbp
pop rbp
ret

error5:
mov rax, -5
mov rsp, rbp
pop rbp
ret
