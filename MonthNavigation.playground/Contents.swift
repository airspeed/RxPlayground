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

final class MonthNavigationView: UIView, UICollectionViewDelegate {
    
    // MARK: Inline types
    
    final class MonthCell: UICollectionViewCell {
        static var reuseIdentifier: String { "MonthCell" }
        lazy private(set) var monthNameLabel: UILabel = {
            let label = UILabel(frame: self.bounds)
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14)
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
        calendar.locale = .init(identifier: "de-DE")
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
            return NSCollectionLayoutSection(group: group)
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
            cell.monthNameLabel.layer.borderColor = UIColor.systemBlue.cgColor
            cell.monthNameLabel.layer.cornerRadius = cell.monthNameLabel.bounds.size.height / 2
            cell.monthNameLabel.layer.borderWidth = month.isSelected ? 1 : 0
            return cell
    })

    lazy private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: self.collectionViewLayout)
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
        self.reload()
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
                self?.months = months.reduce([Month]()) { result, nextMonth in
                    var nextElement = nextMonth
                    nextElement.isSelected = nextMonth.index == selectedMonth
                    return result + [nextElement]
                }
                self?.reload()
            })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] selectedMonth in
                self?.collectionView.scrollToItem(at: IndexPath(item: selectedMonth,
                                                               section: 0),
                                                  at: .centeredHorizontally,
                                                  animated: true)
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

let rect = CGRect(x: 0, y: 0, width: 375, height: 40)
let monthNavigation = MonthNavigationView(frame: rect)
PlaygroundPage.current.liveView = monthNavigation

Observable.just((1..<13))
    .map { $0.randomElement() }
    .unwrap()
    .delay(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
    .bind(to: monthNavigation.rx.selectedMonth)
