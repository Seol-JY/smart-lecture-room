#define _POSIX_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <wiringPi.h>
#include <wiringSerial.h>
#include <spawn.h>
#include <mqueue.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdarg.h>
#include <unistd.h>
#include <signal.h>  

extern char **environ;

#define BAUD_RATE 115200
#define LED_GPIO 17
#define LED_ON '0'
#define LED_OFF '1'
#define BUFF_SIZE 100

static const char * UART2_DEV = "/dev/ttyAMA1"; //UART2 연결을 위한 장치 파일

unsigned char serialReadByte(const int   fd); //1Byte 데이터를 수신하는 함수
void serialWriteByte(const int fd, const unsigned char c); //1Byte 데이터를 송신하는 함수
void lightControl(char state); // 강의실 전등을 켜거나 끄는 함수
void printAndFlush(const char *format, ...);
void runFanMotorProcess();
void runDhtProcess();
void initDhtMQ();

pid_t motorPid; // 외부  fan_motor 프로세스 pid
pid_t dhtPid;
mqd_t mq_fan;
const char* mq_fan_name = "/fan_mq";	

mqd_t mq_dht;
struct mq_attr attr;
const char* mq_dht_name = "/dht_mq";	
int n;

int main() {
    int fd_serial; //UART2 파일 서술자
    unsigned char mode;  // 선택 모드
    char buffer[BUFF_SIZE]; // 임시 버퍼

    int isProgramRunning = 1; // 프로그램 종료 여부를 나타내는 변수
    
    if (wiringPiSetupGpio() < 0) return 1;
    if (wiringPiSetup() < 0) return 1;

    pinMode(LED_GPIO, OUTPUT);

    printAndFlush("연결 시도...\n");
    if ((fd_serial = serialOpen(UART2_DEV, BAUD_RATE)) < 0) { //UART2 포트 오픈
        printf("Bluetooth 장치에 연결할 수 없습니다.\n");
        return 1;
    }

    // 팬모터 mq 열기
    mq_fan = mq_open(mq_fan_name, O_WRONLY);
    runFanMotorProcess();
    runDhtProcess();

    initDhtMQ();

    while (isProgramRunning) {
        if (serialDataAvail(fd_serial)) { //읽을 데이터가 존재한다면,

            mode = serialReadByte(fd_serial);
            printAndFlush("\n모드: %c", mode);
            switch (mode) {        //버퍼에서 1바이트 값을 읽음
                case 's':
                    printAndFlush(" - 전등 상태 변경\n");
                    unsigned char ledState = serialReadByte(fd_serial);
                    printAndFlush("전등 상태: %c\n", ledState);
                    lightControl(ledState);
                    break;
                case 'i':
                    printAndFlush(" - 선풍기 세기 조절 (증가)\n");
                    unsigned char fanSpeedIncrease = serialReadByte(fd_serial);
                    printAndFlush("선풍기 세기: %c\n", fanSpeedIncrease);
                    // queue를 통헤 세기를 보냄
                    mq_send(mq_fan, (const char*)&fanSpeedIncrease, sizeof(unsigned char), 0);
                    sprintf(buffer, "i%c", fanSpeedIncrease);
                    write(fd_serial, &buffer, strlen(buffer)); //write 함수를 통해 1바이트 씀
                    break;
                case 'd':
                    printAndFlush(" - 선풍기 세기 조절 (감소)\n");
                    unsigned char fanSpeedDecrease = serialReadByte(fd_serial);
                    printAndFlush("선풍기 세기: %c\n", fanSpeedDecrease);
                    mq_send(mq_fan, (const char*)&fanSpeedDecrease, sizeof(unsigned char), 0);
                    sprintf(buffer, "d%c", fanSpeedDecrease);
                    write(fd_serial, &buffer, strlen(buffer)); //write 함수를 통해 1바이트 씀
                    break;
                case 'a':
                    printAndFlush(" - 인원수 체크\n");
                    sprintf(buffer, "a%d", fanSpeedDecrease);
                    write(fd_serial, &buffer, strlen(buffer)); //write 함수를 통해 1바이트 씀
                    break;
                case 't':
                    printAndFlush(" - 온습도 측정\n");
                    while (buffer[0] != '1') {
                        // 유효한 온도값이 들어올 때까지 대기
                        n = mq_receive(mq_dht, buffer, attr.mq_msgsize, NULL);
                        delay(10);
                    }
                    sprintf(buffer, "t{%c%c.%c, %c%c.%c}", buffer[1], buffer[2], buffer[3], buffer[4], buffer[5], buffer[6]);
                    printf("%s\n", buffer);
                    write(fd_serial, &buffer, strlen(buffer)); //write 함수를 통해 1바이트 씀
                    break;
                case 'q':
                    printAndFlush(" - 종료\n");
                    isProgramRunning = 0;
                    break;
                default:
                    printAndFlush(" - 명령어 형식에 문제가 있습니다!\n");
                    break;
            }
        }
        delay(10);
    }

    // 종료 시 후속 작업
    lightControl(LED_OFF);
    const char msg = 'q';
    mq_send(mq_fan, &msg, sizeof(char), 0);

    int status;

    if (kill(dhtPid, SIGKILL) != 0) {
        perror("dht 종료 실패!");
    }

    waitpid(motorPid, &status, 0);
    waitpid(dhtPid, &status, 0);

    mq_close(mq_dht);
    mq_close(mq_fan);
}

unsigned char serialReadByte(const int fd) {
    //1Byte 데이터를 수신하는 함수
    unsigned char x;
    if (read(fd, & x, 1) != 1) //read 함수를 통해 1바이트 읽어옴
        return -1;
    return x; //읽어온 데이터 반환
}

void serialWriteByte(const int fd, const unsigned char c) {
    //1Byte 데이터를 송신하는 함수
    write(fd, & c, 1); //write 함수를 통해 1바이트 씀
}

void lightControl(char state) {
    if (state == LED_ON) {
        digitalWrite(LED_GPIO, HIGH);
        return; 
    }
    if (state == LED_OFF) {
        digitalWrite(LED_GPIO, LOW);
        return; 
    }
    printf("선풍기 세기 조절에 오류 발생!\n");
}

void runFanMotorProcess() {
    const char *other_program_path = "./fan_motor"; 

    char *argv[] = {"./fan_motor", NULL};

    if (posix_spawn(&motorPid, other_program_path, NULL, NULL, argv, environ) == 0) {
        printf("Main process: motor created with PID %d\n", motorPid);
    } else {
        perror("Parent process: Error creating other program");
    }
}

void runDhtProcess() {
    const char *other_program_path = "./dht"; 

    char *argv[] = {"./dht", NULL};

    if (posix_spawn(&dhtPid, other_program_path, NULL, NULL, argv, environ) == 0) {
        printf("Main process: dht created with PID %d\n", dhtPid);
    } else {
        perror("Parent process: Error creating other program");
    }
}

void printAndFlush(const char *format, ...) {
    va_list args;
    va_start(args, format);
    vprintf(format, args); // 기존의 printf와 같이 가변 인자를 처리
    va_end(args);
    fflush(stdout); // 출력 버퍼를 비워서 즉시 출력
}

void initDhtMQ() {
    /* 메시지 큐 속성의 초기화 */
    attr.mq_flags = 0;
    attr.mq_maxmsg = 10;
    attr.mq_msgsize = BUFSIZ;
    attr.mq_curmsgs = 0;
    mq_dht = mq_open(mq_dht_name, O_CREAT | O_RDONLY, 0644, &attr);
}