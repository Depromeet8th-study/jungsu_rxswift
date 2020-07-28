# Chapter 2: Observable

## 1. Observable이란?
---
- Rx의 핵심 내용.
- `observable` = `observable sequence` = `sequence` 모두 동일한 의미이다.
- 중요한 것은 이 모든 것들이 **비동기적(Async)** 이라는 것이 핵심이다.
- Observable 들은 일정 기간 동안 계속하여 이벤트를 생성하며, 이를 `emit(방출)` 이라고 표현한다.
- 이러한 개념을 쉽게 이해하는 방법은 `marble diagrams`를 이용하는 것.
  - `marble diagrams` : 시간의 흐름에 따라 값을 표시하는 방식.
  - 타임라인은 왼쪽에서 오른쪽으로 흐른다.

<br>

## 2. Observable의 생명주기
---
![image](https://user-images.githubusercontent.com/33051018/88398452-60592c00-ce00-11ea-99d4-9eaf761b8803.png)

위 그림 Marble Diagram을 살펴보면 세 개의 Marble을 확인할 수 있다.

`Observable` 은 앞서 설명한 `next` 이벤트를 통해 각각의 요소들을 방출한다.

> Observable은 특정 구성요소를 가지는 `event`를 계속하여 `emit` 할 수 있다.
> Observable은 `error` 이벤트를 `emit` 하여 완전 종료시킬 수 있다.
> Observable은 `complete` 이벤트를 방출하여 완전 종료시킬 수 있다.

아래 예제 를 살펴보도록 한다.

```swift

public enum Event<Element> {
    /// Next elem is produced.
    case next(Element)

    // Sequence terminated with an error.
    case error(Swift.Error)

    // Sequence completed Successfully.
    case completed
}
```

- `.next` 이벤트는 특정 Element 인스턴스를 가지고 있는 것을 확인할 수 있다.
- `.error` 이벤트는 Swift.Error 인스턴스를 갖는다.
- `completed` 이벤트는 어떠한 인스턴스도 갖지 않고 단순히 이벤트를 종료시킨다.

<br>

## 3. Observable 만들기
---
```swift
example(of: "just, of, from") {
    let one = 1
    let two = 2
    let three = 3

    let observable: Observable<Int> = Observable<Int>.just(one)
}
```

`just` 메소드를 통해 Observable Sequence를 생성한다.

`just`는 이름 그대로 단 하나의 요소를 포함하는 Observable Sequence를 생성한다.

```swift
let observable2 = Observable.of(one, two, three)
```

- observable2의 타입은 `Observable<Int>`
- `.of` 연산자를 통해 Observable Sequence를 생성한다.
- 만일 특정 observable sequence array를 생성하고 싶을때는 `.of` 를 이용하면 된다.

```swift
let observable3 = Observable.of([one, two, three])
```

- observable3는 `Observable<[Int]>` 타입을 갖는다.

<br>

## 4. Observable 구독하기
---

아래 예제는 클로저를 이용하여 Notification의 observer를 나타낸 것이다.
```swift

let observer = NotificationCenter.default.addObserver {
    forName: .UIKeyboardDidChangeFrame,
    object: nil,
    queue: nil
} { notification in
    // Noti Handling
}
```

- RxSwift의 구독 방식은 위 방식과 유사하다.
- 위 코드에서 구독을 `addObserver()` 를 통해 진행했다면, RxSwift에서는 `subscribe()` 메소드를 이용한다.
- **`Observable`은 단순 `sequence`일 뿐이다, 따라서 `Observable(관찰가능한 이벤트들)`은 `Observer(관찰자)` 들이 `subscribe(구독)` 하기 이전에는 아무런 이벤트도 방출하지 않는다.**

- Observable을 구독하는 것은 매우 간단하다.
- Observable이 방출하는 각각의 이벤트 타입에 대하여 핸들링이 가능하다.
- observable은 `.next`, `.error`, `.completed` 종류의 이벤트를 방출한다.

<br>

### 4.1. subscribe()

```swift
example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3

    let observable = Observable.of(one, two, three)     // Observable Sequence 생성.
    observable.subscribe({ (event) in
        print(event)
    })
    /*
        next(1)
        next(2)
        next(3)
        completed
    */
}
```

- `.subscribe` 는 `@Escaping Closure`로 event라는 Int타입 파라미터를 갖는다.
- 출력값을 보면, Observable은 각각의 원소들에 대하여 `.next` 이벤트를 방출하였다.
- 이후 모든 요소를 방출한 이후 `.completed`를 방출하여 정상적으로 sequence를 종료시켰다.

<br>

### 4.2. subscribe(onNext:)

```swift
observable.subscribe { event in
    if let element = event.element {
        print(element)
    }
    /*
        1
        2
        3
    */

observable.subscribe(onNext: { (element) in
    print(element)
})

    /*
        1
        2
        3
    */
}
```

`subscribe(onNext:)` 는 `.next` 이벤트만 핸들링하고 그 외 이벤트(.completed, .error)는 무시한다.

<br>

### 4.3. empty()

여태까지는 하나 혹은 여러개의 원소를 가지는 Observable Sequence를 만들었다.

Observable.count == 0 인 경우에는 `empty` 연산자를 통해 확인이 가능하며 원소가 하나도 없을 경우에는 `.completed` 이벤트를 방출한다.

```swift
example(of: "empty") {
    let observable = Observable<Void>.empty()           // Observable 생성
    
    observable.subscribe {          // Observable 구독
        onNext: { (element) in
            print(element)          // .onNext Handling
        },
        onCompleted: {
            print("Completed")      // .completed Handling
        }
    }
}
// Completed
```

위와 같은 방식으로 `.empty()` 연산자를 이용해 Observable을 생성하고 이를 observer가 구독하여 `.onCompleted` 이벤트만 방출된다면 Observable이 비어있다는 의미이다.

**`empty` Observable의 용도**
> - 즉시 종료할 수 있는 Observable을 반환하고 싶은 경우.
> - 의도적으로 0개의 원소를 갖는 Observable을 반환하고 싶은 경우.

<br>

### 4.4. never()

`never` 연산자는 `empty`의 반대되는 역할을 제공한다.

```swift
example(of: "never") {
    let observable = Observable<Any>.never()            // never 연산자 사용

    observable.subscribe {
        onNext: { (element) in              // .onNext Handling
            print(element)
        },
        onCompleted: {
            print("Completed")               // .onCompleted Handling
        }
    }
}
```

위 코드는 출력값이 없다.

`.never()` 연산자를 이용해 생성한 Observable은 이벤트 방출과 종료 둘 다 하지 않는다.

<br>

## 5. Disposing 그리고 종료

- Observable은 Observer가 Subscribe 하기 이전에는 아무것도 하지 않는다!
- 즉, subscribe는 Observable이 이벤트를 방출할 수 있도록 해주는 매개체.
- 반대로 생각하면 subscribe가 종료되면 Observable의 이벤트 방출 또한 종료된다!

<br>

### 5.1. dispose()
```swift
example(of: "dispose") {
    let observable = Observable.of("A", "B", "C")       // observable 생성

    let subscription = observable.subscribe({ (element) in      // Observer가 구독 시작.
        print(event)
    })

    subscription.dispose()          // 구독 취소!

}
```

- String 타입의 Observable Sequence 생성.
- Observer가 구독을 시작한다.
- emit 되는 이벤트들을 각가가 출력한다.
- dispose()를 통해 구독을 취소한다. -> Event emit 정지.

<br>

### 5.2. DisposeBag()
- 각각의 subscription을 모두 일일히 관리하는 것은 비효율적이기에, RxSwift는 이를 한번에 관리하기 위하여 DisposeBag을 이용한다.
- DisposeBag에는 (`.disposed(by:)`를 통해 추가된) disposables이 들어있다.

```swift
example(of: "DisposeBag") {
    let disposeBag = DisposeBag()       // DisposeBag 인스턴스 생성
    
    Observable.of("A", "B", "C")
        .subscribe{                     // Observable 구독
            print($0)
        }
        .disposed(by: disposeBag)       // 방출된 값을 disposeBag에 disposed 한다.
}
```

위 코드의 흐름은 아래와같다.

- disposeBag 만들기.
- observable 만들기.
- 방출 이벤트 프린팅.
- 방출 리턴값을 disposeBag에 추가하기.

`observable` 에 대한 `subscripting` 을 하고 이를 즉시 `disposeBag`에 추가하는 패턴은 매우 흔하게 사용된다.

**흔하게 사용되는 이유**
> dispose하는 것을 빼먹는다면, memory leak이 발생할 것.

