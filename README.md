 
# 스마트 강의실 
## Smart Lecture Room
#### 임베디드 시스템 기말 프로젝트 - 임베디드 시스템 2분반 3팀

---

## 프로젝트 소개 

--- 

- 스마트 강의실 프로젝트는 앱을 통해 강의실의 센서로 부터 강의실 환경 정보를 읽고, 이를 통해 강의실의 구성요소들을 제어하고자 하는 프로젝트입니다. 


- 스마트 강의실 프로젝트의 기능은 다음과 같습니다.
    



    1. Bluetooth를 통한 강의실 시스템(라즈베리파이)로의 접속
    2. 강의실의 전등 제어
    3. 강의실의 온/습도 측정
    4. 카메라와 객체탐지 기술을 활용한 자동 출석 체크 기능
    5. 강의실 선풍기 세기 제어
--- 


## 👬 팀 소개 & 역할 명세

 --- 

- 임베디드 시스템 2분반 3팀

<table>
<tr>
<td>GitHub</td><td>이름</td><td>학번</td><td>역할</td>
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
    <td></td>
    <td></td>
</tr>
<tr>
    <td>
        <a href="https://github.com/Seol-JY">
            <img src="https://avatars.githubusercontent.com/u/70826982?v=4" width="100px" />
        </a>
    </td>
    <td>설진영</td>
    <td>20190602</td>
    <td></td>
</tr>
<tr>
    <td>
        <a href="https://github.com/forever2969">
            <img src="https://avatars.githubusercontent.com/u/57749824?v=4" width="100px" />
        </a>
    </td>
    <td>이태헌</td>
    <td>20190938</td>
    <td></td>
</tr>

</table>



--- 


## ❓ How to run? 

---
> 프로그램은 애플리케이션상에서 안전하게 종료하는 것을 권장한다.  
> sudo 권한이 없다면 필요 프로세스가 생성되지 않아 정상적으로 작동하지 않을 수 있다.  
#### 클론 및 컴파일  
```bash
$ git clone https://github.com/Seol-JY/smart-lecture-room.git
$ cd main
$ make
```
#### 실행  
```bash
$ sudo ./main
  
```

--- 


## 🤲🏻 Features 

--- 

#### 1. Bluetooth를 통한 강의실 시스템(라즈베리파이)로의 접속
- 기능상세 설명 #1
- 기능상세 설명 #2


#### 2. 강의실 전등 제어
- 기능상세 설명 #1
- 기능상세 설명 #2

#### 3. 강의실의 온/습도 측정
- 기능상세 설명 #1
- 기능상세 설명 #2

#### 4. 카메라와 객체탐지 기술을 활용한 자동 출석 체크 기능
- 기능상세 설명 #1
- 기능상세 설명 #2

#### 5. 강의실 선풍기 세기 제어
- 기능상세 설명 #1
- 기능상세 설명 #2

--- 

## 🤔 How to use? 

--- 

#### 1. Bluetooth를 통한 강의실 시스템(라즈베리파이)로의 접속
- 기능상세 설명 #1
- 기능상세 설명 #2


#### 2. 강의실 전등 제어
- 기능상세 설명 #1
- 기능상세 설명 #2

#### 3. 강의실의 온/습도 측정
- 기능상세 설명 #1
- 기능상세 설명 #2

#### 4. 카메라와 객체탐지 기술을 활용한 자동 출석 체크 기능
- 기능상세 설명 #1
- 기능상세 설명 #2

#### 5. 강의실 선풍기 세기 제어
- 기능상세 설명 #1
- 기능상세 설명 #2

--- 

## 📐 Architecture

--- 

### 하드웨어 설계도
> Fan Motor의 `VCC` 와 `GND` 방향이 반대로 되어 있으므로 **반드시** 확인할 것.
> 
| Module | Role |
|----------|-----------|
|LED 모듈|강의실 전등|
|Keyes140C04 모듈[L9110 모터 드라이버+DC 모터]|강의실 선풍기(온도조절)|
|HC-06 블루투스 모듈(UART)|Mobile 통신|
|KeyesDHT11 모듈|강의실 온도 및 습도 측정|
|5MP OV5647 Mini Camera 모듈|객체탐지를 통한 강의실 인원 파악|

<img src="https://github.com/Seol-JY/smart-lecture-room/assets/70826982/ba7b8dbc-1d9c-48e6-9cb4-a3ef24fc2bc4" style="width:95%;" />


### 소프트웨어 구조도
> `multi-processing`과 `IPC(POSIX Message Queue)`를 사용하여 각 프로세스간에 통신을 진행.

<br/>

###  📤 Communication Specifications
- 통신은 모바일 어플리케이션과 라즈베리파이 HC-06 모듈간의 블루투스 기능을 활용하여 해당 프로젝트 내부에서 사용하는 독자적인 프로토콜을 정해 통신하였다.
- 프로토콜은 "(command)(value)"로 이루어져 있으며, value는 command에 따라 값이 존재하지 않을 수도 있다.

#### 통신 프로토콜
<table>
<tr>
    <td>command</td><td>from</td><td>to</td><td>의미</td><td>예시</td>
</tr>
<tr>
    <td>s</td><td>Application</td><td>Rasberry PI</td>
    <td>
        Flutter App에서 강의실의 LED를 제어한다.<br>
        - Value 0 : LED ON <br>
        - Value 1 : LED OFF
    </td>
    <td>s0</td>
</tr>
</table>