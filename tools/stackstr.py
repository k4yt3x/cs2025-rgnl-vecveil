#!/usr/bin/python3
# -*- coding: utf-8 -*-

STRING = "Correct answer!"
STACK_START_OFFSET = 64
CHUNK_SIZE = 4


def chunks(lst, n):
    for i in range(0, len(lst), n):
        yield lst[i : i + n]


for chk in chunks(STRING, CHUNK_SIZE):
    stack_uint = "0x"
    for c in reversed(chk):
        stack_uint += hex(ord(c))[2:]
    print("mov dword [rsp-{}], {}".format(STACK_START_OFFSET, stack_uint))
    STACK_START_OFFSET -= CHUNK_SIZE

print("mov byte [rsp-{}], 0x0".format(STACK_START_OFFSET))

print("\nString length: {}".format(len(STRING)))
