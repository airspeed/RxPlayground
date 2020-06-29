//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import PlaygroundSupport
var str = "Hello, playground"

let p = PublishSubject<Int>()
p.onNext(1)
let o = Observable.just(p.asObservable())
p.onNext(2)

o.subscribe(onNext: {
    print($0)
}, onCompleted: {
    PlaygroundPage.current.finishExecution()
})
p.onNext(3)

PlaygroundPage.current.needsIndefiniteExecution = true

// .just() always terminates the sequence.
