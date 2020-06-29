//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import RxCocoa
import PlaygroundSupport

var str = "Hello, playground"

let flowLayout = UICollectionViewFlowLayout()
flowLayout.scrollDirection = .horizontal
let collectionView = UICollectionView(frame: CGRect(x: 0.0, y: 0.0, width: 400.0, height: 90.0), collectionViewLayout: flowLayout)

class PlaygroundCell: UICollectionViewCell {
}

Driver.of([1, 2, 3, 4, 5, 6, 7])
    .drive(collectionView.rx.items(cellIdentifier: "", cellType: UICollectionViewCell.self))

PlaygroundPage.current.liveView = collectionView
PlaygroundPage.current.needsIndefiniteExecution = true
