CC = gcc
CFLAGS = -Wall -Wextra -pedantic -std=c99 -D_POSIX_C_SOURCE=200809L -I/path/to/json-c/include
LDFLAGS = -lwiringPi -lrt -lpthread -ljson-c -lcurl -lssl -lcrypto
LIBS = -lcurl -lssl -lcrypto -ljson-c

all: main fan_motor dht

main: main.c vision_module.o
	$(CC) $(CFLAGS) -o $@ main.c vision_module.o $(LDFLAGS) $(LIBS)

fan_motor: fan_motor.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

dht: dht.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

main.o: main.c
	$(CC) $(CFLAGS) -c $< -o $@

vision_module.o: src/vision_module.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f main fan_motor dht main.o vision_module.o