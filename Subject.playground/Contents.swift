import Foundation
import UIKit
import RxSwift
import RxCocoa
import PlaygroundSupport
import RxSwiftExt

let p = PublishSubject<Int>()
var d = DisposeBag()

// 1 - Subscribe

p.asObservable()
    .subscribe(onNext: {
        print($0)
    }, onError: {
        print($0)
    }, onCompleted: {
        print("completed")
    }, onDisposed: {
        print("disposed")
    })
    .disposed(by: d)

p.onNext(1) // ✅
p.onNext(2) // ✅
p.onNext(3) // ✅
d = DisposeBag()
p.onNext(4) // ❌

print("---")

// 2 - Bind

let p1 = PublishSubject<Int>()
let p2 = PublishSubject<Int>()
var d1 = DisposeBag()
p1.asObservable()
    .bind(to: p2)
    .disposed(by: d1)

p2.asObservable()
.subscribe(onNext: {
    print($0)
}, onError: {
    print($0)
}, onCompleted: {
    print("completed")
}, onDisposed: {
    print("disposed")
})

p1.onNext(1) // ✅
p1.onNext(2) // ✅
p1.onNext(3) // ✅
d1 = DisposeBag()
p1.onNext(4) // ❌

print("---")

// 3 - do

let p3 = PublishSubject<Int>()
let p4 = PublishSubject<Int>()
var d2 = DisposeBag()
p3.asObservable()
    .do(onNext: { p4.onNext($0) })
    .subscribe()
    .disposed(by: d2)

p4.asObservable()
.subscribe(onNext: {
    print($0)
}, onError: {
    print($0)
}, onCompleted: {
    print("completed")
}, onDisposed: {
    print("disposed")
})

p3.onNext(1) // ✅
p3.onNext(2) // ✅
p3.onNext(3) // ✅
d2 = DisposeBag()
p3.onNext(4) // ❌

print("---")
