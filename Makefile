.PHONY: all payload build debug genhash clean

SRCDIR=src
BINDIR=bin
OBJDIR=obj
CFLAGS=-Wall -fPIC -I$(SRCDIR)

# DJB2 hashing lookup enabled by default
DJB2=1

# specify DJB2=1 to enable DJB2 hashing lookup
ifeq ($(DJB2), 1)
    DJB2_FLAG=-DDJB2
else
    DJB2_FLAG=
endif

all: payload build genhash

payload:
	mkdir -p $(BINDIR) $(OBJDIR)
	nasm -f elf64 src/challenge.nasm -o $(OBJDIR)/challenge.o
	ld -lc -o bin/challenge.bin -N -Ttext 0x0 --oformat binary $(OBJDIR)/challenge.o
	python3 tools/encoder.py bin/challenge.bin

build:
	mkdir -p $(BINDIR)
	gcc $(CFLAGS) $(DJB2_FLAG) -Ofast -s $(SRCDIR)/lexicon.c -o $(BINDIR)/lexicon

debug:
	mkdir -p $(BINDIR)
	gcc $(CFLAGS) $(DJB2_FLAG) -g -DDEBUG $(SRCDIR)/lexicon.c \
		-no-pie -fno-stack-protector -Wl,-z,norelro -z execstack \
		-o $(BINDIR)/lexicon

genhash:
	mkdir -p $(BINDIR)
	nasm -f elf64 -g -F dwarf $(SRCDIR)/genhash.nasm -o $(OBJDIR)/genhash.o
	ld -lc -I /lib64/ld-linux-x86-64.so.2 -o $(BINDIR)/genhash $(OBJDIR)/genhash.o

clean:
	rm -f $(SRCDIR)/*.o $(BINDIR)/lexicon

