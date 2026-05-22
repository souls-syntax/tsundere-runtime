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
	void (*text_render)(int x, int y, const char* text);
} API;

#endif
