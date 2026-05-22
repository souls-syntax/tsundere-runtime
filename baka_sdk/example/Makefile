CC      := gcc
LD      := ld
OBJCOPY := objcopy

CFLAGS  := -ffreestanding -fPIC -Wall -Wextra -O2
LDFLAGS := -T linker.lds

SRC     := main.c
OBJ     := main.o
ELF     := app.elf
TARGET  := app.baka

all: $(TARGET)

$(OBJ): $(SRC)
	$(CC) $(CFLAGS) -c $< -o $@

$(ELF): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

$(TARGET): $(ELF)
	$(OBJCOPY) -O binary $< $@

clean:
	rm -f $(OBJ) $(ELF) $(TARGET)

.PHONY: all clean
