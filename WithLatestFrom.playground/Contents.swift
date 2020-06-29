//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import PlaygroundSupport
var str = "Hello, playground"

let one = PublishSubject<Int>()
let two = PublishSubject<String>()
let comb = one.withLatestFrom(two) { ($0, $1) }

comb.subscribe(onNext: {
    print($0)
}, onCompleted: {
    PlaygroundPage.current.finishExecution()
})

one.onNext(1)
one.onNext(2)
two.onNext("1")
one.onNext(3)
one.onCompleted()

PlaygroundPage.current.needsIndefiniteExecution = true
