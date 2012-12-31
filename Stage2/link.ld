OUTPUT_FORMAT(binary)
OUTPUT_ARCH(i386)
SECTIONS
{
	. = 0x500;
	.bootstrap : {
		*(.bootstrap)
	}
	.text : {
		*(.text)
	}
	.data ALIGN(2) : {
	 	*(.rodata*)
	 	*(.data)
	}

	.bss ALIGN(2) : {
		sbss = .;
		*(COMMON)
		*(.bss)
		ebss = .;
	}
}