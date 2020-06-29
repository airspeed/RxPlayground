//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import RxCocoa
import PlaygroundSupport

var str = "Hello, playground"

let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0))
button.layer.borderColor = UIColor.blue.cgColor
button.layer.borderWidth = 3.0
button.rx
    .tap
    .throttle(1.0, latest: false, scheduler: MainScheduler.instance)
    .subscribe(onNext: {
        print($0)
    }, onCompleted: {
        PlaygroundPage.current.finishExecution()
    })


PlaygroundPage.current.liveView = button
PlaygroundPage.current.needsIndefiniteExecution = true
