#include <wiringPi.h>
#include <stdio.h>
#include <mqueue.h>

#define PWM0 18
#define PWM1 19

#define FREQ 1000
#define RANGE 100

mqd_t mq_fan;
struct mq_attr attr;
const char* mq_fan_name = "/fan_mq";	
char buf[BUFSIZ];
int n;

int init();
void initFanMQ();
void initPWM();
void setFanSpeed(unsigned char fanSpeed);

int main() {
    if (init()) return 1;
	printf("선풍기 프로세스 시작..\n");
	fflush(stdout);
	int isProgramRunning = 1; // 프로그램 종료 여부를 나타내는 변수
    while (isProgramRunning) {
        n = mq_receive(mq_fan, buf, sizeof(buf), NULL);
		if (buf[0] == 'q') {
			isProgramRunning = 0;
		} else {
    		setFanSpeed(buf[0]);
		}
    }

    setFanSpeed('0');
	mq_close(mq_fan);
    mq_unlink(mq_fan_name);
	return 0;
}

int init() {
    if (wiringPiSetupGpio() < 0) {
        printf("선풍기 프로세스 초기화 실패!\n");
        return 1;
    }
    initPWM();
    initFanMQ();

    return 0;
}

void setFanSpeed(unsigned char fanSpeed) {
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
			printf("선풍기 세기 조절에 오류 발생!\n");
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

void initFanMQ() {
    /* 메시지 큐 속성의 초기화 */
    attr.mq_flags = 0;
    attr.mq_maxmsg = 10;
    attr.mq_msgsize = BUFSIZ;
    attr.mq_curmsgs = 0;
    mq_fan = mq_open(mq_fan_name, O_CREAT | O_RDONLY, 0644, &attr);
}