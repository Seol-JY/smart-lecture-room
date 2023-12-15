![image](https://github.com/Seol-JY/smart-lecture-room/assets/70826982/c66e5ab2-1de0-4148-bff4-58e52844c87f)
---

**기말 프로젝트 - 2분반 3팀**  
<br/>


## 🎉 프로젝트 소개 

- 스마트 강의실 프로젝트는 앱을 통해 강의실의 센서로부터 강의실 환경 정보를 읽고, 이를 통해 강의실의 구성요소들을 제어하고자 하는 프로젝트입니다. 


- 스마트 강의실 프로젝트의 기능은 다음과 같습니다.
  - Bluetooth를 통한 강의실 시스템(라즈베리파이)로의 접속 
  - 강의실의 전등 제어
  - 강의실의 온/습도 측정
  - 카메라와 객체탐지 기술을 활용한 자동 출석 체크 기능
  - 강의실 선풍기 세기 제어

<br/>

## 👬 팀 소개 & 역할 명세

- #### 임베디드시스템 2분반 3팀

<table>
<tr>
<td><b> GitHub </b></td><td><b> 이름 </b></td><td><b> 학번 </b></td><td><b> 역할 </b></td>
</tr>
<tr>
    <td>
        <a href="https://github.com/minturtle">
            <img src="https://avatars.githubusercontent.com/u/57436755?v=4" width="100px" />
        </a>
    </td>
    <td>김민석</td>
    <td>20190158</td>
    <td>
    - Flutter App 개발<br>
    - Flutter ⇄ 라즈베리 파이 통신 프로토콜 및 인프라 개발
    </td>
</tr>
<tr>
    <td>    
        <a href="https://github.com/Junad-Park">
            <img src="https://avatars.githubusercontent.com/u/67590577?v=4" width="100px" />
        </a>
    </td>
    <td>박준하</td>
    <td>20190509</td>
    <td>
    - Presentation<br>
    - Gcloud Vision API를 이용한 출석체크 기능 개발
    </td>
</tr>
<tr>
    <td>
        <a href="https://github.com/Seol-JY">
            <img src="https://avatars.githubusercontent.com/u/70826982?v=4" width="100px" />
        </a>
    </td>
    <td>설진영</td>
    <td>20190602</td>
    <td>- 라즈베리파이 회로 설계 </br>
        - 라즈베리파이 소프트웨어 구조 설계 및 개발 (멀티쓰레딩 및 IPC 구현)</td>
</tr>
<tr>
    <td>
        <a href="https://github.com/forever2969">
            <img src="https://avatars.githubusercontent.com/u/57749824?v=4" width="100px" />
        </a>
    </td>
    <td>이태헌</td>
    <td>20190938</td>
    <td>- 라즈베리파이 블루투스 통신 </br>
        - 출석체크 기능 테스트 및 통신 </td>
</tr>

</table>

<br/>

## ❓ How to Run? 

> 프로그램은 애플리케이션상에서 안전하게 종료하는 것을 권장한다.  
> sudo 권한이 없다면 필요 프로세스가 생성되지 않아 정상적으로 작동하지 않을 수 있다.  
#### 클론 및 컴파일  
```bash
$ sudo apt-get install libjson-c-dev
$ git clone https://github.com/Seol-JY/smart-lecture-room.git
$ cd main
$ make
```
#### 실행  
```bash
$ sudo ./main
  
```

<br/>

## 🤲🏻 Features 

#### 1. Bluetooth를 통한 강의실 시스템(라즈베리파이)로의 접속
- HC-06 모듈과 스마트폰 간의 BlueTooth 통신 기능 지원
- HC-06 모듈과 라즈베리 파이간의 UART 통신 기능 지원 
- 궁극적으로 스마트폰 ⇄ HC-06 ⇄ 라즈베리파이 ⇄ 강의실 제어 프로세스 간의 통신을 구현


#### 2. 강의실 전등 제어

- 스마트폰 앱 ⇄ 강의실 프로세스 사이의 통신 프로토콜을 사용해 라즈베리 파이에 연결된 전등을 자동으로 제어 한다.
- 스마트폰 앱에서 강의실 프로세스와 연결 시도 성공 직후 강의실의 전등(LED) ON하는 요청을 보냄.
- 스마트폰 앱과 강의실 프로세스 연결 종료시, 종료 직전 스마트폰 앱에서 강의실 전등을 OFF하는 요청을 보냄.

#### 3. 강의실의 온/습도 측정
- 스마트폰 앱은 연결된 강의실에 각 5초마다 블루투스 프로토콜을 사용해 해당 강의실의 온/습도 정보 요청
- 라즈베리파이는 온/습도 센서를 활용해 온/습도 측정
- 라즈베리 파이는 측정된 온/습도를 프로토콜에 맞게 앱으로 전송
- 온/습도를 전달받은 앱은 화면에 온/습도 정보를 출력

#### 4. 카메라와 객체탐지 기술을 활용한 자동 출석 체크 기능
- 스마트폰 앱을 통해 사용자가 출석체크를 요청
- 요청을 전달받은 라즈베리 파이는 카메라를 사용해 강의실 전반의 사진을 찍음
- Google 객체 탐지 API를 사용해 사람 수를 측정
- 측정한 사람 수를 스마트폰 앱에 응답
- 사람 수를 전달받은 앱은 화면에 출력

#### 5. 강의실 선풍기 세기 제어

- 스마트폰 앱을 통해 사용자가 선풍기 제어 요청 전송
- 요청을 전달받은 라즈베리 파이는 모터의 세기를 제어, 현재 모터의 세기를 응답으로 전송
- 스마트폰 앱에서 전달받은 현재 모터의 세기를 화면에 출력

<br/>

## 🤔 How to Use? 
<img width="1639" alt="스크린샷 2023-12-15 오후 8 09 30" src="https://github.com/Seol-JY/smart-lecture-room/assets/70826982/c1facfe0-1b5c-4642-85c3-1ef33ebbc1f9">

<br/>
<br />

## 📐 Architecture

### 하드웨어 설계도
> 🚨 설계도 상의 Fan Motor의 `VCC` 와 `GND` 방향이 반대로 되어 있으므로 **반드시** 확인할 것.
> 
| Module | Role |
|----------|-----------|
|LED 모듈|강의실 전등|
|Keyes140C04 모듈[L9110 모터 드라이버+DC 모터]|강의실 선풍기(온도조절)|
|HC-06 블루투스 모듈(UART)|Mobile 통신|
|KeyesDHT11 모듈|강의실 온도 및 습도 측정|
|5MP OV5647 Mini Camera 모듈|객체탐지를 통한 강의실 인원 파악|

<img src="https://github.com/Seol-JY/smart-lecture-room/assets/70826982/ba7b8dbc-1d9c-48e6-9cb4-a3ef24fc2bc4" style="width:95%;" />

<br/>

### 소프트웨어 구조도
> `multi-processing`과 `IPC(POSIX Message Queue)`를 사용하여 각 프로세스간에 통신을 진행.

<img width="1601" alt="스크린샷 2023-12-15 오후 7 33 09" src="https://github.com/Seol-JY/smart-lecture-room/assets/70826982/1f963f9d-0bc8-4fbc-b594-07ee31777dab">

<br/>
<br/>

##  📤 Communication Specifications
- 통신은 모바일 어플리케이션과 라즈베리파이 HC-06 모듈간의 블루투스 기능을 활용하여 해당 프로젝트 내부에서 사용하는 독자적인 프로토콜을 정해 통신하였다.
- 프로토콜은 "(command)(value)"로 이루어져 있으며, value는 command에 따라 값이 존재하지 않을 수도 있다.

### 통신 프로토콜
<table>
<tr>
    <td><b>Command</b></td><td><b>From</b></td><td><b>To</b></td><td><b>의미</b></td><td><b>예시</b></td>
</tr>
<tr>
    <td>s</td><td>Application</td><td>RasPi</td>
    <td>
        Flutter App에서 강의실의 LED를 제어한다.<br>
        - Value 0 : LED ON <br>
        - Value 1 : LED OFF
    </td>
    <td>s0</td>
</tr>
<tr>
     <td>i</td><td>Application</td><td>RasPi</td>
    <td>
    Flutter App에서 강의실의 모터의 세기를 증가시킨다.<br>
    단계는 0~4단계 사이로 제어된다.<br>
    - Value n : 모터를 n단계로 제어
    </td>
    <td>i2</td>
</tr>
<tr>
     <td>i</td><td>RasPi</td><td>Application</td>
    <td>
    Rasberry PI에서 강의실의 모터를 증가한 후, 현재 모터의 세기를 App에게 전달한다. <br>
    Rasberry PI 와 APP간의 세기 불일치 문제를 해결하기 위해 사용<br>
    - Value n : 현재 모터가 n단계임을 의미
    </td>
    <td>i2</td>
</tr>
<tr>
     <td>d</td><td>Application</td><td>RasPi</td>
    <td>
    Flutter App에서 강의실의 모터의 세기를 감소시킨다.<br>
    단계는 0~4단계 사이로 제어된다.<br>
    - Value n : 모터를 n단계로 제어
    </td>
    <td>d2</td>
</tr>
<tr>
     <td>d</td><td>RasPi</td><td>Application</td>
    <td>
    Rasberry PI에서 강의실의 모터를  감소한 후, 현재 모터의 세기를 App에게 전달한다. <br>
    Rasberry PI 와 APP간의 세기 불일치 문제를 해결하기 위해 사용<br>
    - Value n : 현재 모터가 n단계임을 의미
    </td>
    <td>d2</td>
</tr>
<tr>
     <td>a</td><td>Application</td><td>RasPi</td>
    <td>
    Flutter App에서 출석체크를 요청한다.<br>
    </td>
    <td>a</td>
</tr>
<tr>
     <td>a</td><td>RasPi</td><td>Application</td>
    <td>
    Rasberry PI에서 출석한 학생의 수를 측정해서 이를 APP에게 응답한다.<br>
    - Value n : 현재 출석한 학생의 수가 n명임을 의미
    </td>
    <td>a15</td>
</tr>
<tr>
     <td>t</td><td>RasPi</td><td>Application</td>
    <td>
    Flutter APP에서 현재 강의실의 온/습도 정보를 요청한다.
    </td>
    <td>t</td>
</tr>
<tr>
     <td>t</td><td>RasPi</td><td>Application</td>
    <td>
    Rasberry PI에서 현재 온/습도를 측정해서 이를 APP에게 응답한다.<br>
    - Value {n1, n2} : 현재 온도가 n1°C, 습도가 n2%임을 의미
    </td>
    <td>t{25.3,40.5}</td>
</tr>
</table>

<br/>

## 🤔 문제점 및 해결방안

#### 1. 블루투스 통신 시 데이터를 정상적으로 읽어들이지 못하는 현상
> 라즈베리파이에서 데이터 전송 시 애플리케이션에서 정상적으로 인식하지 못하는 현상이 발생. 

- 전송 시에 캐리지 리턴(‘\r’) 기호를 추가해 주는 방식으로 해결.
- 라즈베리파이에서 데이터를 수신하는 경우에 줄 바꿈 문자 (‘\n’) 및 캐리지 리턴 (’\r’) 을 무시하도록 설정
``` c
// main.c
sprintf(buffer, "d%c\r", fanSpeedDecrease);
write(fd_serial, &buffer, strlen(buffer));
...
if (mode == '\r' || mode == '\n') {
  continue;
}
```

<br/>

#### 2. C언어 상에서 JSON 데이터 파싱에 대한 어려움
> Google Vision API의 응답형식이 JSON, C언어에서 json 형식의 응답을 분석할 때 어려움을 겪음. 

- json-c 외부 라이브러리를 사용해 데이터 파싱
``` c
int performVisionAPIRequest(const char *base64ImageData) {
  ...
  json_object_object_add(requestObj, "image", imageObj);
  ...
}
...
int handleApiResponse(const char *response) {
  ...
  if (json_object_object_get_ex(responseItem, "faceAnnotations", &faceAnnotations)) {
    peopleCount = json_object_array_length(faceAnnotations);
    ...
  }
}
```

<br/>

## 📹 데모 영상

[![demo](https://img.youtube.com/vi/0umso5RNOMI/hqdefault.jpg)](https://www.youtube.com/watch?v=0umso5RNOMI) 
