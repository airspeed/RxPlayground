import UIKit
import RxSwift
import RxCocoa

final class View {
    private let presenter: Presenter
    var tag: Int = 0

    init(presenter: Presenter) {
        self.presenter = presenter
    }

    var binder: Binder<Int> {
        return Binder(self) { view, int in
            view.tag = int
        }
    }

    deinit {
        print("\(self) deinited.")
    }
}

final class Presenter {
    private let disposeBag = DisposeBag()

    func register(view: View) {
        Observable.just(1)
            .debug()
            .bind(to: view.binder)
            .disposed(by: self.disposeBag)
    }

    deinit {
        print("\(self) deinited.")
    }
}

var v: View? = .none
var p: Presenter? = Presenter()
v = View(presenter: p!)

// OK - deiniting

p?.register(view: v!)

// OK - deiniting

// deinit
p = .none
v = .none

