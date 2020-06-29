//: Playground - noun: a place where people can play

import UIKit
import RxSwift

var str = "Hello, playground"

let s = PublishSubject<Int>()

s.onNext(0)
s.onNext(1)
s.onNext(2)

let puts = { print($0) }
s.subscribe(onNext: puts)

s.onNext(4)

s.subscribe(onNext: puts)

s.onNext(5)
