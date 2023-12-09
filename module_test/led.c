#include <stdio.h>
#include <wiringPi.h>
#include <stdlib.h>


int ledControlwithSwitch(int gpioOut) {
    wiringPiSetupGpio(); /* wiringPi */
    pinMode(gpioOut, OUTPUT);

    digitalWrite(gpioOut, HIGH);

    return 0;
}

int main(int argc, char **argv) {
    return ledControlwithSwitch(17);
}
