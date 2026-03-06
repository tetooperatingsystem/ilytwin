clang --target=i386-elf -ffreestanding -c kernel/kernel.c -o ../build/kernel.o -nostdlib
nasm -f bin bootloader/boot.s -o ../build/boot.bin
nasm -f elf32 kernel/kernel_exec.s -o ../build/kernel_exec.o

ld -m elf_i386 -T kernel/linker.ld ../build/kernel_exec.o ../build/kernel.o -o ../build/kernel.elf
objcopy -O binary ../build/kernel.elf ../build/kernel.bin
