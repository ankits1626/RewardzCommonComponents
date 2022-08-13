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
    private var selectedYear : Int {
        didSet{
            delegate?.didFinishedSelection(selectedDay: selectedYear)
        }
    }
    weak var delegate : DaySelectorHandlerDelegate?
    public init(_ delegate : DaySelectorHandlerDelegate) {
        self.delegate = delegate
        selectedYear = currentYear
        self.delegate?.didFinishedSelection(selectedDay: selectedYear)
    }
    public func indexOfDefaultSelectdYear() -> Int {
        return 0
    }
    private func getYears() -> [Int]{
        let years =  Array(1...30)
        return years
    }
}

extension DaySelectorHandler : HorizontalScrollingOptionsDelegate, HorizontalScrollingOptionsDatasource{
    public func didSelectItemAt(_ index: Int) {
        let years =  Array(1...30)
        selectedYear = years[index]
    }
    
    public func numberOfItems() -> Int {
        return getYears().count
    }
    
    public func configureItemCell(_ cell: UICollectionViewCell, index: Int) {
        (cell as? HorizontalScrollingOptionCell)?.titleLBL?.text = "\(getYears()[index])"
    }
}

