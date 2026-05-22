//! main.c the entry point for the application built 
#include "../baka.h"


__attribute__((section(".baka_header")))
BakaHeader header = {
	.magic_number = 0x62616B61,
	.version = 1,
	.memory_mb = 4096,
	.binary_size = 0,
	.entry_offset = 0x40,
	.name = "hello",
	.padding = {0}
};

void baka_main(const API* api) {
	api->text_render(0,0, "humpf, reeee.. i don't want to talk to you. baka.");
}
