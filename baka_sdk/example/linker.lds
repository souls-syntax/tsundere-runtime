/*linker.lds The binary format describer*/

SECTIONS {
	. = 0x0;

	.baka_header : {
		*(.baka_header) /* Header first offset 0 */
	}

	. = 0x40; 

	.text : {
		*(.text)
	}

	.data : {
		*(.data)
		*(.rodata)
	}
}
