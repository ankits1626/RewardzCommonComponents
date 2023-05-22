//
//  GenericFilterViewController.swift
//  Cerrapoints SG
//
//  Created by Rewardz on 18/10/19.
//  Copyright © 2019 Rewradz Private Limited. All rights reserved.
//

import UIKit
import KUIPopOver

public protocol PopoverPresentable{
    var completion :((_ userInfo : [String : Any]?) -> Void)? {get set}
}

public protocol GenericFilterCoordinatorProtocol : class {
    var identifier : Int {get}
    func getAllFilterOptions<T>() -> [T]
    func getExistingAppliedFilters<T>() -> [T]?
    func updateSelectedItems<T>(_ items : [T])
    func clearAllSelection()
}

public protocol GenericFilterViewDelegate : class {
    func applyFilter(_ filterCoordinator : GenericFilterCoordinatorProtocol)
}

public class GenericFilterViewController<T : ListItemProtocol>: UIViewController, PopoverPresentable, KUIPopOverUsable {
    let kHeightOfFilterTitle : CGFloat = 40
    let kHeightOfBottonButtonContainer : CGFloat = 47
     private lazy var size: CGSize = {
           var categoriescount : Int = 0
           for i in 0 ..< self.currentDataSource.count {
               
               let categorycount = self.currentDataSource[i].showcategory
               if categorycount == true
               {
                   categoriescount = categoriescount + 1
               }
           }
           print("%%%%%%%%%%%%%size is 44 * \(min(categoriescount, 2)) = \(CGFloat(44 * categoriescount))")
           return CGSize(
            width: 320.0,
            height: CGFloat(44 * categoriescount) +
                kHeightOfFilterTitle +
            kHeightOfBottonButtonContainer
        )
       }()
       
    public var contentSize: CGSize {
           return size
       }
    
    public var completion: (([String : Any]?) -> Void)?
    
    private var currentDataSource : [T] {
        return filterCoordinator.getAllFilterOptions()
    }
    
    @IBOutlet private weak var listContainer : UIView?
    @IBOutlet private weak var clearButton : UIButton?
    @IBOutlet private weak var applyButton : UIButton?
    private var listVC : OptionListViewController<T>!
    public var isMultipleSelectionAllowed : Bool = false
    @IBOutlet private weak var filterScreenTitle : UILabel?
    public override func viewDidLoad() {
        super.viewDidLoad()
        filterScreenTitle?.text = "Filter by".localized
        clearButton?.setTitle("Clear".localized, for: .normal)
        applyButton?.setTitle("Apply".localized, for: .normal)
        setup()
    }
    
    private weak var delegate : GenericFilterViewDelegate?
    private var filterCoordinator: GenericFilterCoordinatorProtocol
    
    public init( filterCoordinator: GenericFilterCoordinatorProtocol,  delegate: GenericFilterViewDelegate?) {
        self.filterCoordinator = filterCoordinator
        self.delegate = delegate
        super.init(nibName: "GenericFilterViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupList() {
        listVC = OptionListViewController(nibName: "OptionListViewController", bundle: Bundle(for: OptionListViewController<T>.self))
        listVC.isMultipleSelectionAllowed = isMultipleSelectionAllowed
        listVC.selectedItemIndexpaths = getSelectedIndexpaths()
        listVC.shouldAllowAutoDismiss = false
        listVC.loadDataForList(filterCoordinator.getAllFilterOptions())
        addViewControllerToContainer(listVC)
    }
    
    private func setupFilterAppearance(){
        clearButton?.curvedWithoutBorderedControl()
        applyButton?.curvedCornerControl()
        applyButton?.backgroundColor = .getControlColor()
    }
    
    private func setup(){
        setupList()
        setupFilterAppearance()
    }
    
    
    private func addViewControllerToContainer(_ newVC : UIViewController){
        addChild(newVC)
        newVC.view.frame = CGRect(x: 0, y: 0, width: listContainer!.bounds.size.width, height: listContainer!.bounds.size.height)
        listContainer?.addSubview(newVC.view)
        newVC.didMove(toParent: self)
    }
    
    @IBAction private func clear(){
        filterCoordinator.clearAllSelection()
        delegate?.applyFilter(filterCoordinator)
        self.dismissPopover(animated: true)
    }
    
    @IBAction private func applyFilter(){
        filterCoordinator.updateSelectedItems(listVC.getAllSelectedItems())
        delegate?.applyFilter(filterCoordinator)
        self.dismissPopover(animated: true)
    }
    
    private func getSelectedIndexpaths() -> [IndexPath]{
        var selectedindexpath = [IndexPath]()
        if let selectedItems : [T] = self.filterCoordinator.getExistingAppliedFilters(){
            for anelement in selectedItems {
                if let index = currentDataSource.firstIndex(of: anelement) {
                    selectedindexpath.append(IndexPath(row: index, section: 0))
                }
            }
        }
        return selectedindexpath
    }
}
