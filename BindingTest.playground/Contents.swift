import RxSwift
import RxCocoa

let subject = PublishSubject<Int>()
let xs = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
var disposeBag = DisposeBag()
let clearDisposeBag: (Int) -> () = { _ in disposeBag = DisposeBag() }
let debug: (Int) -> () = { _ in print("resetting disposeBag") }
let pushNewValueToSubject: (Int) -> () = { _ in subject.onNext(100) }
let performBind: (Int) -> () = { _ in xs.take(10).bind(to: subject).disposed(by: disposeBag) }

let ys = Observable<Int>.timer(5, scheduler: MainScheduler.instance)
    .do(onNext: debug)
    .do(onNext: clearDisposeBag)
    .do(onNext: pushNewValueToSubject)
    .do(onNext: performBind)

subject.asObservable().subscribe(onNext: { print($0) }, onError: { print($0) }, onCompleted: { print("completed") }, onDisposed: { print("disposed") })
performBind(0)
ys.subscribe()
