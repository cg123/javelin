#include "console.h"
#include "pio.h"

#define VMEM_BASE ((uint8_t*)0xB8000)
#define CON_WIDTH 80
#define CON_HEIGHT 25

static int cursor_pos;
static uint8_t attribute;


void console_init(int clear)
{
	cursor_pos = 0;
	attribute = 0x0f;
	if (clear)
	{
		uint32_t i;
		for (i = 0; i < CON_WIDTH * CON_HEIGHT; i++)
		{
			VMEM_BASE[i*2 + 0] = ' ';
			VMEM_BASE[i*2 + 1] = attribute;
		}
		console_sync_cursor();
	}
	else
	{
		outb(0x3D4, 0x0E);
		cursor_pos = inb(0x3D5) << 8;
		outb(0x3D4, 0x0F);
		cursor_pos |= inb(0x3D5);
	}
}

void console_putc(char c)
{
	if (cursor_pos >= CON_WIDTH*CON_HEIGHT)
	{
		console_scroll();
	}
	if (c < ' ')
	{
		switch(c)
		{
		case '\n':
			cursor_pos += CON_WIDTH;
			break;
		case '\r':
			cursor_pos -= cursor_pos % CON_WIDTH;
			break;
		default:
			console_putc('?');
			break;
		}
		return;
	}

	VMEM_BASE[cursor_pos*2 + 0] = (uint8_t)c;
	VMEM_BASE[cursor_pos*2 + 1] = attribute;
	cursor_pos++;
}

uint8_t console_get_attribute(void)
{
	return attribute;
}
void console_set_attribute(uint8_t attr)
{
	attribute = attr;
}

int console_get_cursor(void)
{
	return cursor_pos;
}
void console_set_cursor(int pos)
{
	cursor_pos = pos;
}
void console_sync_cursor(void)
{
	outb(0x3D4, 0x0F);
	outb(0x3D5, (uint8_t)(cursor_pos & 0xFF));
	outb(0x3D4, 0x0E);
	outb(0x3D5, (uint8_t)((cursor_pos >> 8) & 0xFF));
}


void console_scroll(void)
{
	uint32_t i;
	for (i = 0; i < CON_WIDTH * (CON_HEIGHT-1); i++)
	{
		VMEM_BASE[i*2 + 0] = VMEM_BASE[(i+CON_WIDTH)*2 + 0];
		VMEM_BASE[i*2 + 1] = VMEM_BASE[(i+CON_WIDTH)*2 + 1];
	}
	cursor_pos -= CON_WIDTH;
	console_sync_cursor();
}
