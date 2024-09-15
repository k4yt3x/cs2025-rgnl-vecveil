.PHONY: all build debug shellcode clean

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

all: shellcode build

build:
	mkdir -p $(BINDIR)
	gcc $(CFLAGS) $(DJB2_FLAG) -Ofast -s $(SRCDIR)/lexikon.c -o $(BINDIR)/lexikon

debug:
	mkdir -p $(BINDIR)
	gcc $(CFLAGS) $(DJB2_FLAG) -g -DDEBUG $(SRCDIR)/lexikon.c \
		-no-pie -fno-stack-protector -Wl,-z,norelro -z execstack \
		-o $(BINDIR)/lexikon

validator:
	mkdir -p $(BINDIR)
	gcc $(CFLAGS) $(DJB2_FLAG) -nostartfiles -Ofast -mavx2 -s \
		$(SRCDIR)/validator.c -o $(BINDIR)/validator

shellcode:
	mkdir -p $(BINDIR)
	mkdir -p $(OBJDIR)
	nasm -f elf64 src/challenge.nasm -o $(OBJDIR)/challenge.o
	ld -o bin/challenge.bin -N -Ttext 0x0 --oformat binary $(OBJDIR)/challenge.o
	python3 tools/encoder.py bin/challenge.bin

clean:
	rm -f $(SRCDIR)/*.o $(BINDIR)/lexikon

