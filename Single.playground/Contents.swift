import UIKit
import RxSwift
import RxCocoa

var str = "Hello, playground"

let xs = Observable.from([0, 1, 2, 3, 4, 5])
xs.subscribe(onNext: {
    print($0)
})
/*
0
1
2
3
4
5
 */

print("===")

xs.asSingle()
    .subscribe {
        print($0)
} // error(Sequence contains more than one element.)

print("===")

xs.filter { $0 < 0 }.asSingle()
    .subscribe {
        print($0)
} // error(Sequence doesn't contain any elements.)

print("===")

xs.filter { $0 < 1 }.asSingle()
    .subscribe {
        print($0)
} // success(0)

/*:
 Single **must** complete in order to emit a `(success|error)` result.
*/
