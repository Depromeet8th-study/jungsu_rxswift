# Observable Sequence & Subject

본 문서는 Observable Sequence와 Subject 대한 이해를 돕고자 공부하며 정리한 내용을 기재합니다.

<br>

## 1. Observable Sequences
---

`RxSwift` 에 대해 이해하기 위한 첫걸음은 `Observable Sequence` 혹은 `Observable Sequence`에 의해 방출된 이벤트에서의 `subscribe`이다.

RxSwift에서는 Array, String 혹은 Dict 모두 `Observable Sequences`로 변환될 수 있다.

Swift Standard Library의 `Sequence Protocol` 을 준수하는 모든 객체는 `observable sequence` 가 될 수 있다.

간단한 `Observable Sequence` 를 생성해보자.

```swift
let helloSequence = Observable.just("Hello Rx")

let fibonacciSequence = Observable.from([0, 1, 1, 2, 3, 5, 8])

let dictSequence = Observable.from([1: "Hello", 2: "World!"])
```

위와 같이 `Observable Sequence`를 생성하였다.

이를 구독할때는 `subscribe(on: (Event<T>) -> ())` 함수를 호출함으로써 구독을 진행한다.

**전달되는 block은 sequence에 의해 방출되는 모든 이벤트를 받기 위한 핸들러 역할을 한다.**

```swift
// Observable Sequence 생성
let helloSequence = Observable.of("Hello Rx")   

// Observable 구독
let subscription = helloSequence.subscribe { event in 
    print(event)
}

// next("Hello Rx")
// completed
```

`Observable Sequence`는 자신의 생명주기동안 0개 혹은 그 이상의 이벤트를 **방출**할 수 있다.

`RxSwift`에서의 이벤트는 `enum` 타입으로 제공되며 3가지의 상태가 존재한다.

- `.next(value: T)` : Observable Sequence에 값이 추가되면 위에서 본 것과 같이 구독자에게 이벤트를 방출한다.

- `.error(error: Error)` : Observable Sequence에서 에러가 발생한 경우를 의미한다, 에러 발생시에는 sequence가 `error` 를 방출하며 sequence를 종료시킨다.

- `.completed` : sequence가 정상적으로 종료되면 구독자에게 `completed` 이벤트를 방출한다.


```swift
// Observable Sequence 생성.
let helloSequence = Observable.from(["H", "e", "l", "l", "o"])

// sequence 구독.
let subscription = helloSequence.subscribe { event in
    switch event {
        case .next(let value):      // next event
            print(value)
        case .error(let error):     // error event
            print(error)
        case .completed:            // completed event
            print("completed")
    }
}

// H e l l o
// completed
```

만일 구독을 취소하고 싶은 경우에는 `dispose`를 호출하도록 한다.

또한 `DisposeBag` 인스턴스를 초기화 할 때 여러개의 구독을 자동으로 취소하는 것 또한 가능하다.

```swift
// DisposeBag 인스턴스 생성
let bag = DisposeBag()

// String value를 방출하는 sequence 생성
let observable = Observable.just("Hello Rx!")

// next 이벤트를 위한 구독 생성
let subscription = observable.subscribe (onNext: {
    print($0)
})

// 구독을 DisposeBag에 추가하기.
subscription.addDisposeableTo(bag)
```

<br>

## 2. Subjects
---

`Subject`는 특별한 형태의 Observable Sequence이다.

`subscribe` 도 가능하며 추가적으로 원소를 더하는 것 또한 가능하다.

`RxSwift`에서는 4가지 종류의 subject를 제공한다.

- `PublishSubject` : PublishSubject를 구독하면 **구독 이후에 발생하는 모든 이벤트를 제공받는다.**

- `BehaviourSubject` : BehaviorSubject를 구독하면 구독자에게 **가장 최근의 element와 구독 이후 방출되는 모든 element를 제공받는다.**

- `ReplaySubject` : **최근의 element 그 이상의 것들을 새로운 구독자에게 제공하고 싶을때**는 ReplaySubject를 이용한다. ReplaySubject를 사용하면 새로운 구독자에게 최근 element 몇개를 방출할지 지정할 수 있다.

- `Variable` : 일반 변수처럼 사용되기도 하는 `Variable`은 BehaviourSubject의 wrapper로 사용된다.

`PublishSubject`에 대한 예시를 살펴보도록 한다.

```swift
let bag = DisposeBag()
var publishSubject = PublishSubject<String>()       // PublishSubject 생성
```

해당 subject에  `onNext()` 함수를 이용하여 새로운 값을 추가해보도록 한다.

```swift
publishSubject.onNext("Hello")
publishSubject.onNext("RxSwift Study")
```

만일 구독자가 `Hello`, `RxSwift Study` 문자열이 `onNext()` 함수를 통해 sequence에 추가된 이후에 구독을 하게되면 이벤트를 통해서 두 값을 받지 못한다. ( -> PublishSubject는 구독 이후의 이벤트만 제공한다.)

반면, 위 subject가 `BehaviourSubject` 라면 `RxSwift Study` 는 받게된다. ( -> BehaviourSubject는 가장 최근의 element와 구독 이후의 이벤트를 제공하기 때문.)

마지막으로 Subject에 새로운 값을 추가하고 새로운 구독을 생성해보도록 한다.

```swift

// 구독자 1
let subscription1 = publishSubject.subscription(onNext: {
    print($0)
}).addDisposeableTo(bag)

// Subject에 element 추가
publishSubject.onNext("Hello")
publishSubject.onNext("Again")

// 구독자 2 , 구독자 2는 Hello 와 Again 이벤트를 받지 못한다.
let subscription2 = publishSubject.subscribe(onNext: {
    print(#line, $0)
})

publishSubject.onNext("Both Subscriptions receive this message")
```

PublishSubject에 대한 구독자 1을 생성하고 PublishSubject에 `onNext()`를 통해 element를 추가한다.

구독자 1은 앞서 추가한 element에 대한 이벤트는 받지 못한다.



