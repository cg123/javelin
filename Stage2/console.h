#ifndef _STAGE2_CONSOLE_H_
#define _STAGE2_CONSOLE_H_

#include <stdint.h>

void console_init(int clear);
void console_putc(char c);

uint8_t console_get_attribute(void);
void console_set_attribute(uint8_t attr);

int console_get_cursor(void);
void console_set_cursor(int pos);
void console_sync_cursor(void);

void console_scroll(void);

#endif//_STAGE2_CONSOLE_H_
