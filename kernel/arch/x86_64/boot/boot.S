.section .multiboot
.align 4

.set MULTIBOOT_MAGIC,    0x1BADB002
.set MULTIBOOT_FLAGS,    0x00000003
.set MULTIBOOT_CHECKSUM, -(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS)

.long MULTIBOOT_MAGIC
.long MULTIBOOT_FLAGS
.long MULTIBOOT_CHECKSUM


.section .bss
.align 16

stack_bottom:
.skip 16384
stack_top:


.section .text
.global _start
.extern kernel_main

_start:
    mov $stack_top, %esp

    push %ebx
    push %eax

    call kernel_main

.hang:
    cli
    hlt
    jmp .hang
