import Foundation
import UIKit
import RxSwift
import RxCocoa
import PlaygroundSupport

let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
PlaygroundPage.current.liveView = textField
PlaygroundPage.current.needsIndefiniteExecution = true

let textSubject = PublishSubject<String>()
textField.rx.text.orEmpty
.debug()
    .bind(to: textSubject)

textSubject.asObservable()
.take(1)
    .debug()
.bind(to: textField.rx.text)

// Programmatically assign
textField.text = "1"
Observable.just("0").bind(to: textSubject)
