//: Playground - noun: a place where people can play

import UIKit
import RxSwift

var str = "Hello, playground"

let one = PublishSubject<Int>()
let two = PublishSubject<String>()
let comb = one.withLatestFrom(two)
