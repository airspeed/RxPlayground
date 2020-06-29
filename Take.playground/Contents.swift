//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import PlaygroundSupport

var str = "Hello, playground"

let one = PublishSubject<Int>()
one.asObservable()
.take(1)
    .subscribe(onNext: {
        print($0)
    }, onCompleted: {
        print("completed")
        PlaygroundPage.current.finishExecution()
    })

one.onNext(1)
one.onNext(2)
one.onNext(3)
//one.onCompleted() // redundant, as `take` autocompletes the sequence once the max number of elements is reached.

PlaygroundPage.current.needsIndefiniteExecution = true
