# Chapter 1: Hello RxSwift!

## Section 1: Getting Started with RxSwift

<br>

### Chapter 1: Hello RxSwift!
---

**RxSwift** 란 무엇인가?
- `RxSwift`란, observable 한 시퀀스, operator를 이용하여 이벤트 기반 코드 및 비동기 작업을 도와주는 라이브러리.

~~음.. 뭔 소리인지 모르겠다;~~

> 키워드 : observable, asynchronous, functional, via schedulers

**RxSwift는 '본질적'으로 코드가 '새로운 데이터에 반응'하고 '순차적으로 분리된' 방식으로 처리함으로써 '비동기식' 프로그램 개발을 간소화한다.**

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

일반적으로 대부분의 클래스들은 비동기 방식으로 작업을 수행하고 모든 UI 구성요소들은 본질적으로 비동기적이다.

따라서, 내가 어떠한 코드를 작성했을 때 정확히 매버너 어떠한 순서로 작동하는지 가정하는 것은 불가능하다.

결국 앱의 코드는 사용자 입력, 네트워크 활동 또는 기타 OS와 같은 다양한 외부 요인에 따라 완전히 다른 순서로 실행될 수 있다.

**결국 Apple의 SDK 내 API를 통한 비동기 코드는 나눠쓰기 어렵고 추적이 거의 불가능하다.**


<br>

#### 비동기 프로그래밍 용어

**State, and specifically, shared mutable state**

- 처음 시동한 Laptop은 불량이 아닌 이상 잘 작동한다.
- 시간이 지날수록 반응이 느려직나 반응이 멈추는 상황이 발생한다. -> 왜?
- hardware 와 software는 그대로지만 변한 것은 state

사용하면 사용할수록 데이터의 교환등이 이루어지고 이로인해 잔류하는 것들이 남게되서 상태가 변화한다는 뜻.

> 앱의 State(상태)를 관리하는 것(특히 비동기 구성요소 공유시)은 RxSwift를 통해 배울 수 있는 주요 포인트 중 하나

**명령형 프로그래밍**

예를 들어, `viewDidAppear(_:)` 메소드를 살펴보자.

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    setupUI()
    connectUIControls()
    createDataSource()
    listenForChanges()
}
```

이렇게만 보면 각각의 method들이 정확하게 무슨 동작을 하는지는 알 수 없다.

뿐만 아니라, 각각의 method들이 기재된 순서대로 실행되었는지 보증할 수 없다.

<br>

### RxSwift basic
---
RxSwift의 핵심 세 가지 키워드는 `observables`, `operators`, `schedulers` 다.

#### 1. Observables

- `Observable<T>` 클래스는 '시간 경과에 따라 다른 클래스가 내보내는 값에 대해 클래스가 **Subscribe(구독)**할 수 있게 해준다.'

- `T` 타입 데이터 snapshot을 '전달' 할 수 있는 일련의 이벤트를 비동기적으로 생성하는 기능

또한, 하나 혹은 여러 observer들이 어떤 이벤트에 반응하여 앱 UI를 업데이트하거나, 다른 방법으로 새 데이터와 수신 데이터를 처리하고 활용할 수 있도록 한다.

`ObservableType` 프로토콜은 매우 간단하며 `Observable`은 3가지 타입의 이벤트를 방출하며 `Observers`는 이들 유형만 수신할 수 있다.

- `next` : 최신 혹은 다음 데이터를 가져오는 이벤트.

- `completed` : 이벤트 시퀀스를 성공적으로 마무리 한 경우를 의미한다, `Observable`이 다른 이벤트를 배출하지 않고 성공적으로 업무가 끝난 경우.

- `error` 이벤트 : `Observable`이 에러와 함께 종료되거나 추가적으로 이벤트를 생성하지 않을 것임을 의미.

![image](https://user-images.githubusercontent.com/33051018/87429218-655af600-c61e-11ea-8fad-24985cfb1e53.png)
![image](https://user-images.githubusercontent.com/33051018/87429224-69871380-c61e-11ea-86bf-0f5cd5d7ef78.png)

- 세 가지 유형의 `Observable` 이벤트는, `observable` 또는 `observer`의 본질에 대한 어떤 가정도 하지 않는다.

- 리얼월드에서 아이디어를 얻으려면 Observable Sequence(유한/무한)을 이해해야 한다.

#### Finite observable sequences

어떤 observable 시퀀스는 0, 1 또는 그 이상의 값을 배출하다가 성공적으로 종료하거나 에러와 함께 종료된다.

iOS 앱 내에서 인터넷을 통해 파일을 다운로드하는 코드를 생각해보자.

1. 다운로드를 시작하고 다운받는 데이터를 관측한다.
2. 데이터를 받는다.
3. 만일 네트워크가 죽으면 다운로드는 멈출것이고 커넥션은 에러와 함께 종료될 것이다.
4. 모든 데이터를 다운로드 받으면 성공적으로 이벤트를 마무리한다.

이러한 workflow는 앞서 서술한 Observable의 생명주기와 정확히 일치한다.

RxSwift 코드로 표현하는 다음과 같다.

```swift
API.download(file: "http://www...")
    .subscribe(onNext: { data in
    ... append data to temporary file 
    },
    onError: { error in
        ... display error to user
    },
    onCompleted: {
        ... use downloaded file
    })
```

- `API.download(file:)` 은 네트워크를 통해 들어오는 `Data` 값을 방출하는 Observable<Data> 인스턴스를 반환한다.

- `onNext` 클로저를 통해 이벤트를 구독하여 데이터를 추가한다.

- error 발생시에는 `onError` 로 제어하며 error를 보여주도록 한다.

- 최종적으로 completed 이벤트는 `onCompleted`로 제어가 가능하다.

#### Infinite observable sequences

일반적으로 event sequence 가 끝나면 종료되는 파일 다운로드 같은 할동과는 달리, 무한한 sequence가 있다.

보통 UI 이벤트는 무한하게 관찰가능한 sequence다.

```swift
UIDevice.rx.orientation
    .subscribe(onNext: { current in
        swift current {
                case .landscape:
                    ... re-arrange UI for landscape
                case .portrait:
                    ... re-arrange UI for portrait
        }
    })
```

`UIDevice.rx.orientation` 은 `Observable<Orientation>` 을 통해 만든 가상 코드다.

이를 통해 Orientation(방향)을 받을 수 있고, 이에 따라 UI를 업데이트 할 수 있다.

해당 이벤트에서는 절대 발생할 수 없는 `onError` 이벤트와 `onCompleted` 이벤트 파라미터는 건너 뛸 수 있다.

<br>

#### 2. Operators

- `observableType` 과 `Observable` 클래스의 구현은 비동기 작업을 추상화하는 많은 메소드가 포함되어 있다. -> 이러한 메소드는 독립적으로 구성 가능하므로 보편적으로 **Operator(연산자)**라고 부른다.

- Operator(연산자)들은 주로 비동기 입력을 받아 출력만 생성하므로 퍼즐 조각처럼 쉽게 결합할 수 있다.

- 예를 들어, `(5 + 6) * 10 - 2` 수식의 경우
    - `*`, `()`, `+`, `-` 같은 연산자를 기반으로 표현식을 처리하게 된다.
    - 비슷한 방식으로, 표현식의 최종값이 도출될 때 까지, `Observable`이 방출한 값에 RxSwift 연산자를 적용하여 부수작용을 만들 수 있다.

- 다음은 앞서 방향전환에 대한 예제의 Rx 연산자를 적용시킨 코드다.

```swift
UIDevice.rx.orientation
    .filter { value in
        return value != .landscape      
        }
    .map { _ in 
            return "Portrait is the best!"
    }
    .subscribe(onNext: { string in 
            showAlert(text: string)
    })
```

- `filter` 는, `.landscape`가 아닌 값만을 골라낸다. 만일 디바이스가 landscape 모드라면 나머지 코드는 진행되지 않는다.

- `subscribe`를 통해 결과로 `next` 이벤트를 핸들링하게 된다. `string` 값을 전달 하여 `showAlert`을 통해 경고창을 띄운다.

<br> 

#### 3. Schedulers

- Rx의 스케줄러는 `dispatchQueue` 개념과 동일, 다만 훨씬 강력하고 쓰기 편하다.

- `RxSwift` 에는 이미 여러 스케줄러가 정의되어 있으며, 99% 상황에서 사용 가능하므로 정~~~~~~말 특이한 케이스 제외하고는 개발자가 직접 자신만의 스케줄러를 생성할 일은 없을 것이다.

- 해당 책의 초기 반 정도에서 다룰 대부분의 예제는 아주 간단하고 일반적인 상황으로 **보통 데이터를 관찰하고, UI를 업데이트 하는 것이 대부분이다. -> 따라서 기초를 완전히 닦기 전 까지 스케줄러 공부는 절대적이지 않다.

- 다만, 기존까지 GCD를 이용했다면 RxSwift에서는 스케줄러를 통해 아래와 같이 작동한다.

![image](https://user-images.githubusercontent.com/33051018/87432348-d2708a80-c622-11ea-9e20-4a6ce549a077.png)

- 각 색깔로 표시된 일들은 스케줄 (1, 2, 3 ...)이 된다.
    - `network subscription` 은 1로 표시된 `Custom NSOperation Scheduler`에서 구동된다.
    - 여기서 출력된 데이터가 `Background Concurrent Scheduler`로 가게된다.
    - 최종적으로, 네트워크 코드의 마지막 (3)은 `Main Thread Serial Scheduler`로 가서 UI를 업데이트하게 된다.


<br>

#### App Architecture

- RxSwift는 주로 이벤트 혹은 비동기 데이터 시퀀스 등을 처리하기 때문에 기존 앱 아키텍처에 영향을 주지 않는다.

- 따라서 Apple 문서에서 언급된 `MVC Arch` 에 Rx를 도입할 수 있다. 물론 MVP, MVVM 모두 가능하다.

- Reactive 앱을 만들기 위해 처음부터 프로젝트를 시작할 필요도 없다. 기존 프로젝트를 부분적으로 리팩토링하거나 단순히 앱에 새로운 기능을 추가할 때에도 사용이 가능하다.

<br>

#### RxCocoa

- RxCocoa는 RxSwift의 동반 라이브러리로, UIKit과 Cocoa FrameWork 기반 개발을 지원하는 모든 클래스를 보유하고 있다.
    - RxSwift는 일반적인 Rx API라서, Cocoa 혹은 특정 UIKit에 대한 정보는 없다.

- RxCocoa를 이용하여 `UISwitch` 상태를 확인하는 코드는 아래와 같다.

```swift
toggleSwitch.rx.isOn
    .subscribe(onNext: { enabled in
        print( enabled ? "It's ON" : "It's OFF")
    })
```

- RxCocoa는 `rx.isOn` 과 같은 프로퍼티를 `UISwitch` 클래스에 제공하며, 이를 통해 이벤트 시퀀스를 확인할 수 있다.

- RxCocoa는 `UITextField`, `URLSession`, `UIViewController` 등에 `rx`를 추가하여 사용한다.



<br>

## Summary
---

- RxSwift 핵심 키워드 : Observer(관찰자), operators(연산자), schedulers(스케쥴러)

- RxSwift는 '새로운 데이터에 반응'하고 '순차적으로 분리된' 방식으로 처리함으로써 '비동기식' 프로그램 개발을 간소화한다.

- `Observable<T>` 클래스는 시간 경과에 따라 다른 클래스가 내보내는 값에 대해 클래스가 Subscribe(구독) 할 수 있게 해준다.

- `observableType` 과 `Observable` 클래스의 구현은 비동기 작업을 추상화하는 많은 메소드가 포함되어 있다. -> 이러한 메소드는 독립적으로 구성 가능하므로 보편적으로 **Operator(연산자)**라고 부른다.

- Rx의 스케줄러는 `dispatchQueue` 개념과 동일, 다만 훨씬 강력하고 쓰기 편하다.