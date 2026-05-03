# ============================================
# makefile для LowKey Mini OS
# простая сборка мини ос
# ============================================

# компиляторы и инструменты
ASM = nasm
CC = gcc
LD = ld
EMU = qemu-system-i386

# флаги
ASM_FLAGS = -f bin
CC_FLAGS = -m16 -ffreestanding -fno-pic -nostdlib -nostartfiles -fno-stack-protector -c
LD_FLAGS = -T linker.ld

# цели
all: lowkey_os.img

# создание образа диска
lowkey_os.img: boot.bin kernel.bin
	# объединяем загрузчик и ядро
	cat boot.bin kernel.bin > lowkey_os.img
	# дополняем до минимального размера дискеты (1.44mb)
	dd if=/dev/zero bs=1 count=1474560 conv=notrunc >> lowkey_os.img 2>/dev/null || true
	truncate -s 1474560 lowkey_os.img

# компиляция загрузчика
boot.bin: boot.asm
	$(ASM) $(ASM_FLAGS) boot.asm -o boot.bin

# компиляция точки входа ядра (asm)
kernel_entry.o: kernel_entry.asm
	$(ASM) -f elf32 kernel_entry.asm -o kernel_entry.o

# компиляция ядра (c)
kernel.o: kernel.c
	$(CC) $(CC_FLAGS) kernel.c -o kernel.o

# линковка ядра - упрощённая версия
kernel.bin: kernel_entry.o kernel.o
	# создаём плоский бинарник
	$(LD) -m elf_i386 -Ttext 0x7e00 --oformat binary -o kernel.bin kernel_entry.o kernel.o

# запуск в эмуляторе
run: lowkey_os.img
	$(EMU) -fda lowkey_os.img -boot a -nographic

# запуск с графическим режимом
run-gui: lowkey_os.img
	$(EMU) -fda lowkey_os.img -boot a

# очистка
clean:
	rm -f *.bin *.o *.img

# переcборка
rebuild: clean all

.PHONY: all run run-gui clean rebuild
