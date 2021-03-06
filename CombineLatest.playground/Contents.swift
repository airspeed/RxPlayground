//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import PlaygroundSupport
var str = "Hello, playground"

let one = PublishSubject<Int>()
let two = PublishSubject<String>()
let comb = Observable.combineLatest(one, two)

comb.subscribe(onNext: {
    print($0)
}, onCompleted: {
    PlaygroundPage.current.finishExecution()
})

one.onNext(1)
one.onNext(2)
two.onNext("1")
one.onNext(3)
two.onNext("2")
one.onCompleted()
two.onCompleted() // both should complete

PlaygroundPage.current.needsIndefiniteExecution = true
