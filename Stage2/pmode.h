#ifndef _STAGE2_PMODE_H_
#define _STAGE2_PMODE_H_

#include <stdint.h>

uint32_t p2r_call(void* func, uint16_t ax, uint16_t bx, uint16_t cx, uint16_t dx);

#endif//_STAGE2_PMODE_H_
