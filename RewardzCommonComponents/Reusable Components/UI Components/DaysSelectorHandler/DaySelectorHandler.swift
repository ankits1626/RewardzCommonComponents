//
//  DaySelectorHandler.swift
//  RewardzCommonComponents
//
//  Created by Puneeeth on 13/08/22.
//

import UIKit

public protocol DaySelectorHandlerDelegate : class {
    func didFinishedSelection(selectedDay :Int)
}

public class DaySelectorHandler {
    private var MAX_YEAR = 3
    weak var yearHorizontalScrollingOptionsView : HorizontalScrollingOptions? = nil
    private let currentYear : Int = Calendar(identifier: .gregorian).component(.year, from: Date())
    private var selectedDay : Int {
        didSet{
            delegate?.didFinishedSelection(selectedDay: selectedDay)
        }
    }
    weak var delegate : DaySelectorHandlerDelegate?
    public init(_ delegate : DaySelectorHandlerDelegate) {
        self.delegate = delegate
        selectedDay = 1
        self.delegate?.didFinishedSelection(selectedDay: selectedDay)
    }
    public func indexOfDefaultSelectdYear() -> Int {
        return 0
    }
    private func getDays() -> [Int]{
        let years =  Array(1...30)
        return years
    }
}

extension DaySelectorHandler : HorizontalScrollingOptionsDelegate, HorizontalScrollingOptionsDatasource{
    public func didSelectItemAt(_ index: Int) {
        let years =  Array(1...30)
        selectedDay = years[index]
    }
    
    public func numberOfItems() -> Int {
        return getDays().count
    }
    
    public func configureItemCell(_ cell: UICollectionViewCell, index: Int) {
        (cell as? HorizontalScrollingOptionCell)?.titleLBL?.text = "\(getDays()[index])"
    }
}

