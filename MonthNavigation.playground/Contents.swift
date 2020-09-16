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

final class TransparentGradientView: UIView {
    enum Direction {
        case horizontal
        case vertical
        case diagonal
        case horizontalReversed
        case verticalReversed
        case diagonalReversed

        var startPoint: CGPoint {
            switch self {
            case .horizontalReversed: return CGPoint(x: 1.0, y: 0.0)
            case .verticalReversed: return CGPoint(x: 0.0, y: 1.0)
            case .diagonalReversed: return CGPoint(x: 1.0, y: 1.0)
            default: return .zero
            }
        }

        var endPoint: CGPoint {
            switch self {
            case .horizontal: return CGPoint(x: 1.0, y: 0.0)
            case .vertical: return CGPoint(x: 0.0, y: 1.0)
            case .diagonal: return CGPoint(x: 1.0, y: 1.0)
            default: return .zero
            }
        }
    }

    init(frame: CGRect, direction: Direction = .horizontal) {
        super.init(frame: frame)
        self.configure(direction: direction)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure(direction: .horizontal)
    }
    
    private func configure(direction: Direction) {
        self.backgroundColor = .systemBackground
        let gradientMaskLayer = CAGradientLayer()
        gradientMaskLayer.frame = self.bounds

        gradientMaskLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientMaskLayer.locations = [0.1, 0.9]
        gradientMaskLayer.startPoint = direction.startPoint
        gradientMaskLayer.endPoint = direction.endPoint

        self.layer.mask = gradientMaskLayer
    }
}

final class MonthNavigationView: UIView, UICollectionViewDelegate {
    
    // MARK: Inline types
    
    final class MonthCell: UICollectionViewCell {
        static var reuseIdentifier: String { "MonthCell" }
        lazy private(set) var monthNameLabel: UILabel = {
            let label = UILabel(frame: self.bounds)
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14)
            label.layer.borderColor = UIColor.systemBlue.cgColor
            label.layer.cornerRadius = 20
            self.addSubview(label)
            return label
        }()
    }
    
    // MARK: Data types
    
    enum Section: Int {
        case months
    }
    
    struct Month: Hashable {
        let index: Int
        let symbol: String
        var isSelected: Bool
    }
    
    // MARK: Properties
    
    lazy var months: [Month] = {
        var calendar = Calendar.current
        calendar.locale = Locale.autoupdatingCurrent
        return calendar.shortStandaloneMonthSymbols.enumerated().map { offset, name in
            Month(index: offset,
                  symbol: name,
                  isSelected: false)
        }
    }()

    lazy private var collectionViewLayoutConfiguration: UICollectionViewCompositionalLayoutConfiguration = {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        return configuration
    }()

    lazy private var collectionViewLayout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            ))
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(54),
                    heightDimension: .fractionalHeight(1)
                ),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            return section
        }
        layout.configuration = self.collectionViewLayoutConfiguration
        return layout
    }()

    lazy private var dataSource = UICollectionViewDiffableDataSource<Section, Month>(
        collectionView: self.collectionView,
        cellProvider: { collectionView, indexPath, month in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonthCell.reuseIdentifier,
                                                          for: indexPath) as! MonthCell
            cell.monthNameLabel.text = month.symbol.uppercased()
            cell.monthNameLabel.textColor = month.isSelected ? .systemBlue : .darkText
            cell.monthNameLabel.layer.borderWidth = month.isSelected ? 1 : 0
            return cell
    })

    lazy private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect(x: 0,
                                                            y: self.collectionViewVerticalInset,
                                                            width: self.bounds.size.width,
                                                            height: self.bounds.size.height - 2 * self.collectionViewVerticalInset), collectionViewLayout: self.collectionViewLayout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MonthCell.self, forCellWithReuseIdentifier: MonthCell.reuseIdentifier)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        self.addSubview(collectionView)
        return collectionView
    }()

    private let disposeBag = DisposeBag()
    fileprivate let selectedMonthSubject = PublishSubject<Int>()
    var observeSelectedMonth: Observable<Int> {
        self.selectedMonthSubject.asObservable()
    }
    var collectionViewVerticalInset: CGFloat { 10 }
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }
    
    // MARK: Actions
    
    private func configure() {
        self.configureUI()
        self.configureActions()
    }
    
    private func configureUI() {
        self.collectionView.dataSource = self.dataSource
        self.collectionView.delegate = self
        self.configureGradientViews()
        self.reload()
    }
    
    private func configureGradientViews() {
        let gradientViewSize = CGSize(width: 28, height: self.bounds.size.height)
        let gradientViewLeftFrame = CGRect(origin: .zero, size: gradientViewSize)
        let gradientViewRightFrame = CGRect(origin: .zero, size: gradientViewSize)
        let gradientViewLeft = TransparentGradientView(frame: gradientViewLeftFrame,
                                                       direction: .horizontal)
        let gradientViewRight = TransparentGradientView(frame: CGRect(x: self.bounds.size.width - 28, y: 0, width: gradientViewSize.width, height: gradientViewSize.height),
                                                       direction: .horizontalReversed)
        gradientViewLeft.backgroundColor = .systemBackground
        gradientViewRight.backgroundColor = .systemBackground
        self.addSubview(gradientViewLeft)
        self.addSubview(gradientViewRight)
    }
    
    private func reload() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Month>()
        snapshot.appendSections([Section.months])
        snapshot.appendItems(self.months)
        self.dataSource.apply(snapshot)
    }
    
    private func configureActions() {
        let months = self.months
        self.observeSelectedMonth
            .do(onNext: { [weak self] selectedMonth in
                self?.collectionView.scrollToItem(at: IndexPath(item: selectedMonth,
                                                               section: 0),
                                                  at: .centeredHorizontally,
                                                  animated: true)
            })
            .debounce(RxTimeInterval.milliseconds(250), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] selectedMonth in
                self?.months = months.reduce([Month]()) { result, nextMonth in
                    var nextElement = nextMonth
                    nextElement.isSelected = nextMonth.index == selectedMonth
                    return result + [nextElement]
                }
                self?.reload()
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedMonthSubject.onNext(indexPath.item)
    }
}


// MARK: Binder

extension Reactive where Base: MonthNavigationView {
    var selectedMonth: Binder<Int> {
        Binder(self.base) { view, month in
            view.selectedMonthSubject.onNext(month)
        }
    }
}

let rect = CGRect(x: 0, y: 0, width: 375, height: 60)
let monthNavigation = MonthNavigationView(frame: rect)
PlaygroundPage.current.liveView = monthNavigation

Observable.just((1..<13))
    .map { $0.randomElement() }
    .unwrap()
    .delay(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
    .bind(to: monthNavigation.rx.selectedMonth)
