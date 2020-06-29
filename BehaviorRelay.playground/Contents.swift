import UIKit
import RxSwift
import RxCocoa

var str = "Hello, playground"

let br = BehaviorRelay<Int>(value: 0)
br.accept(2)

br.asObservable()
    .subscribe(onNext: {
        print($0)
    })

br.accept(1)
