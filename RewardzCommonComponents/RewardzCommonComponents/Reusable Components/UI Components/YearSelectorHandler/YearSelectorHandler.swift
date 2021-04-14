//
//  YearSelectorHandler.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 01/04/21.
//

import UIKit

public protocol YearSelectorHandlerDelegate : class {
    func didFinishedSelection(selectedYear :Int)
}

public class YearSelectorHandler {
    private var MAX_YEAR = 3
    weak var yearHorizontalScrollingOptionsView : HorizontalScrollingOptions? = nil
    private let currentYear : Int = Calendar(identifier: .gregorian).component(.year, from: Date())
    private var selectedYear : Int {
        didSet{
            delegate?.didFinishedSelection(selectedYear: selectedYear)
        }
    }
    weak var delegate : YearSelectorHandlerDelegate?
    public init(_ delegate : YearSelectorHandlerDelegate) {
        self.delegate = delegate
        selectedYear = currentYear
        self.delegate?.didFinishedSelection(selectedYear: selectedYear)
    }
    public func indexOfDefaultSelectdYear() -> Int {
        return Array(currentYear-MAX_YEAR...currentYear).firstIndex(of: currentYear) ?? 0
    }
    private func getYears() -> [Int]{
        return Array(currentYear-MAX_YEAR...currentYear)
    }
}

extension YearSelectorHandler : HorizontalScrollingOptionsDelegate, HorizontalScrollingOptionsDatasource{
    public func didSelectItemAt(_ index: Int) {
       selectedYear = Array(currentYear-MAX_YEAR...currentYear+MAX_YEAR)[index]
    }
    
    public func numberOfItems() -> Int {
        return getYears().count
    }
    
    public func configureItemCell(_ cell: UICollectionViewCell, index: Int) {
        (cell as? HorizontalScrollingOptionCell)?.titleLBL?.text = "\(getYears()[index])"
    }
}
