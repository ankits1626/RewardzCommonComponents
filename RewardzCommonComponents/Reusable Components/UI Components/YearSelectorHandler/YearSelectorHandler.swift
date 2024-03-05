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
    public var shouldShowFinancialYear:  Bool = false
    public var redeemptionYears : [Int] = []
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
        return 0
    }
    
    private func getYears() -> [Int]{
        if redeemptionYears.count > 0 {
            return redeemptionYears
        }else {
            let years = Array(currentYear-MAX_YEAR...currentYear)
            return years.reversed()
        }
    }
}

extension YearSelectorHandler : HorizontalScrollingOptionsDelegate, HorizontalScrollingOptionsDatasource{
    public func didSelectItemAt(_ index: Int) {
        if redeemptionYears.count > 0 {
            selectedYear = redeemptionYears[index]
        }else {
            let years = Array(currentYear-MAX_YEAR...currentYear)
            selectedYear = years.reversed()[index]
        }
    }
    
    public func numberOfItems() -> Int {
        return getYears().count
    }
    
    public func configureItemCell(_ cell: UICollectionViewCell, index: Int) {
        (cell as? HorizontalScrollingOptionCell)?.titleLBL?.text = getDisplayableYear(index)
    }
    
    private func getDisplayableYear(_ index: Int) -> String{
        if shouldShowFinancialYear{
            return "FY\(getYears()[index] % 100)"
        }else{
            return "\(getYears()[index])"
        }
    }
}
