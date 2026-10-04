.section .multiboot
.align 4

.set MULTIBOOT_MAGIC,    0x1BADB002
.set MULTIBOOT_FLAGS,    0x00000003
.set MULTIBOOT_CHECKSUM, -(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS)

.long MULTIBOOT_MAGIC
.long MULTIBOOT_FLAGS
.long MULTIBOOT_CHECKSUM


.section .bss
.align 4096

stack_bottom:
.skip 16384
stack_top:

.align 4096
pml4:
.skip 4096

pdpt:
.skip 4096

pd:
.skip 4096


.section .text
.code32

.global _start
.extern kernel_main

_start:
    cli

    # Проверяем CPUID
    mov $0x80000000, %eax
    cpuid
    cmp $0x80000001, %eax
    jb no_long_mode

    # Проверяем Long Mode
    mov $0x80000001, %eax
    cpuid
    test $(1 << 29), %edx
    jz no_long_mode

    # PML4 -> PDPT
    mov $pdpt, %eax
    or $0x03, %eax
    mov %eax, pml4

    # PDPT -> PD
    mov $pd, %eax
    or $0x03, %eax
    mov %eax, pdpt

    # Identity-map первые 2 MiB
    # Page size = 2 MiB
    mov $0x00000083, %eax
    mov %eax, pd

    # CR3 = PML4
    mov $pml4, %eax
    mov %eax, %cr3

    # Включаем PAE
    mov %cr4, %eax
    or $(1 << 5), %eax
    mov %eax, %cr4

    # Включаем Long Mode через EFER
    mov $0xC0000080, %ecx
    rdmsr
    or $(1 << 8), %eax
    wrmsr

    # Включаем paging
    mov %cr0, %eax
    or $(1 << 31), %eax
    mov %eax, %cr0

    # Загружаем 64-bit GDT
    lgdt gdt64_descriptor

    # Far jump в 64-bit code segment
    ljmp $0x08, $long_mode


no_long_mode:
    mov $0xB8000, %edi
    mov $0x4F4C4E47, %eax
    mov %eax, (%edi)

.hang:
    cli
    hlt
    jmp .hang


.code64

long_mode:
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss

    mov $stack_top, %rsp

    call kernel_main

.hang64:
    cli
    hlt
    jmp .hang64


.section .rodata

.align 8

gdt64:
    .quad 0x0000000000000000
    .quad 0x00AF9A000000FFFF
    .quad 0x00AF92000000FFFF

gdt64_descriptor:
    .word gdt64_descriptor - gdt64 - 1
    .quad gdt64
