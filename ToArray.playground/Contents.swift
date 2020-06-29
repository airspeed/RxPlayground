//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import RxSwiftExt
import PlaygroundSupport
var str = "Hello, playground"

enum PlaygroundError: Error { case `default` }

let p = PublishSubject<Int>()
let o = PublishSubject<Observable<Int>>()
let os = [
    Observable.timer(1, scheduler: MainScheduler.instance).map { (_: Int) -> Int in 1 },
    Observable.timer(2, scheduler: MainScheduler.instance).map { (_: Int) -> Int in 2 },
    Observable.just(3),
]
let q = Observable.from(os)

p
.asObservable()
.toArray()
.subscribe(onNext: {
    print($0)
}, onCompleted: {
//    PlaygroundPage.current.finishExecution()
}, onDisposed: { print("disposed") })
p.onNext(1)
p.onNext(2)
p.onNext(3)
//p.onError(PlaygroundError.default)
p.onCompleted()

o
.asObservable()
.toArray()
.subscribe(onNext: { value in
    print(value)
}, onCompleted: {
//    PlaygroundPage.current.finishExecution()
}, onDisposed: { print("disposed") })
o.onNext(Observable.just(1))
o.onNext(Observable.just(2))
o.onNext(Observable.just(3))
o.onCompleted()

q
.flatMap { $0 }
.toArray()
//.debug()
.subscribe(onNext: { value in
    print("flatMap")
    print(value)
}, onCompleted: {
    print("completed")
}, onDisposed: {
    print("disposed")
//    PlaygroundPage.current.finishExecution()
})

Observable.zip(os)
//.debug()
.subscribe(onNext: { value in
    print("zip")
    print(value)
}, onCompleted: {
    print("completed")
}, onDisposed: {
    print("disposed")
    PlaygroundPage.current.finishExecution()
})

PlaygroundPage.current.needsIndefiniteExecution = true

