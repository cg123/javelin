// Copyright (c) 2012, Charles O. Goddard
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met: 
// 
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer. 
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#ifndef _STAGE2_CONSOLE_H_
#define _STAGE2_CONSOLE_H_

#include <stdint.h>

// console_init
// 	Prepare the console for output.
// INPUTS:
// 	int clear - If non-zero, clear the screen.
void console_init(int clear);

// console_putc
// 	Print a single character to the console.
// INPUTS:
// 	char c - The character to output.
void console_putc(char c);

// console_get_attribute
// 	Return the current attribute byte.
// RETURN:
// 	The current attribute byte.
uint8_t console_get_attribute(void);
// console_set_attribute
// 	Set the current attribute byte.
// INPUTS:
// 	uint8_t attr - A new value for the attribute byte.
void console_set_attribute(uint8_t attr);

// console_get_cursor
// 	Return the current position of the cursor.
// RETURN:
// 	The position of the cursor, as number of characters past the
// 	top-left corner of the screen.
int console_get_cursor(void);
// console_set_cursor
//  Set the current position of the cursor.
// INPUTS:
// 	int pos - The new position of the cursor.
void console_set_cursor(int pos);

// console_sync_cursor
//  Update the position of the cursor on the VGA hardware.
void console_sync_cursor(void);

// console_scroll
//  Scroll the console down one line.
void console_scroll(void);

// CON_WIDTH - width of the console, in characters
#define CON_WIDTH 80
// CON_HEIGHT - height of the console, in characters
#define CON_HEIGHT 25

#endif//_STAGE2_CONSOLE_H_
