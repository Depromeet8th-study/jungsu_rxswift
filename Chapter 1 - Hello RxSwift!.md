# Chapter 1: Hello RxSwift!

## Section 1: Getting Started with RxSwift

<br>

### Chapter 1: Hello RxSwift!
---

**RxSwift** 란 무엇인가?
- `RxSwift`란, observable 한 시퀀스, operator를 이용하여 이벤트 기반 코드 및 비동기 작업을 도와주는 라이브러리.

~~음.. 뭔 소리인지 모르겠다;~~

이 책의 목표는 **다양한 RxSwift API에 대한 소개 및 사용을 통해 Rx 개념에 대하여 이해하는 것**이다.

<br>

#### Introducing to asynchronous programming

iOS 앱 내에서는 아래와 같은 일들이 흔하게 발생한다.

- 버튼 터치에 반응하기.
- 텍스트필드가 포커싱을 잃으면서 키보드 올리기.
- 인터넷으로부터 큰 용량의 사진 다운로드하기.
- 디스크에 데이터 저장하기.
- 오디오 재생하기.

위 모든 일들이 동시에 발생한다고 생각해보자.

프로그램 내에서 모든 부분들은 각각 서로의 실행을 방해하지 않는다.

iOS는 다양한 스레드에서 서로 다른 작업을 실행할 수 있는 모든 API를 제공하며, CPU의 여러 코어를 이용하여 작업을 수행할 수 있다.

그러나, 병렬적인 실행을 제어하기 위한 코드는 다소 복잡하다.

<br>

#### Cocoa and UIKit Asynchronous APIs

`Apple`은 iOS SDK를 통해 다양한 API를 제공하며 이를 기반으로 비동기 코드를 작성할 수 있도록 한다.

- `NotificationCenter` : 특정 이벤트가 발생하면 특정 코드를 실행시킨다. 

- `The delegate pattern` : 다른 클래스 혹은 API에 의해 실행될 액션을 정의하기 위해서는 delegate pattern을 이용한다.

- `Grand Central Dispatch` : serial Queue를 이용하여 진행될 코드를 스케줄링 할 수 있다.

- `Closures` : 클래스 간에 전달할 수 있는 분리된 코드 조각을 만들어 각 클래스가 실행 여부, 몇 번 실행할지, 어떤 맥락에서 실행할지 결정할 수 있도록 하기 위해 사용하는 익명 함수.

대체로 앱은 사용자의 입력, 네트워크 활성화 등등 OS 이벤트와 같은 외부 요인에 크게 의존한다.

<br>

RxSwift의 핵심 세 가지 키워드는 `observables`, `operators`, `schedulers` 다.

#### Observables

`Observable<T>` 클래스는 '시간 경과에 따라 다른 클래스가 내보내는 값에 대해 클래스가 **구독**할 수 있게 해준다.'

또한, 하나 혹은 여러 observer들이 어떤 이벤트에 반응하여 앱 UI를 업데이트하거나, 다른 방법으로 새 데이터와 수신 데이터를 처리하고 활용할 수 있도록 한다.

`ObservableType` 프로토콜은 매우 간단하며 `Observable`은 3가지 타입의 이벤트를 배출할 수 있다.

- `next` 이벤트 : 최신 혹은 다음 데이터를 가져오는 이벤트, 옵저버들이 데이터를 수신하는 방식

- `completed` 이벤트 : 이벤트 시퀀스를 성공적으로 마무리 한 경우를 의미한다, `Observable`이 다른 이벤트를 배출하지 않고 성공적으로 업무가 끝난 경우.

- `error` 이벤트 : `Observable`이 에러와 함께 종료되거나 어떤 이벤트도 배출하지 않는 경우.

두 가지의 observable sequences에 대해 알아본다.

#### Finite observable sequences

몇 몇 observable 시퀀스는 0, 1 또는 그 이상의 값을 배출하다가 성공적으로 종료하거나 에러와 함께 종료된다.

iOS 앱 내에서 인터넷을 통해 파일을 다운로드하는 코드를 에시로 살펴보자.

1. 다운로드를 시작하고 다운받는 데이터를 관측한다.
2. 데이터를 받는다.
3. 만일 네트워크가 죽으면 다운로드는 멈출것이고 커넥션은 에러와 함께 종료될 것이다.
4. 모든 데이터를 다운로드 받으면 성공적으로 이벤트를 마무리한다.

이러한 workflow는 일반적인 observable의 라이프사이클을 설명한다.

```swift
API.download(file: "http://www...")
    .subscribe(onNext: { data in
    ... append data to temporary file 
    },
    onError: { errorr in
        ... display error to user
    },
    onCompleted: {
        ... use downloaded file
    })
```

`API.download(file:)` 은 Observable<Data> 인스턴스를 반환한다.

`onNext` 클로저에서는 이벤트를 구독하여 데이터를 추가한다.

error 발생시에는 `onError` 로 제어하며 error를 보여주도록 한다.

결과적으로 completed 이벤트는 `onCompleted`로 제어가 가능하다.