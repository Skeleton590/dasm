small:
	# Building object.
	nasm -felf64 -o main.o main.asm
	# Striping the binary and merging the .data and .text segments to save space.
	ld -m elf_x86_64 --no-warn-rwx-segments -s -N -o a.out main.o
	# Striping the section headers to save more space.
	strip --strip-section-headers a.out
