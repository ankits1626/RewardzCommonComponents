//
//  OptionListViewController.swift
//  SKOR
//
//  Created by Rewardz on 20/12/17.
//  Copyright © 2017 Rewradz Private Limited. All rights reserved.
//

import UIKit
import KUIPopOver

public protocol ListItemProtocol : Equatable {
    var title : String {get}
    var showcategory : Bool{get}
    var slug : String{get}
}

public enum FilterOptionType : Int{
    case Points = 0
    case Discount
}
public struct languageSelection : ListItemProtocol {
    public var slug: String
    public var title : String
    public var type : FilterOptionType
    public var showcategory : Bool
    
    public init(slug: String, title: String, type: FilterOptionType, showcategory : Bool) {
        self.slug = slug
        self.title = title
        self.type = type
        self.showcategory = showcategory
    }
}
struct RewardFilterListOption : ListItemProtocol {
    var slug: String
    var title : String
    var type : FilterOptionType
    var showcategory : Bool
}

class OptionListViewController<T : ListItemProtocol>: UIViewController,  PopoverPresentable, KUIPopOverUsable, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    var isSearchEnabled : Bool = false
    @IBOutlet weak var optionTable : UITableView!
    var completion: (([String : Any]?) -> Void)?
    let loader = MFLoader()
    var isMultipleSelectionAllowed : Bool = false
    var shouldAllowAutoDismiss : Bool = true
    var selectedItemIndexpaths = [IndexPath]()
    private lazy var size: CGSize = {
        var categoriescount : Int = 0
        for i in 0 ..< self.currentDataSource.count {
            
            let categorycount = self.currentDataSource[i].showcategory
            if categorycount == true
            {
                categoriescount = categoriescount + 1
            }
        }
        print("%%%%%%%%%%%%%size is 44 * \(categoriescount) = \(CGFloat(44 * categoriescount))")
        return CGSize(width: 320.0, height: CGFloat(44 * categoriescount) )
    }()
    
    var contentSize: CGSize {
        return size
    }
    var originalDataSource : [T] = [T](){
        didSet{
            currentDataSource = originalDataSource
        }
    }
    private var currentDataSource : [T] = [T]()
    let cellIdentifier = "OptionListTableViewCell"
    var listSelectionCompletion : ((_ selectedItem : T) -> Void)?
    var listItemFetcher : ListItemFetcher<T>?
    
    func loadDataForList(_ items :[T]) {
        originalDataSource = items
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optionTable.register(
            UINib(nibName: "OptionListTableViewCell", bundle: Bundle(for: OptionListTableViewCell.self)),
            forCellReuseIdentifier: cellIdentifier
        )
        optionTable.tableFooterView = UIView(frame: CGRect.zero)
        fetchListItems()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchBarHeightConstraint.constant = isSearchEnabled ? 44.0 : 0
    }
    
    func fetchListItems() {
        if let unwrappedListItemFetcher = listItemFetcher{
            self.loader.showActivityIndicator(self.view)
            unwrappedListItemFetcher.fetchListItem(completionHandler: { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .Success(let fetchResult):
                        self.originalDataSource = fetchResult
                        self.currentDataSource = self.originalDataSource
                        self.optionTable.reloadData()
                        self.loader.hideActivityIndicator(self.view)
                    case .Failure(let error):
                        self.dismissPopover(animated: true)
                        self.showAlert(title: NSLocalizedString("Error", comment: ""), message:
                            error.displayableErrorMessage())
                        self.loader.hideActivityIndicator(self.view)
                    case .SuccessWithNoResponseData:
                        print("[DEBUG]")
                        self.loader.hideActivityIndicator(self.view)
                    }
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! OptionListTableViewCell).optionTitle.text = currentDataSource[indexPath.row].title
        (cell as! OptionListTableViewCell).checkBox.isHidden = shouldAllowAutoDismiss
        (cell as! OptionListTableViewCell).checkBox.isChecked = selectedItemIndexpaths.contains(indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldAllowAutoDismiss{
            if let unwrappedCompletion = listSelectionCompletion{
                           unwrappedCompletion(currentDataSource[indexPath.row])
                       }
                       self.dismissPopover(animated: true)
        }else{
            var reloadIndexPaths  : [IndexPath] = [indexPath]
            if isMultipleSelectionAllowed{
                if let index = selectedItemIndexpaths.firstIndex(of: indexPath){
                    selectedItemIndexpaths.remove(at: index)
                }else{
                    selectedItemIndexpaths.append(indexPath)
                }
            }else{
                if let deselectIndexpath = selectedItemIndexpaths.first{
                    reloadIndexPaths.append(deselectIndexpath)
                }
               selectedItemIndexpaths = [indexPath]
            }
            tableView.reloadRows(at: reloadIndexPaths, with: UITableView.RowAnimation.none)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if (searchText.count > 0) {
            currentDataSource = originalDataSource.filter{ $0.title.localizedCaseInsensitiveContains(searchText)}
        }else{
            currentDataSource = originalDataSource
        }
        optionTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func getAllSelectedItems() -> [T] {
        var selectedItems = [T]()
        for anIndexpath in selectedItemIndexpaths {
            selectedItems.append(currentDataSource[anIndexpath.row])
        }
        return selectedItems
    }
}
