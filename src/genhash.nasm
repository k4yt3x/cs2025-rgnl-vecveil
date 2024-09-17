section .data
    fmt db 'Hash: %lu', 10, 0
    err_usage db 'Usage: genhash <NAME>', 10, 0
    const dd 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8

section .bss
    name resb 32                          ; Reserve 32 bytes for the name input

section .text
    global _start
    extern printf

_start:
    ; Get argc from the stack
    mov rax, [rsp]                        ; argc is at [rsp]
    cmp rax, 2                            ; Check if argc >= 2
    je proceed                           ; If yes, proceed

    ; argc < 2, print usage message
    sub rsp, 8                            ; Align stack
    lea rdi, [rel err_usage]              ; Load usage message
    xor rax, rax                          ; Clear rax
    call printf
    add rsp, 8                            ; Restore stack

    ; Exit the program
    mov rax, 60                           ; sys_exit system call
    xor rdi, rdi                          ; Exit code 0
    syscall

proceed:
    ; Load argv[1] into rsi
    mov rsi, [rsp + 16]                   ; argv[1] is at [rsp + 16]

    ; Zero the 'name' buffer
    vpxor ymm0, ymm0, ymm0                ; Zero ymm0 register
    vmovdqu [rel name], ymm0              ; Zero first 32 bytes of 'name'

    ; Copy argv[1] into 'name' buffer, zero-padded up to 32 bytes
    mov rcx, 32                           ; Max 32 bytes to copy
    lea rdi, [rel name]                   ; Destination buffer 'name'
    ; rsi already points to argv[1]       ; Source string
copy_loop:
    cmp rcx, 0
    je copy_done                          ; If rcx == 0, we're done
    mov al, byte [rsi]                    ; Load byte from source
    mov byte [rdi], al                    ; Store byte to destination
    cmp al, 0
    je copy_done                          ; If null terminator, done
    inc rsi                               ; Increment source pointer
    inc rdi                               ; Increment destination pointer
    dec rcx                               ; Decrement counter
    jmp copy_loop

copy_done:
    ; Load the string into ymm0 using AVX2 instruction
    vmovdqu ymm0, [rel name]

    ; Extract lower 128 bits of ymm0 into xmm0
    vextracti128 xmm0, ymm0, 0

    ; Zero-extend bytes to words (16-bit integers)
    vpmovzxbw xmm1, xmm0

    ; Zero-extend words to doublewords (32-bit integers)
    vpmovzxwd ymm2, xmm1

    ; Convert packed 32-bit integers to single-precision floats
    vcvtdq2ps ymm3, ymm2

    ; Load constants into ymm4
    vmovups ymm4, [rel const]

    ; Perform floating-point multiplication
    vmulps ymm3, ymm3, ymm4

    ; Sum the elements in ymm3
    vextractf128 xmm5, ymm3, 0            ; Lower 128 bits
    vextractf128 xmm6, ymm3, 1            ; Upper 128 bits

    vhaddps xmm5, xmm5, xmm5              ; Horizontal add
    vhaddps xmm5, xmm5, xmm5
    vhaddps xmm6, xmm6, xmm6
    vhaddps xmm6, xmm6, xmm6

    vaddps xmm7, xmm5, xmm6               ; Combine sums

    ; Convert the floating-point sum to integer
    vpextrq rax, xmm7, 0

    ; Prepare for calling printf (align stack)
    sub rsp, 8                            ; Align stack

    ; Set up arguments for printf
    lea rdi, [rel fmt]                    ; Format string
    mov rsi, rax                          ; Integer value to print
    xor rax, rax                          ; Clear rax for variadic function

    ; Call printf
    call printf

    ; Clean up stack
    add rsp, 8                            ; Restore stack alignment

    ; Exit the program
    mov rax, 60                           ; sys_exit system call
    xor rdi, rdi                          ; Exit code 0
    syscall

