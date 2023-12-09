#include <wiringPi.h>
#include <stdio.h>
#include <spawn.h>
#include <mqueue.h>
#include <string.h>

#define MAXTIMINGS 85
#define DHTPIN     23
#define BUFF_SIZE 8

void readData();

mqd_t mq_dht;
const char* mq_dht_name = "/dht_mq";	

int dhtVal[5] = { 0, 0, 0, 0, 0 };
char buffer[BUFF_SIZE]; // 임시 버퍼
int canSend = 0; // 값 전달 가능 여부

int main(void) {
	printf("dht 프로세스 시작..\n");

    /* wiringPi GPIO 라이브러리 초기화 */
    if (wiringPiSetupGpio() == -1)
        return -1;

    // dht mq 열기
    mq_dht = mq_open(mq_dht_name, O_WRONLY);

    while (1) {
        readData();
        if (canSend == 1) {
            buffer[BUFF_SIZE - 1] = '\0';
            mq_send(mq_dht, buffer, BUFF_SIZE, 0);
        }
        delay(1000); /* 1초 대기 후 새로고침 및 재전송*/
    }

    return (0);
}

// DHT11 센서에서 데이터를 읽고 해석하여 온도와 습도를 출력하는 함수
void readData() {
    int laststate = HIGH;  // 마지막 상태를 저장하는 변수
    int counter = 0;       // 신호 길이를 세는 변수
    int j = 0, i;

    // 데이터 배열 초기화
    dhtVal[0] = dhtVal[1] = dhtVal[2] = dhtVal[3] = dhtVal[4] = 0;

    /* 핀을 18 밀리초 동안 낮춤 */
    pinMode(DHTPIN, OUTPUT);
    digitalWrite(DHTPIN, LOW);
    delay(18);

    /* 그 후 40 마이크로초 동안 높임 */
    digitalWrite(DHTPIN, HIGH);
    delayMicroseconds(40);

    /* 핀을 입력으로 설정하여 데이터를 읽을 준비를 함 */
    pinMode(DHTPIN, INPUT);

    /* 변화를 감지하고 데이터를 읽음 */
    for (i = 0; i < MAXTIMINGS; i++)
    {
        counter = 0;
        while (digitalRead(DHTPIN) == laststate)
        {
            counter++;
            delayMicroseconds(1);
            if (counter == 255)
            {
                break;
            }
        }

        laststate = digitalRead(DHTPIN);

        if (counter == 255)
            break;

        /* 처음 3번의 전환은 무시함 */
        if ((i >= 4) && (i % 2 == 0))
        {
            /* 각 비트를 저장 바이트로 밀어 넣음 */
            dhtVal[j / 8] <<= 1;
            if (counter > 16)
                dhtVal[j / 8] |= 1;
            j++;
        }
    }

    /*
     * 40 비트(8비트 x 5)를 읽었는지 확인하고 마지막 바이트의 체크섬을 확인함
     * 데이터가 올바르면 출력함
     */
    if ((j >= 40) && 
        (dhtVal[4] == ((dhtVal[0] + dhtVal[1] + dhtVal[2] + dhtVal[3]) & 0xFF)))
    {
        if (dhtVal[2] == 0) {
          return;
        } 
        canSend = 1;
        sprintf(buffer, "1%02d%d%02d%d", dhtVal[0], dhtVal[1], dhtVal[2], dhtVal[3]);
    }
    return;
}
