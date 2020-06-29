//: Playground - noun: a place where people can play

import Foundation
import UIKit
import RxSwift
import RxCocoa
import PlaygroundSupport

var str = "Hello, playground"

enum PlaygroundError: String, Error {
    case generic = "Playground error"

    var localizedDescription: String {
        return self.rawValue
    }
}

let e = Observable<Int>.empty()
let a = Observable<Int>.just(1)
let h = Observable<Int>.error(PlaygroundError.generic)
let t = Observable<Int>.timer(.seconds(1), period: .seconds(1), scheduler: MainScheduler.instance)
a.flatMapLatest { _ in e }
.subscribe(onNext: { print($0) }, onCompleted: { print("empty completed") })

let n = Observable<Int>.never()
a.flatMapLatest { _ in n }
    .subscribe(onNext: { print($0) }, onCompleted: { print("never completed") })

let button = UIButton(frame: CGRect(x: 0.0, y: 200.0, width: 300.0, height: 50.0))
button.layer.borderColor = UIColor.blue.cgColor
button.layer.borderWidth = 3.0
button.setTitle("Start observable sequence", for: .normal)
button.rx
    .tap
    .throttle(1.0, latest: false, scheduler: MainScheduler.instance)
    .flatMapLatest { _ in e } // completion does not propagate
//    .flatMapLatest { _ in a } // completion does not propagate
//    .flatMap { _ in h } // error propagates
    .subscribe(onNext: {
        print($0)
    }, onError: { error in
        print(error.localizedDescription)
        PlaygroundPage.current.finishExecution()
    }, onCompleted: {
        print("button completed")
        PlaygroundPage.current.finishExecution()
    })

// empty + merge
Observable.merge(e, a)
    .subscribe(onNext: { print($0) },
               onCompleted: { print("completed") })
Observable.merge(e, t)
.subscribe(onNext: { print($0) },
           onCompleted: { print("completed") })

PlaygroundPage.current.liveView = button
PlaygroundPage.current.needsIndefiniteExecution = true
