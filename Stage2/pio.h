#ifndef _JAVELIN_STAGE2_PIO_H_
#define _JAVELIN_STAGE2_PIO_H_

#include <stdint.h>

static inline void outb(uint16_t port, uint8_t val)
{
	__asm__ __volatile__ ("outb %0, %1" : : "a"(val), "Nd"(port));
}
static inline void outw(uint16_t port, uint16_t val)
{
	__asm__ __volatile__ ("outw %0, %1" : : "a"(val), "Nd"(port));
}
static inline void outl(uint16_t port, uint32_t val)
{
	__asm__ __volatile__ ("outl %0, %1" : : "a"(val), "Nd"(port));
}

static inline uint8_t inb(uint16_t port)
{
	uint8_t ret;
	__asm__ __volatile__ ("inb %1, %0" : "=a"(ret) : "Nd"(port));
	return ret;
}
static inline uint16_t inw(uint16_t port)
{
	uint16_t ret;
	__asm__ __volatile__ ("inb %1, %0" : "=a"(ret) : "Nd"(port));
	return ret;
}
static inline uint32_t inl(uint16_t port)
{
	uint32_t ret;
	__asm__ __volatile__ ("inb %1, %0" : "=a"(ret) : "Nd"(port));
	return ret;
}

#endif//_JAVELIN_STAGE2_PIO_H_
