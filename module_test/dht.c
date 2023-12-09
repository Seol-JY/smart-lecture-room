#include <wiringPi.h>
#include <stdio.h>

#define MAXTIMINGS 85
#define DHTPIN     23

int dhtVal[5] = { 0, 0, 0, 0, 0 };

// DHT11 센서에서 데이터를 읽고 해석하여 온도와 습도를 출력하는 함수
void readData()
{
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
        // if (dhtVal[2] == 0) {
        //   return;
        // } 
        printf("습도 = %d.%d %% 온도 = %d.%d *C\n", 
                      dhtVal[0], dhtVal[1], dhtVal[2], dhtVal[3]);
                      fflush(stdout);
    }
    return;
}

// 메인 함수
int main(void)
{
    printf("라즈베리 파이 wiringPi DHT11 온도 측정 프로그램\n");

    /* wiringPi GPIO 라이브러리 초기화 */
    if (wiringPiSetupGpio() == -1)
        return -1;

    while (1)
    {
        /* 온도 및 습도 데이터를 읽고 출력 */
        readData();
        delay(1000); /* 4초 대기 후 새로고침 */
    }

    return (0);
}
