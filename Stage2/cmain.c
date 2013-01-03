#include "console.h"

static const char* testMessage = "\r\n  A rollicking band of pirates we,\r\n Who, tired of tossing on the sea,\r\nAre trying their hand at a burglary,\r\n    With weapons grim and gory.\r\n";

void cmain(void);

void cmain(void)
{
	console_init(0);
	const char* c = testMessage;
	while (*c)
	{
		console_putc(*(c++));
	}
	console_sync_cursor();
}
