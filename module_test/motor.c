#include <wiringPi.h>
#include <stdio.h>
#include <mqueue.h>

#define PWM0 18
#define PWM1 19

#define FREQ 1000
#define RANGE 100

int init();
void initPWM();
void setFanSpeed(unsigned char fanSpeed);

int main() {
    if (init()) return 1;

	setFanSpeed('30');
}

int init() {
    if (wiringPiSetupGpio() < 0) {
        printf("선풍기 초기화 실패!\n");
        return 1;
    }
    initPWM();

    return 0;
}

void setFanSpeed(unsigned char fanSpeed) {
    printf("선풍기 세기: %c\n", fanSpeed);
	switch(fanSpeed) {
		case '0':
		// 종료 상태
			pwmWrite(PWM0, 0);
			break;
		case '1':
			pwmWrite(PWM0, 30);
			break;
		case '2':
			pwmWrite(PWM0, 50);
			break;
		case '3':
			pwmWrite(PWM0, 70);
			break;
		case '4':
		// 최대 강도
			pwmWrite(PWM0, 100);
			break;
		default:
			printf("선풍기 세기 조절에 오류 발생");
			return;	
	}
	pwmWrite(PWM1, 0);
}

void initPWM() {
    pinMode(PWM0, PWM_OUTPUT);
    pinMode(PWM1, PWM_OUTPUT);

    pwmSetMode(PWM_MODE_MS);
    pwmSetRange(RANGE);
    pwmSetClock(19200000 / (FREQ * RANGE));
}