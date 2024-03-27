small:
	nasm -felf64 -o main.o main.asm
	ld -m elf_x86_64 --no-warn-rwx-segments -s -N -o a.out main.o
	strip --strip-section-headers a.out
