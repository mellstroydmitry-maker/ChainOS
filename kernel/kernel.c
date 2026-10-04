#include <stdint.h>

static volatile uint16_t *const VGA = (uint16_t *)0xB8000;

static void vga_write(const char *text, uint8_t color)
{
    for (uint32_t i = 0; text[i] != '\0'; i++) {
        VGA[i] = ((uint16_t)color << 8) | (uint8_t)text[i];
    }
}

void kernel_main(void)
{
    vga_write("ChainOS kernel - x86_64 initialization", 0x0F);

    for (;;) {
        __asm__ volatile ("hlt");
    }
}
