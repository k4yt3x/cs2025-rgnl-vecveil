.PHONY: all shellcode build debug genhash clean

SRCDIR=src
INCDIR=include
BINDIR=bin
OBJDIR=obj
CFLAGS=-Wall -fPIC -I$(INCDIR)

# DJB2 hashing lookup
DJB2=1

# specify DJB2=1 to enable DJB2 hashing lookup
ifeq ($(DJB2), 1)
    DJB2_FLAG=-DDJB2
else
    DJB2_FLAG=
endif

fast: prepare shellcode genhash
	gcc $(CFLAGS) $(DJB2_FLAG) -Ofast -s $(SRCDIR)/lexicon.c -o $(BINDIR)/lexicon

build: prepare shellcode genhash
	gcc $(CFLAGS) $(DJB2_FLAG) -s $(SRCDIR)/lexicon.c -o $(BINDIR)/lexicon

debug: prepare shellcode genhash
	gcc $(CFLAGS) $(DJB2_FLAG) -g -DDEBUG $(SRCDIR)/lexicon.c -o $(BINDIR)/lexicon

shellcode: prepare
	nasm -f elf64 src/challenge.nasm -o $(OBJDIR)/challenge.o
	ld -o bin/challenge.bin -N -Ttext 0x0 --oformat binary $(OBJDIR)/challenge.o
	python3 tools/encoder.py bin/challenge.bin include/shellcode.h

genhash: prepare
	nasm -f elf64 -g -F dwarf $(SRCDIR)/genhash.nasm -o $(OBJDIR)/genhash.o
	ld -lc -I /lib64/ld-linux-x86-64.so.2 -o $(BINDIR)/genhash $(OBJDIR)/genhash.o

prepare:
	mkdir -p $(BINDIR) $(OBJDIR)

clean:
	rm -f $(SRCDIR)/*.o $(BINDIR)/lexicon

