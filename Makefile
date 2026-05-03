# ============================================
# makefile для LowKey Mini OS
# полностью на ассемблере - максимум кастома
# ============================================

# инструменты
ASM = nasm
EMU = qemu-system-i386

# флаги
ASM_FLAGS = -f bin

# цели
all: lowkey_os.img

# создание образа диска
lowkey_os.img: boot.bin kernel.bin
	cat boot.bin kernel.bin > lowkey_os.img
	dd if=/dev/zero bs=1 count=1474560 conv=notrunc >> lowkey_os.img 2>/dev/null || true
	truncate -s 1474560 lowkey_os.img

# загрузчик (512 байт)
boot.bin: boot.asm
	$(ASM) $(ASM_FLAGS) boot.asm -o boot.bin

# ядро - полностью на ассемблере
kernel.bin: kernel.asm
	$(ASM) $(ASM_FLAGS) kernel.asm -o kernel.bin

# запуск в консольном режиме
run: lowkey_os.img
	$(EMU) -fda lowkey_os.img -boot a -nographic

# запуск с окном
run-gui: lowkey_os.img
	$(EMU) -fda lowkey_os.img -boot a

# очистка
clean:
	rm -f *.bin *.img

# полная пересборка
rebuild: clean all

.PHONY: all run run-gui clean rebuild
