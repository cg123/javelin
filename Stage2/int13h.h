#ifndef _JAVELIN_STAGE2_INT13H_H_
#define _JAVELIN_STAGE2_INT13H_H_

#include <stdint.h>

extern char rm_i13h_call;
extern char rm_i13h_has_ext;

typedef struct {
    uint8_t size;
    uint8_t reserved;
    uint16_t num_sectors;
    uint32_t buffer;
    uint64_t start_sector;
} __attribute__((__packed__)) i13h_packet_t;

#define I13_ERR_SUCCESS             0x00
#define I13_ERR_INVALID_FUNCTION    0x01
#define I13_ERR_ADDR_MARK           0x02
#define I13_ERR_WRITE_PROTECT       0x03
#define I13_ERR_SECTOR_NOT_FOUND    0x04
#define I13_ERR_RESET_FAILED        0x05
#define I13_ERR_DISK_CHANGED        0x06
#define I13_ERR_DPA_FAILED          0x07
#define I13_ERR_DMA_OVERRUN         0x08
#define I13_ERR_DATA_BOUNDARY       0x09
#define I13_ERR_BAD_SECTOR          0x0A
#define I13_ERR_BAD_TRACK           0x0B
#define I13_ERR_INVALID_MEDIA       0x0C
#define I13_ERR_SEEK_FAILED         0x40
#define I13_ERR_TIMEOUT             0x80
#define I13_ERR_NOT_READY           0xAA
#define I13_ERR_UNDEFINED           0xBB
#define I13_ERR_STATUS_REGISTER     0xE0
#define I13_ERR_SENSE_FAILED        0xFF


#endif//_JAVELIN_STAGE2_INT13H_H_
