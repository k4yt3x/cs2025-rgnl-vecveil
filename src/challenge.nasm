section .data

section .text
    global _start

_start:
    ; Use ptrace to detect if a debugger is attached
    mov rax, 0x42ca0000 ; PTRACE_TRACEME (101) in float
    vmovq xmm0, rax
    vcvttps2dq xmm0, xmm0
    vpextrq rax, xmm0, 0
    vzeroall
    vmovq rdi, xmm0
    vmovq rsi, xmm0
    vmovq rdx, xmm0
    vmovq r10, xmm0
    syscall

    ; Jump to the entry point if no debugger is attached (rax == 0)
    ; Jump to the stack (invalid) if a debugger is attached (rax != 0)
    vxorps ymm1, ymm1, ymm1
    vcvtsi2ss xmm1, xmm1, rax
    lea rax, [rel .name]
    vucomiss xmm0, xmm1
    cmovnz rax, rsp
    jmp rax
    db 0xE8

.name:
    ; Allocate 256 bytes on the stack
    ; sub rsp, 256
    mov rax, 0x43800000
    vmovq xmm0, rax
    vcvttps2dq xmm0, xmm0
    vinserti128 ymm0, ymm0, xmm0, 0

    vmovq xmm1, rsp
    vinserti128 ymm1, ymm1, xmm1, 0
    vpsubq ymm1, ymm1, ymm0
    vmovq rsp, xmm1

    ; Setup for write to stdout
    vpxor ymm0, ymm0, ymm0
    vpcmpeqd ymm1, ymm0, ymm0
    vpsrld ymm1, ymm1, 31
    vpextrq rax, xmm1, 0
    vpextrq rdi, xmm1, 0
    lea rsi, [rsp-28]

    ; mov rdx, 24
    mov rdx, 0x41c00000
    vmovq xmm2, rdx
    vcvttps2dq xmm2, xmm2
    vpextrq rdx, xmm2, 0

    ; "Please enter your name: "
    mov rbx, 0x61656c50
    vmovq xmm3, rbx
    vmovss dword [rsp-28], xmm3
    mov rbx, 0x65206573
    vmovq xmm3, rbx
    vmovss dword [rsp-24], xmm3
    mov rbx, 0x7265746e
    vmovq xmm3, rbx
    vmovss dword [rsp-20], xmm3
    mov rbx, 0x756f7920
    vmovq xmm3, rbx
    vmovss dword [rsp-16], xmm3
    mov rbx, 0x616e2072
    vmovq xmm3, rbx
    vmovss dword [rsp-12], xmm3
    mov rbx, 0x203a656d
    vmovq xmm3, rbx
    vmovss dword [rsp-8], xmm3
    vxorps xmm3, xmm3, xmm3
    vmovss dword [rsp-4], xmm3
    syscall

    ; Read 64 bytes from stdin, although only 33 bytes are needed
    vxorps ymm0, ymm0, ymm0
    vmovdqu [rsp-128], ymm0
    vmovq rax, xmm0
    vmovq rdi, xmm0
    lea rsi, [rsp-128]

    ; Read 64 bytes to [rsp-128]
    mov rdx, 0x42800000
    vmovq xmm2, rdx
    vcvttps2dq xmm2, xmm2
    vpextrq rdx, xmm2, 0
    syscall

    ; Check if the bytes read are less than 32
    vzeroall
    vcvtsi2ss xmm1, xmm1, rax ; xmm1 contains the number of bytes read

    ; Check if the input is empty
    vpxor ymm0, ymm0, ymm0
    vpcmpeqd ymm2, ymm0, ymm0
    vpsrld ymm2, ymm2, 31
    vcvtdq2ps  xmm2, xmm2
    vucomiss xmm1, xmm2
    jbe .nempty

    mov rbx, 0x42040000 ; 33 in float
    vmovq xmm2, rbx

    ; If we read more than 33 bytes, the input is invalid
    vucomiss xmm1, xmm2
    jbe .token

    vcvtsi2ss xmm2, xmm2, rdx
    vucomiss xmm1, xmm2
    jb .toolong1

    ; Check if we need to read more bytes
    cmp byte [rsi+rdx-1], 10
    je .toolong1
    jmp .overflow1

.nempty:
    ; Setup for write to stdout
    vpxor ymm0, ymm0, ymm0
    vpcmpeqd ymm1, ymm0, ymm0
    vpsrld ymm1, ymm1, 31
    vpextrq rax, xmm1, 0
    vpextrq rdi, xmm1, 0
    lea rsi, [rsp-28]

    ; mov rdx, 22
    mov rdx, 0x41b00000
    vmovq xmm2, rdx
    vcvttps2dq xmm2, xmm2
    vpextrq rdx, xmm2, 0

    ; "Name cannot be empty.\n"
    mov rbx, 0x656d614e
    vmovq xmm3, rbx
    vmovss dword [rsp-28], xmm3
    mov rbx, 0x6e616320
    vmovq xmm3, rbx
    vmovss dword [rsp-24], xmm3
    mov rbx, 0x20746f6e
    vmovq xmm3, rbx
    vmovss dword [rsp-20], xmm3
    mov rbx, 0x65206562
    vmovq xmm3, rbx
    vmovss dword [rsp-16], xmm3
    mov rbx, 0x7974706d
    vmovq xmm3, rbx
    vmovss dword [rsp-12], xmm3
    mov rbx, 0xa2e
    vmovq xmm3, rbx
    vmovss dword [rsp-8], xmm3
    vxorps xmm3, xmm3, xmm3
    vmovss dword [rsp-4], xmm3
    syscall
    jmp .exit1

; Read and discard the remaining input
.overflow1:
    vxorps ymm0, ymm0, ymm0
    vmovq rax, xmm0
    vmovq rdi, xmm0
    lea rsi, [rsp-16]

    ; mov rdx, 16
    mov rdx, 0x41800000
    vmovq xmm2, rdx
    vcvttps2dq xmm2, xmm2
    vpextrq rdx, xmm2, 0
    syscall

    vxorps ymm1, ymm1, ymm1
    vxorps ymm2, ymm2, ymm2
    vcvtsi2ss xmm1, xmm1, rax
    vcvtsi2ss xmm2, xmm2, rdx

    ; After reading all remaining bytes, print an error message
    vucomiss xmm1, xmm2
    jb .toolong1

    cmp byte [rsi+rdx-1], 10
    jne .overflow1

.toolong1:
    ; Setup for write to stdout
    vpxor ymm0, ymm0, ymm0
    vpcmpeqd ymm1, ymm0, ymm0
    vpsrld ymm1, ymm1, 31
    vpextrq rax, xmm1, 0
    vpextrq rdi, xmm1, 0
    lea rsi, [rsp-48]

    ; mov rdx, 41
    mov rdx, 0x42240000
    vmovq xmm2, rdx
    vcvttps2dq xmm2, xmm2
    vpextrq rdx, xmm2, 0

    ; "Names can contain at most 32 characters.\n"
    mov rbx, 0x656d614e
    vmovq xmm3, rbx
    vmovss dword [rsp-48], xmm3
    mov rbx, 0x61632073
    vmovq xmm3, rbx
    vmovss dword [rsp-44], xmm3
    mov rbx, 0x6f63206e
    vmovq xmm3, rbx
    vmovss dword [rsp-40], xmm3
    mov rbx, 0x6961746e
    vmovq xmm3, rbx
    vmovss dword [rsp-36], xmm3
    mov rbx, 0x7461206e
    vmovq xmm3, rbx
    vmovss dword [rsp-32], xmm3
    mov rbx, 0x736f6d20
    vmovq xmm3, rbx
    vmovss dword [rsp-28], xmm3
    mov rbx, 0x32332074
    vmovq xmm3, rbx
    vmovss dword [rsp-24], xmm3
    mov rbx, 0x61686320
    vmovq xmm3, rbx
    vmovss dword [rsp-20], xmm3
    mov rbx, 0x74636172
    vmovq xmm3, rbx
    vmovss dword [rsp-16], xmm3
    mov rbx, 0x2e737265
    vmovq xmm3, rbx
    vmovss dword [rsp-12], xmm3
    mov rbx, 0xa
    vmovq xmm3, rbx
    vmovss dword [rsp-8], xmm3
    vxorps xmm3, xmm3, xmm3
    vmovss dword [rsp-4], xmm3
    syscall
    jmp .exit1

.token:
    ; Remove the newline character
    mov byte [rsi+rax-1], 0

    ; Setup for write to stdout
    vpxor ymm0, ymm0, ymm0
    vpcmpeqd ymm1, ymm0, ymm0
    vpsrld ymm1, ymm1, 31
    vpextrq rax, xmm1, 0
    vpextrq rdi, xmm1, 0
    lea rsi, [rsp-30]

    ; mov rdx, 25
    mov rdx, 0x41c80000
    vmovq xmm2, rdx
    vcvttps2dq xmm2, xmm2
    vpextrq rdx, xmm2, 0

    ; "Please enter your token: "
    mov rbx, 0x61656c50
    vmovq xmm3, rbx
    vmovss dword [rsp-30], xmm3
    mov rbx, 0x65206573
    vmovq xmm3, rbx
    vmovss dword [rsp-26], xmm3
    mov rbx, 0x7265746e
    vmovq xmm3, rbx
    vmovss dword [rsp-22], xmm3
    mov rbx, 0x756f7920
    vmovq xmm3, rbx
    vmovss dword [rsp-18], xmm3
    mov rbx, 0x6f742072
    vmovq xmm3, rbx
    vmovss dword [rsp-14], xmm3
    mov rbx, 0x3a6e656b
    vmovq xmm3, rbx
    vmovss dword [rsp-10], xmm3
    mov rbx, 0x20
    vmovq xmm3, rbx
    vmovss dword [rsp-6], xmm3
    vxorps xmm3, xmm3, xmm3
    vmovss dword [rsp-2], xmm3
    syscall

    ; Read 64 bytes from stdin, although only 20 bytes are needed
    vxorps ymm0, ymm0, ymm0
    vmovdqu [rsp-192], ymm0
    vmovq rax, xmm0
    vmovq rdi, xmm0
    lea rsi, [rsp-192]

    ; Read 64 bytes to [rsp-192]
    mov rdx, 0x42800000
    vmovq xmm2, rdx
    vcvttps2dq xmm2, xmm2
    vpextrq rdx, xmm2, 0
    syscall

    ; Check if the bytes read are less than 21
    vzeroall
    vcvtsi2ss xmm1, xmm1, rax ; xmm1 contains the number of bytes read

    ; Check if the input is empty
    vpxor ymm0, ymm0, ymm0
    vpcmpeqd ymm2, ymm0, ymm0
    vpsrld ymm2, ymm2, 31
    vcvtdq2ps  xmm2, xmm2
    vucomiss xmm1, xmm2
    jbe .tempty

    mov rbx, 0x41a80000 ; 21 in float
    vmovq xmm2, rbx

    ; If we read more than 21 bytes, the input is invalid
    vucomiss xmm1, xmm2
    jbe .atoi

    vcvtsi2ss xmm2, xmm2, rdx
    vucomiss xmm1, xmm2
    jb .toolong2

    ; Check if we need to read more bytes
    cmp byte [rsi+rdx-1], 10
    je .toolong2
    jmp .overflow2

.tempty:
    ; Setup for write to stdout
    vpxor ymm0, ymm0, ymm0
    vpcmpeqd ymm1, ymm0, ymm0
    vpsrld ymm1, ymm1, 31
    vpextrq rax, xmm1, 0
    vpextrq rdi, xmm1, 0
    lea rsi, [rsp-28]

    ; mov rdx, 23
    mov rdx, 0x41b80000
    vmovq xmm2, rdx
    vcvttps2dq xmm2, xmm2
    vpextrq rdx, xmm2, 0

    ; "Token cannot be empty.\n"
    mov rbx, 0x656b6f54
    vmovq xmm3, rbx
    vmovss dword [rsp-28], xmm3
    mov rbx, 0x6163206e
    vmovq xmm3, rbx
    vmovss dword [rsp-24], xmm3
    mov rbx, 0x746f6e6e
    vmovq xmm3, rbx
    vmovss dword [rsp-20], xmm3
    mov rbx, 0x20656220
    vmovq xmm3, rbx
    vmovss dword [rsp-16], xmm3
    mov rbx, 0x74706d65
    vmovq xmm3, rbx
    vmovss dword [rsp-12], xmm3
    mov rbx, 0xa2e79
    vmovq xmm3, rbx
    vmovss dword [rsp-8], xmm3
    vxorps xmm3, xmm3, xmm3
    vmovss dword [rsp-4], xmm3
    syscall
    jmp .exit1

; Read and discard the remaining input
.overflow2:
    vxorps ymm0, ymm0, ymm0
    vmovq rax, xmm0
    vmovq rdi, xmm0
    lea rsi, [rsp-16]

    ; mov rdx, 16
    mov rdx, 0x41800000
    vmovq xmm2, rdx
    vcvttps2dq xmm2, xmm2
    vpextrq rdx, xmm2, 0
    syscall

    vxorps ymm1, ymm1, ymm1
    vxorps ymm2, ymm2, ymm2
    vcvtsi2ss xmm1, xmm1, rax
    vcvtsi2ss xmm2, xmm2, rdx

    ; After reading all remaining bytes, print an error message
    vucomiss xmm1, xmm2
    jb .toolong2

    cmp byte [rsi+rdx-1], 10
    jne .overflow2

.toolong2:
    ; Setup for write to stdout
    vpxor ymm0, ymm0, ymm0
    vpcmpeqd ymm1, ymm0, ymm0
    vpsrld ymm1, ymm1, 31
    vpextrq rax, xmm1, 0
    vpextrq rdi, xmm1, 0
    lea rsi, [rsp-48]

    ; mov rdx, 42
    mov rdx, 0x42280000
    vmovq xmm2, rdx
    vcvttps2dq xmm2, xmm2
    vpextrq rdx, xmm2, 0

    ; "Tokens can contain at most 20 characters.\n"
    mov rbx, 0x656b6f54
    vmovq xmm3, rbx
    vmovss dword [rsp-48], xmm3
    mov rbx, 0x6320736e
    vmovq xmm3, rbx
    vmovss dword [rsp-44], xmm3
    mov rbx, 0x63206e61
    vmovq xmm3, rbx
    vmovss dword [rsp-40], xmm3
    mov rbx, 0x61746e6f
    vmovq xmm3, rbx
    vmovss dword [rsp-36], xmm3
    mov rbx, 0x61206e69
    vmovq xmm3, rbx
    vmovss dword [rsp-32], xmm3
    mov rbx, 0x6f6d2074
    vmovq xmm3, rbx
    vmovss dword [rsp-28], xmm3
    mov rbx, 0x32207473
    vmovq xmm3, rbx
    vmovss dword [rsp-24], xmm3
    mov rbx, 0x68632030
    vmovq xmm3, rbx
    vmovss dword [rsp-20], xmm3
    mov rbx, 0x63617261
    vmovq xmm3, rbx
    vmovss dword [rsp-16], xmm3
    mov rbx, 0x73726574
    vmovq xmm3, rbx
    vmovss dword [rsp-12], xmm3
    mov rbx, 0xa2e
    vmovq xmm3, rbx
    vmovss dword [rsp-8], xmm3
    vxorps xmm3, xmm3, xmm3
    vmovss dword [rsp-4], xmm3
    syscall
    jmp .exit1

.atoi:
    xor rbx, rbx
    lea rdi, [rsp-192]

.atoiloop:
    movzx rax, byte [rdi]
    sub rax, '0'
    imul rbx, rbx, 10
    add rbx, rax
    inc rdi

    cmp byte [rdi], 10
    je .verify

    cmp byte [rdi], 0
    jne .atoiloop

; Verify if the password is correct
.verify:
    mov dword [rsp-200], 0x3fe66666
    mov dword [rsp-204], 0x3fd9999a
    mov dword [rsp-208], 0x3fcccccd
    mov dword [rsp-212], 0x3fc00000
    mov dword [rsp-216], 0x3fb33333
    mov dword [rsp-220], 0x3fa66666
    mov dword [rsp-224], 0x3f99999a
    mov dword [rsp-228], 0x3f8ccccd

    ; Load name into ymm0
    vmovdqu ymm0, [rsp-128]

    vextracti128 xmm0, ymm0, 0
    vpmovzxbw xmm1, xmm0
    vpmovzxwd ymm2, xmm1
    vcvtdq2ps ymm3, ymm2
    vmovups ymm4, [rsp-228]
    vmulps ymm3, ymm3, ymm4
    vextractf128 xmm5, ymm3, 0 ; Lower 128 bits
    vextractf128 xmm6, ymm3, 1 ; Upper 128 bits
    vhaddps xmm5, xmm5, xmm5 ; Horizontal add
    vhaddps xmm5, xmm5, xmm5
    vhaddps xmm6, xmm6, xmm6
    vhaddps xmm6, xmm6, xmm6
    vaddps xmm7, xmm5, xmm6 ; Combine sums
    vpextrq rax, xmm7, 0
    vmovq xmm5, rbx
    vucomiss xmm5, xmm7
    je .correct

.incorrect:
    vpxor ymm0, ymm0, ymm0
    vpcmpeqd ymm1, ymm0, ymm0
    vpsrld ymm1, ymm1, 31
    vpextrq rax, xmm1, 0
    vpextrq rdi, xmm1, 0
    lea rsi, [rsp-32]

    ; mov rdx, 24
    mov rbx, 0x41c00000
    vmovq xmm3, rbx
    vcvttps2dq xmm3, xmm3
    vpextrq rdx, xmm3, 0

    ; "Invalid token proivded.\n"
    mov rbx, 0x61766e49
    vmovq xmm3, rbx
    vmovss dword [rsp-32], xmm3
    mov rbx, 0x2064696c
    vmovq xmm3, rbx
    vmovss dword [rsp-28], xmm3
    mov rbx, 0x656b6f74
    vmovq xmm3, rbx
    vmovss dword [rsp-24], xmm3
    mov rbx, 0x7270206e
    vmovq xmm3, rbx
    vmovss dword [rsp-20], xmm3
    mov rbx, 0x6469766f
    vmovq xmm3, rbx
    vmovss dword [rsp-16], xmm3
    mov rbx, 0xa2e6465
    vmovq xmm3, rbx
    vmovss dword [rsp-12], xmm3
    vxorps xmm3, xmm3, xmm3
    vmovss dword [rsp-8], xmm3
    syscall

.exit1:
    ; exit(1)
    mov rax, 0x42700000
    vmovq xmm1, rax
    vcvttps2dq xmm1, xmm1
    vpextrq rax, xmm1, 0

    vpxor ymm0, ymm0, ymm0
    vpcmpeqd ymm1, ymm0, ymm0
    vpsrld ymm1, ymm1, 31
    vpextrq rdi, xmm1, 0
    syscall

.correct:
    vpxor ymm0, ymm0, ymm0
    vpcmpeqd ymm1, ymm0, ymm0
    vpsrld ymm1, ymm1, 31
    vpextrq rax, xmm1, 0
    vpextrq rdi, xmm1, 0
    lea rsi, [rsp-40]

    ; mov rdx, 34
    mov rbx, 0x42080000
    vmovq xmm3, rbx
    vcvttps2dq xmm3, xmm3
    vpextrq rdx, xmm3, 0

    ; "Your identity has been validated.\n"
    mov rbx, 0x72756f59
    vmovq xmm3, rbx
    vmovss dword [rsp-40], xmm3
    mov rbx, 0x65646920
    vmovq xmm3, rbx
    vmovss dword [rsp-36], xmm3
    mov rbx, 0x7469746e
    vmovq xmm3, rbx
    vmovss dword [rsp-32], xmm3
    mov rbx, 0x61682079
    vmovq xmm3, rbx
    vmovss dword [rsp-28], xmm3
    mov rbx, 0x65622073
    vmovq xmm3, rbx
    vmovss dword [rsp-24], xmm3
    mov rbx, 0x76206e65
    vmovq xmm3, rbx
    vmovss dword [rsp-20], xmm3
    mov rbx, 0x64696c61
    vmovq xmm3, rbx
    vmovss dword [rsp-16], xmm3
    mov rbx, 0x64657461
    vmovq xmm3, rbx
    vmovss dword [rsp-12], xmm3
    mov rbx, 0xa2e
    vmovq xmm3, rbx
    vmovss dword [rsp-8], xmm3
    vxorps xmm3, xmm3, xmm3
    vmovss dword [rsp-4], xmm3
    syscall

.exit0:
    ; exit(0)
    mov rax, 0x42700000
    vmovq xmm1, rax
    vcvttps2dq xmm1, xmm1
    vpextrq rax, xmm1, 0
    vxorps xmm1, xmm1, xmm1
    vpextrq rdi, xmm1, 0
    syscall
