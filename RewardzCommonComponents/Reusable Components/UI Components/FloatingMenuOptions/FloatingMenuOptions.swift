//
//  FloatingMenuOptions.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 13/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import KUIPopOver

public struct FloatingMenuOption {
    var title : String
    var action : (()-> Void)
    
    public init(title : String, action : @escaping (()-> Void)) {
        self.title = title
        self.action = action
    }
}

public class FloatingMenuOptions: UIViewController, KUIPopOverUsable {
    public var contentSize: CGSize {
        return CGSize(width: 160, height: max(24, 24 * options.count))
    }
    public var popOverBackgroundColor: UIColor?{
        return .white
    }
    public var arrowDirection: UIPopoverArrowDirection = .none
    public var options : [FloatingMenuOption]
    
    public init( options : [FloatingMenuOption]) {
        self.options = options
        super.init(nibName: "FloatingMenuOptions", bundle: Bundle(for: FloatingMenuOptions.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @IBOutlet private weak var listTable : UITableView?
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.view.superview?.layer.cornerRadius = 0.0;
        self.view.superview?.clipsToBounds = false
        self.view.superview?.layoutSubviews()
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        setupTableView()
    }
    
    private func setupTableView(){
        listTable?.separatorStyle = options.count == 1 ? .none : .singleLine
        listTable?.isScrollEnabled = false
        listTable?.register(
            UINib(nibName: "FloatingMenuOptionTableViewCell", bundle: Bundle(for: FloatingMenuOptionTableViewCell.self)),
            forCellReuseIdentifier: "FloatingMenuOptionTableViewCell"
        )
    }
}

extension FloatingMenuOptions : UITableViewDataSource, UITableViewDelegate{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FloatingMenuOptionTableViewCell") as! FloatingMenuOptionTableViewCell
        cell.optionTile?.text = options[indexPath.row].title
        cell.optionTile?.font = UIFont.Button
        if indexPath.row == (options.count - 1){
            cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width, bottom: 0, right: 0)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 24
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.options[indexPath.row].action()
        }
    }
}
