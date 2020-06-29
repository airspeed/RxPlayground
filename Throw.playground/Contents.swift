//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import PlaygroundSupport

var str = "Hello, playground"

enum PlaygroundError: Error {
    case `default`
}

let t = Observable<Int>.create { observer in
    observer.onNext(1)
    observer.onCompleted()
    return Disposables.create()
}

t
    .map { _ in
        throw PlaygroundError.default
    }
    .subscribe(
    onNext: { print($0) },
    onError: { print($0); PlaygroundPage.current.finishExecution() }
)
PlaygroundPage.current.needsIndefiniteExecution = true

