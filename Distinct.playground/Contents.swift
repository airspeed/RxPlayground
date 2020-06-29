import Foundation
import UIKit
import RxSwift
import RxCocoa
import PlaygroundSupport
import RxSwiftExt

let o1 = Observable.from([1, 2, 3, 4, 5, 1, 1, 3])
//o1.subscribe(onNext: { print($0) })
//
//o1.distinctUntilChanged().subscribe(onNext: { print($0) })

o1.distinct().subscribe(onNext: { print($0) })

