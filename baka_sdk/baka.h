//! baka.h the C side api
#ifndef BAKA_H
#define BAKA_H

#include <stdint.h>

typedef struct {
	uint32_t magic_number;
	uint32_t version;
	uint32_t memory_mb;
	uint32_t binary_size;
	uint32_t entry_offset;
	char name[32];
	char padding[12];
} BakaHeader ;

typedef struct {
    unsigned char e_ident[16];
    uint16_t e_type;
    uint16_t e_machine;
    uint32_t e_version;
    uint64_t e_entry;
    uint64_t e_phoff;
    uint64_t e_shoff;
    uint32_t e_flags;
    uint16_t e_ehsize;
    uint16_t e_phentsize;
    uint16_t e_phnum;
    uint16_t e_shentsize;
    uint16_t e_shnum;
    uint16_t e_shstrndx;
} BakaElfHeader ;

typedef struct {
	void (*text_render)(int x, int y, const char* text);
} API;

#endif
