# 13 - 음악 재생,녹음

# AVAudioPlayer란?
  - 아이폰에서는 대부분의 정보를 화면을 통해 제공하지만 간혹 소리를 이용해 정보를 제공하기도 함
  - iOS에서는 기본적으로 음악 재생 앱과 녹음 앱을 제공
  - 오디오 파일을 재생할 수 있다면 벨소리나 알람과 같이 각종 소리와 관련된 다양한 작업을 할 수 있음
  - ex) 일정관리 앱에서 녹음 기능을 추가해 목소리로 메모를 하는 등 메인 기능이 아닌 서브 기능으로도 사용 가능
  - 오디오를 재생하는 방법 중 가장 쉬운 방법은 ***AVAudioPlayer***를 사용하는 것  
    
  - AVAudioPlayer는 다음과 같이 다양한 오디오 포맷 및 코덱을 지원
  
  |            오디오 포맷            |           코 덱        |    
  | :--------------------------: |  :--------------------------: | 
  | ACC(MPEG-4 Advamced Audio Coding) | ALAC(Aple Lossless Audio Codec|
  |HE-AAC(MPEG-4 High Efficiency ACC | AMR(Adaptive Mulit-rate|
  | Linear PCM(Linear Pluse Code Modulation| iLBC(internet Low Bit Rate Codec|
  |                 |MP3(MPEG-1 audio layer3|
  
  - 가장 기본적인 기능을 수행하는 오디오 재생앱을 만들기 위해 버튼과 레이블, 프로그래스 뷰(Progress View), 슬라이더(Slider)를 사용해서 만들어 보았다.
  <hr/>  
  
  - 오디오를 재생하려면 오디오 파일을 불러오고 추가 설정도 해야함
  - 추가 설정이 필요한 부분은 소리의 크기를 조절하기 위한 볼륨, 볼륨을 표시할 슬라이더, 재생 시간을 표시하기 위한 타이머,  
    재생 정도를 표시할 프로그레스 뷰 등
  - 오디오를 재생하려면 '초기화'라는 단계를 거쳐야함
  - ***초기화*** 란 오디오를 재생하기 위한 준비 과정뿐만 아니라 재생 시간을 맨 처음으로 돌리고 버튼의 활성화 또는 비활성화를 설정하는 과정
  
  <hr/>
  
  ### 스위프트 문법 01 - do-try-catch문이란?
  
  - 오류가 발생할 수 있는 함수를 호출할 때는 do-try-catch문 사용  
  - do-try-catch 구문이 오류를 잡아 처리해준다. 사용형식은 아래와 같다  
  
 ~~~swift
    do {
        try 오류 발생 가능 코드
          오류가 발생하지 않으면 실행할 코드
    } catch 오류 패턴 1 {
          처리 구문
    } catch 오류 패턴 2 where 추가 조건 {
          처리 구문
    } catch {
          처리구문
    }
  ~~~

  - 오류 타입은 한 개 또는 그 이상도 가능
  ~~~
      1. 예를 들어 나누기 함수의 경우 0으로 나누는 오류가 발생할 수 있다.
      2. 적절하게 처리하기 위해 do-try-catch 문을 사용해 예외로 처리 가능
      3. 오류가 발생할 수 있는 함수는 "func 함수명(입력 파라미터) throws -> 리턴 파라미터" 형태를 가지며, 
         이 함수를 호출할 때는 do-try-catch문을 사용해야 한다.
  ~~~
  
  <hr/>
  
  ### 스위프트 문법 02 - / 와 % 의 차이

  ~~~
    / 연산자는 나누었을 때 '몫'이고, %는 나누었을 때 '나머지'이다.
    예를 들어 5/2는 나눈 몫이기 때문에 2이고, 5%2는 나눈 나머지이기 때문에 1이다.
  ~~~
  
  <hr/>
  
  
  
  
