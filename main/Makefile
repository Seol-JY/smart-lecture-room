CC = gcc
CFLAGS = -Wall -Wextra -pedantic -std=c99
LDFLAGS = -lwiringPi -lrt -lpthread

all: main fan_motor dht

main: main.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

fan_motor: fan_motor.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

dht: dht.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

clean:
	rm -f main fan_motor dht
