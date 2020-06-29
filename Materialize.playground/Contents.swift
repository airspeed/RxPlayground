//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import PlaygroundSupport

var str = "Hello, playground"

enum PlaygroundError: Error {
    case `default`
}
let one = PublishSubject<Int>()
let two = PublishSubject<Int>()
one.asObservable()
    .flatMap { _ in
        two.asObservable()
        .materialize()
    }
    .filter { $0.error == nil }
    .dematerialize()
    .subscribe(onNext: {
        print($0)
    }, onError: { error in
        print(error)
        PlaygroundPage.current.finishExecution()
    }, onCompleted: {
        print("completed")
        PlaygroundPage.current.finishExecution()
    })

one.onNext(1)
one.onNext(2)
one.onNext(3)
two.onNext(10)
one.onNext(4) // does not output
two.onError(PlaygroundError.default) // errors `two`
two.onNext(20) // does not output
one.onCompleted()
two.onCompleted()

PlaygroundPage.current.needsIndefiniteExecution = true

