![image](https://github.com/Seol-JY/smart-lecture-room/assets/70826982/eb2dee9c-7329-414f-8303-a3055cdba7f4)
---

**Raspberry Pi와 센서 및 엑츄에이터 등을 활용해 ~~~ 프로젝트입니다.**  
**~~~**

<br/>

## 👬 TEAM 3

<table>
  <tr>
		<td>
        <a href="https://github.com/minturtle">
            <img src="https://avatars.githubusercontent.com/u/57436755?v=4" width="100px" />
        </a>
    </td>
    <td>    
        <a href="https://github.com/Junad-Park">
            <img src="https://avatars.githubusercontent.com/u/67590577?v=4" width="100px" />
        </a>
    </td>
    <td>
        <a href="https://github.com/Seol-JY">
            <img src="https://avatars.githubusercontent.com/u/70826982?v=4" width="100px" />
        </a>
    </td>
    <td>
        <a href="https://github.com/forever2969">
            <img src="https://avatars.githubusercontent.com/u/57749824?v=4" width="100px" />
        </a>
    </td>
  </tr>
  <tr>    
    <td><b>김민석</b></td>
    <td><b>박준하</b></td>
    <td><b>설진영</b></td>
    <td><b>이태헌</b></td>
  </tr>
  <tr>
    <td>학번입력</td>
    <td>학번입력</td>
    <td>20190602</td>
    <td>학번입력</td>
  </tr>
</table>

필요시 담당 역할 명세

<br/>

## ❓ How to run?
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

<br/>

## 🤲🏻 Features
#### 여기에 기능 제목 입력
- 기능상세 설명 #1
- 기능상세 설명 #2

<br/>

## 🤔 How to use?
여기에 애플리케이션 사용법 작성

<br/>

## 📐 Architecture
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

## 📤 Communication Specifications
통신은 ~
