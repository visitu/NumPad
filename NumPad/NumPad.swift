//
//  NumPad.swift
//  NumPad
//
//  Created by Lasha Efremidze on 1/9/16.
//  Copyright © 2016 Lasha Efremidze. All rights reserved.
//

import UIKit

public typealias Position = (row: Int, column: Int)

public protocol NumPadDataSource: class {
    
    func numberOfRowsInNumberPad(numPad: NumPad) -> Int
    func numPad(numPad: NumPad, numberOfColumnsInRow row: Int) -> Int
    func numPad(numPad: NumPad, titleForButtonAtPosition position: Position) -> String
    
}

extension NumPadDataSource {
    
    
    
}

public protocol NumPadDelegate: class {
    
    func numPad(numPad: NumPad, didSelectButtonAtIndexPath indexPath: NSIndexPath)
    
}

extension NumPadDelegate {
    
    func numPad(numPad: NumPad, didSelectButtonAtIndexPath indexPath: NSIndexPath) {}
    
}

public class NumPad: UIView {

    let collectionView = UICollectionView()
    
    weak public var delegate: NumPadDataSource?
    weak public var dataSource: NumPadDelegate?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        collectionView.collectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            return layout
        }()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clearColor()
        collectionView.allowsSelection = false
        collectionView.scrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CollectionViewCell.self)
        addSubview(collectionView)
        
        let views = ["collectionView": collectionView]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: [], metrics: nil, views: views))
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

// MARK: - UICollectionViewDataSource
extension NumPad: UICollectionViewDataSource {
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (0..<numberOfRows()).map { numberOfColumnsInRow($0) }.reduce(0, combine: +)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        let position = positionForIndexPath(indexPath)
        
        let title = delegate?.numPad(self, titleForButtonAtPosition: position)
        cell.button.setTitle(title, forState: .Normal)
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension NumPad: UICollectionViewDelegate {
    
}

// MARK: - Helpers
extension NumPad {
    
    func positionForIndexPath(indexPath: NSIndexPath) -> Position {
        let row = rowForIndexPath(indexPath)
        return (row: row, column: 0)
    }
    
    func rowForIndexPath(indexPath: NSIndexPath) -> Int {
        
        return 0
    }

    func numberOfRows() -> Int {
        return delegate?.numberOfRowsInNumberPad(self) ?? 0
    }
    
    func numberOfColumnsInRow(row: Int) -> Int {
        return delegate?.numPad(self, numberOfColumnsInRow: row) ?? 0
    }
    
}

// MARK: - CollectionViewCell
class CollectionViewCell: UICollectionViewCell, ReusableView {
    
    let button = UIButton(type: .Custom)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textAlignment = .Center
        contentView.addSubview(button)
        
        let views = ["button": button]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-1-[button]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-1-[button]|", options: [], metrics: nil, views: views))
    }
    
}

protocol ReusableView: class {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return NSStringFromClass(self)
    }
}

extension UICollectionView {
    
    func register<T: UICollectionViewCell where T: ReusableView>(_: T.Type) {
        registerClass(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell where T: ReusableView>(forIndexPath indexPath: NSIndexPath) -> T {
        guard let cell = dequeueReusableCellWithReuseIdentifier(T.defaultReuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }
    
}
