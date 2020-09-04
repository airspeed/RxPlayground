import UIKit
import RxSwift
import RxCocoa
import RxGesture
import RxSwiftExt
import PlaygroundSupport

extension UIColor {
    static var random: UIColor {
        [.systemTeal, .systemYellow, .systemRed, .blue, .systemGreen, .systemGray, .systemPurple, .white, .systemFill, .systemBackground, .systemPink, .systemIndigo, .systemOrange, .systemGray2, .systemGroupedBackground, .systemGray3, .systemGray4].randomElement() ?? .clear
    }
}

final class MPButtonSlider: UIView {

    final class Knob: UIButton {}

    // MARK: Properties

    fileprivate let elementsSubject = PublishSubject<[String]>()
    fileprivate let selectedElementSubject = PublishSubject<String>()
    var observeSelectedElement: Observable<String> {
        self.selectedElementSubject.asObservable()
    }
    private let buttonTapSubject = PublishSubject<Int>()
    private var configurationDisposeBag = DisposeBag()
    private var buttonsDisposeBag = DisposeBag()
    private var knobDisposeBag = DisposeBag()

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }

    deinit {
        print("\(self) deinited")
    }

    // MARK: Tasks

    private func configure() {
        self.configureReuse()
        self.configureUI()
        self.configureActions()
    }

    private func configureUI() {
        self.backgroundColor = .systemBackground
        self.configureLabels()
        self.configureButtons()
        self.configureKnob()
    }

    private func configureReuse() {
        self.elementsSubject.asObservable()
            .do(onNext: { [weak self] _ in
                self?.subviews.forEach { $0.removeFromSuperview() }
                self?.buttonsDisposeBag = DisposeBag()
                self?.knobDisposeBag = DisposeBag()
            })
            .subscribe()
            .disposed(by: self.configurationDisposeBag)
    }

    // MARK: UI

    private func configureLabels() {
        self.elementsSubject.asObservable()
            .map { [weak self] elements -> [UILabel] in
                let bounds = self?.bounds ?? .zero
                let containerWidth = bounds.width
                let containerHeight = bounds.height
                let elementWidth = containerWidth / CGFloat(elements.count)
                return elements.enumerated().map { offset, element -> UILabel in
                    let labelOrigin = CGPoint(x: elementWidth * CGFloat(offset),
                                              y: 0)
                    let labelSize = CGSize(width: elementWidth,
                                           height: containerHeight)
                    let labelFrame = CGRect(origin: labelOrigin, size: labelSize)
                    let label = UILabel(frame: labelFrame)
                    label.textAlignment = .center
//                    label.backgroundColor = .random
                    label.textColor = .systemBlue
                    label.text = element
                    return label
                }
            }
            .do(onNext: { [weak self] labels in
                labels.forEach { self?.addSubview($0) }
            })
            .subscribe()
            .disposed(by: self.configurationDisposeBag)
    }

    private func configureButtons() {
        let buttonsDisposeBag = self.buttonsDisposeBag
        let buttonTapSubject = self.buttonTapSubject
        self.elementsSubject.asObservable()
            .map { [weak self] elements -> [UIButton] in
                let bounds = self?.bounds ?? .zero
                let containerWidth = bounds.width
                let containerHeight = bounds.height
                let elementWidth = containerWidth / CGFloat(elements.count)
                return elements.enumerated().map { offset, element -> UIButton in
                    let buttonOrigin = CGPoint(x: elementWidth * CGFloat(offset),
                                               y: 0)
                    let buttonSize = CGSize(width: elementWidth,
                                            height: containerHeight)
                    let buttonFrame = CGRect(origin: buttonOrigin, size: buttonSize)
                    let button = UIButton(frame: buttonFrame)
                    button.backgroundColor = .clear
                    return button
                }
            }
            .do(onNext: { [weak self] buttons in
                buttons.enumerated().forEach { offset, button in
                    self?.addSubview(button)
                    button.rx.tap.asObservable()
                        .mapTo(offset)
                        .asDriver(onErrorJustReturn: 0)
                        .drive(buttonTapSubject)
                        .disposed(by: buttonsDisposeBag)
                }
            })
            .subscribe()
            .disposed(by: self.configurationDisposeBag)
    }

    private func configureKnob() {
        let knobDisposeBag = self.knobDisposeBag
        let selectedElementSubject = self.selectedElementSubject
        Observable.combineLatest(self.elementsSubject.asObservable(),
                                 self.observeSelectedElement)
            .do(onNext: { [weak self] _ in
                self?.subviews.filter { $0 is Knob }
                    .forEach { $0.removeFromSuperview() }
                self?.knobDisposeBag = DisposeBag()
            })
            .map { elements, selectedElement -> ([String], Int, String)? in
                guard let index = elements.firstIndex(of: selectedElement) else { return nil }
                return (elements, index, selectedElement)
            }
            .unwrap()
            .map { [weak self] elements, selectedIndex, selectedElement -> (Knob, CGFloat, [String]) in
                let bounds = self?.bounds ?? .zero
                let containerWidth = bounds.width
                let containerHeight = bounds.height
                let elementWidth = containerWidth / CGFloat(elements.count)
                let knobWidth = min(elementWidth, containerHeight)
                let knobOrigin = CGPoint(x: elementWidth * CGFloat(selectedIndex) + (elementWidth - knobWidth) / 2,
                                         y: (containerHeight - knobWidth) / 2)
                let knobSize = CGSize(width: knobWidth, height: knobWidth)
                let knobFrame = CGRect(origin: knobOrigin, size: knobSize)
                let knob = Knob(frame: knobFrame)
                knob.backgroundColor = .systemBlue
                knob.setTitleColor(.white, for: .normal)
                knob.setTitle(selectedElement, for: .normal)
                knob.layer.cornerRadius = knobWidth / 2
                return (knob, elementWidth, elements)
            }
            .do(onNext: { [weak self] knob, elementWidth, elements in
                self?.addSubview(knob)
                knob.rx.panGesture()
                .when(.changed)
                .throttle(.milliseconds(100), latest: true, scheduler: MainScheduler.instance)
                .do(afterNext: { [weak self] in
                    $0.setTranslation(.zero, in: self)
                })
                .map { [weak self] in $0.translation(in: self) }
                .filter { [weak self] _ in
                    knob.frame.maxX <= self?.frame.maxX ?? 0 &&
                        knob.frame.minX >= 0
                }
                .subscribe(onNext: { [weak self] translation in
                    let origin = knob.frame.origin.x
                    let knobWidth = knob.bounds.size.width
                    let maxX = (self?.frame.maxX ?? 0) - knobWidth
                    let translation = origin + translation.x
                    let snapToItem: (CGFloat, CGFloat, Int)? = (0..<elements.count).map { index -> (CGFloat, Int) in
                            (CGFloat(index) * elementWidth + (elementWidth - knobWidth) / 2, index)
                        }
                        .map { (origin, index) -> (CGFloat, CGFloat, Int) in
                            (abs(origin - translation), origin, index)
                        }
                        .min { $0.0 < $1.0 }

                    let snappedTranslation: CGFloat = snapToItem?.1 ?? 0
                    let snappedIndex: Int = snapToItem?.2 ?? 0
                    let snappedElement: String = elements[snappedIndex]
                    knob.frame.origin.x = min(max((snappedTranslation), 0), maxX)
                    knob.setTitle(snappedElement, for: .normal)
                })
                .disposed(by: knobDisposeBag)

                knob.rx.panGesture()
                .when(.ended)
                .throttle(.milliseconds(100), latest: true, scheduler: MainScheduler.instance)
                .map({ _ -> String in
                    let translation = knob.frame.origin.x
                    let knobWidth = knob.bounds.size.width
                    let snapToItem: (CGFloat, CGFloat, Int)? = (0..<elements.count).map { index -> (CGFloat, Int) in
                            (CGFloat(index) * elementWidth + (elementWidth - knobWidth) / 2, index)
                        }
                        .map { origin, index -> (CGFloat, CGFloat, Int) in
                            (abs(origin - translation), origin, index)
                        }
                        .min { $0.0 < $1.0 }

                    let snappedIndex: Int = snapToItem?.2 ?? 0
                    let snappedElement: String = elements[snappedIndex]
                    return snappedElement
                })
                .bind(to: selectedElementSubject)
                .disposed(by: knobDisposeBag)
            })
            .subscribe()
            .disposed(by: self.configurationDisposeBag)
    }

    private func configureActions() {
        self.buttonTapSubject.asObservable()
            .withLatestFrom(self.elementsSubject.asObservable()) { $1[$0] }
            .asDriver(onErrorJustReturn: "")
            .drive(self.selectedElementSubject)
            .disposed(by: self.configurationDisposeBag)
    }
}

// MARK: Binder

extension Reactive where Base: MPButtonSlider {
    var elements: Binder<[String]> {
        Binder(self.base) { slider, elements in
            slider.elementsSubject.onNext(elements)
        }
    }

    var selectedElement: Binder<String> {
        Binder(self.base) { slider, selectedElement in
            slider.selectedElementSubject.onNext(selectedElement)
        }
    }
}

var bs: MPButtonSlider? = MPButtonSlider(frame: CGRect(x: 0, y: 0, width: 375, height: 44))
let xs = Observable.just((1..<13))
    .map { xs -> [String] in xs.map { "\($0)" }}

bs.map {
    xs
        .bind(to: $0.rx.elements)
    xs.map { $0.randomElement() }.unwrap()
        .bind(to: $0.rx.selectedElement)
}

bs?.observeSelectedElement.subscribe(onNext: { print($0) })
PlaygroundPage.current.liveView = bs
//bs = nil // test disposition
