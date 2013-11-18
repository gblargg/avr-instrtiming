MCU   = atmega8
F_CPU = 8000000

all:
	avr-gcc -mmcu=$(MCU) -DF_CPU=$(F_CPU) $(DEFINES) main.c main.S -o main.elf
	avr-objcopy -R .eeprom -R .fuse -R .lock -R .signature -O ihex main.elf main.hex
	avr-objdump -S main.elf > main.lss

clean:
	-rm main.elf
	-rm main.hex
	-rm main.lss
