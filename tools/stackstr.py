#!/usr/bin/python3
# -*- coding: utf-8 -*-
import sys

STRING = sys.argv[1].replace("\\n", "\n")
STACK_START_OFFSET = len(STRING) + (4 - (len(STRING) % 4)) + 4
CHUNK_SIZE = 4


def chunks(lst, n):
    for i in range(0, len(lst), n):
        yield lst[i : i + n]


for chk in chunks(STRING, CHUNK_SIZE):
    stack_uint = "0x"
    for c in reversed(chk):
        stack_uint += hex(ord(c))[2:]
    print(f"    mov rbx, {stack_uint}")
    print("    vmovq xmm3, rbx")
    print(f"    vmovss dword [rsp-{STACK_START_OFFSET}], xmm3")
    STACK_START_OFFSET -= CHUNK_SIZE

print("    vxorps xmm3, xmm3, xmm3")
print("    vmovss dword [rsp-{}], xmm3".format(STACK_START_OFFSET))

print("\nString length: {}".format(len(STRING)))
