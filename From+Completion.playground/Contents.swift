import UIKit
import RxSwift

let xs = [1, 2, 3]

print("========")
print("1.")
print("========")
Observable.from(xs)
    .subscribe(onNext: { print($0) })

print("========")
print("2.")
print("========")
Observable.from(xs)
    .flatMap {
        Observable.just($0)
    }
    .subscribe(onNext: { print($0) })

print("========")
print("3.")
print("========")
Observable.from(xs)
    .flatMapLatest {
        Observable.just($0)
    }
    .subscribe(onNext: { print($0) })

print("========")
print("4.")
print("========")
Observable.from(xs)
    .flatMap { x -> Observable<Int> in
        let delay = 3 + Double(x)
        return Observable.just(x)
            .delay(delay, scheduler: MainScheduler.asyncInstance)
    }
    .toArray()
    .asObservable()
    .subscribe(onNext: { print($0) })
