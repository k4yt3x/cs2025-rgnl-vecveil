section .data

section .text
global _start

_start:
    lea rax, [rel .ptrace]
    jmp short rax
    db 0xE8

.ptrace:
    ; Use ptrace to detect if a debugger is attached
    mov rax, 101
    mov rdi, 0
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall

    ; Jump to the entry point if no debugger is attached
    test rax, rax
    jz .entry
    db 0xEB

.entry:
    ; Write "Enter the password: " to stdout
    mov rax, 1
    mov rdi, 1
    lea rsi, [rsp-64]
    mov rdx, 20

    ; Push "Enter the password: " (20 bytes) in little-endian format
    mov dword [rsp-64], 0x65746e45
    mov dword [rsp-60], 0x68742072
    mov dword [rsp-56], 0x61702065
    mov dword [rsp-52], 0x6f777373
    mov dword [rsp-48], 0x203a6472
    mov byte [rsp-44], 0x0
    syscall

    ; Read 30 bytes from stdin into [rsp-8]
    mov rax, 0
    mov rdi, 0
    lea rsi, [rsp-30]
    mov rdx, 30
    syscall

    cmp rax, rdx
    jb .verify

    cmp byte[rsi+rdx-1], 10
    je .verify

; Read and discard the remaining input
.overflow:
    mov rax, 0
    mov rdi, 0
    lea rsi, [rsp-64]
    mov rdx, 8
    syscall

    cmp rax, rdx
    jb .verify

    cmp byte [rsi+rdx-1], 10
    jne .overflow

; Verify if the password is correct
.verify:
    mov rax, [rsp-30]
    mov rbx, 0x0893c7dae819efee
    xor rax, rbx
    mov rbx, 0x4ed68298ac58aaaa
    xor rax, rbx
    test rax, rax
    je short .correct

.incorrect:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rsp-64]
    mov rdx, 25
    mov dword [rsp-64], 0x6e6f7257
    mov dword [rsp-60], 0x6e612067
    mov dword [rsp-56], 0x72657773
    mov dword [rsp-52], 0x7254202e
    mov dword [rsp-48], 0x67612079
    mov dword [rsp-44], 0x2e6e6961
    mov byte [rsp-40], 0x0a
    mov byte [rsp-39], 0x0
    syscall
    jmp short .exit

.correct:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rsp-64]
    mov rdx, 16
    mov dword [rsp-64], 0x72726f43
    mov dword [rsp-60], 0x20746365
    mov dword [rsp-56], 0x77736e61
    mov dword [rsp-52], 0x0a217265
    mov byte [rsp-48], 0x0
    syscall

.exit:
    mov rax, 60
    xor rdi, rdi
    syscall
