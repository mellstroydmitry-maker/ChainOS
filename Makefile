CC = gcc
AS = gcc
LD = ld

CFLAGS = -m64 -ffreestanding -fno-pie -fno-stack-protector -mno-red-zone -Wall -Wextra
ASFLAGS = -m64 -c
LDFLAGS = -m elf_x86_64 -T kernel/linker64.ld

KERNEL = build/chainos.kernel

all: $(KERNEL)

build:
	mkdir -p build

build/boot64.o: kernel/arch/x86_64/boot/boot64.S | build
	$(AS) $(ASFLAGS) $< -o $@

build/kernel.o: kernel/kernel.c | build
	$(CC) $(CFLAGS) -c $< -o $@

$(KERNEL): build/boot64.o build/kernel.o
	$(LD) $(LDFLAGS) $^ -o $@

clean:
	rm -rf build iso chainos.iso

.PHONY: all clean
