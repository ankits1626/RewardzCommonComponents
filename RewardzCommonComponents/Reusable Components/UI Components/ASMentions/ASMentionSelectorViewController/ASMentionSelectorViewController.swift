//
//  ASMentionSelectorViewController.swift
//  MentionsPOC
//
//  Created by Ankit Sachan on 06/12/20.
//

import UIKit

protocol TagUserPickerDelegate : class {
    func didFinishedPickingUser(_ user: ASTaggedUser, replacementText: String)
}

typealias UserPickerCompletionBlock = (ASTaggedUser?) -> Void

class ASMentionSelectorViewController: UIViewController {
    
    var completion : UserPickerCompletionBlock?
    weak var pickerDelegate : TagUserPickerDelegate?
    var networkRequestCoordinator : CFFNetworkRequestCoordinatorProtocol!
    weak var mediaFetcher: CFFMediaCoordinatorProtocol?
    var isAddedToParent = false
    private lazy var listFetcher: TagUserListProvider = {
        return TagUserListProvider(networkRequestCoordinator: networkRequestCoordinator)
    }()
    
    private var users : [ASTaggedUser]?
    private var searchKey : String?
    lazy private var tapGestureRecognizer: UITapGestureRecognizer = {
        let tap =  UITapGestureRecognizer(target: self, action: #selector(handleKeyboardDismiss))
        tap.delegate = self
        return tap
    }()
    
    @IBOutlet private weak var userListTable : UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        setupTableView()
    }
    
    private func setupTableView(){
        userListTable?.register(
            UINib(
                nibName: "TagUserTableViewCell",
                bundle: Bundle(for: TagUserTableViewCell.self)),
            forCellReuseIdentifier: "TagUserTableViewCell"
        )
    }
    
    func addTagPickerToParent(_ parent: UIViewController?) {
        if !isAddedToParent{
            isAddedToParent =  true
            parent?.addChild(self)
            view.frame = CGRect.zero
            parent?.view.addSubview(view)
            didMove(toParent: parent)
        }
    }
    
    func searchForUser(_ key: String, displayRect: CGRect, parent: UIViewController?, shouldSearchOnlyDepartment: Bool) {
        addTagPickerToParent(parent)
        view.layer.shadowColor =  UIColor.clear.cgColor
        listFetcher.fetchUserList(key, shouldSearchOnlyDepartment: shouldSearchOnlyDepartment) { [weak self](result) in
            DispatchQueue.main.async {
                if let unwrappedSelf = self{
                    switch result {
                    case .Success(result: let result):
                        if let users = result.users,
                           !users.isEmpty{
                            unwrappedSelf.searchKey = key
                            self?.users = users
                            unwrappedSelf.updateFrameOfPicker(displayRect)
                            unwrappedSelf.updateShadow()
                            unwrappedSelf.userListTable?.reloadData()
                            parent?.view.addGestureRecognizer(unwrappedSelf.tapGestureRecognizer)
                        }else{
                            fallthrough
                        }
                    case .SuccessWithNoResponseData:
                        fallthrough
                    case .Failure(error: _):
                        self?.users = nil
                        if unwrappedSelf.isAddedToParent{
                            unwrappedSelf.userListTable?.reloadData()
                            unwrappedSelf.dismissTagSelector {
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updateShadow()  {
        let shadowPath = UIBezierPath(rect: view.bounds)
        view.layer.masksToBounds = false
        view.layer.shadowColor =  UIColor.clear.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let userCount = self.users?.count,
               userCount > 0{
                self.view.layer.shadowColor =  UIColor.black.cgColor
            }else{
                self.view.layer.shadowColor =  UIColor.clear.cgColor
            }
        }
        view.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowPath = shadowPath.cgPath
    }
    
    func updateFrameOfPicker(_ cursorRectRect: CGRect) {
        view.layer.shadowColor =  UIColor.clear.cgColor
        let keyboardHeight = KeyboardService.shared.measuredSize
        let convertedRect = cursorRectRect
        let delta : CGFloat =  20
        let pickerHeight = CGFloat(120)
        let viewY = convertedRect.origin.y + pickerHeight + delta + 44
        let keyboardY = keyboardHeight.origin.y
        var y_cord = convertedRect
        var x = convertedRect.origin.x
        if (x + 200) > UIScreen.main.bounds.width{
            x = UIScreen.main.bounds.width - 210
        }
        let difference = (keyboardHeight.height - convertedRect.origin.y)
        let extraSpace = difference < 120 ? convertedRect.origin.y - 113  : convertedRect.origin.y + delta
        if viewY > keyboardY{
            y_cord = CGRect(
                x: x,
                y: convertedRect.origin.y - delta - pickerHeight,
                width: 200,
                height: pickerHeight)
        }else{
            y_cord = CGRect(
                x: x,
                y: extraSpace ,
                width: 200,
                height: pickerHeight
            )
        }
        view.frame = y_cord
    }

}

extension ASMentionSelectorViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagUserTableViewCell") as! TagUserTableViewCell
        cell.userDisplayName?.text = self.users?[indexPath.row].displayName
        cell.userDisplayName?.font = .SemiBold12
        cell.department?.text = self.users?[indexPath.row].department
        cell.department?.font = .Caption1
        cell.department?.textColor = .getSubTitleTextColor()
        cell.contentView.backgroundColor = .guidenceViewBackgroundColor
        mediaFetcher?.fetchImageAndLoad(cell.profileImage, imageEndPoint: self.users?[indexPath.row].profileImage ?? "")
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedUser = users?[indexPath.row],
           let searchKey = self.searchKey{
            pickerDelegate?.didFinishedPickingUser(selectedUser, replacementText: searchKey)
        }
    }
    
    func dismissTagSelector(_ completion :(() -> Void)) {
        isAddedToParent = false
        self.view.removeFromSuperview()
        self.removeFromParent()
        completion()
    }
}

extension ASMentionSelectorViewController{
    @objc private func handleKeyboardDismiss(){
        parent?.view.removeGestureRecognizer(tapGestureRecognizer)
        view.endEditing(true)
        dismissTagSelector {}
    }
}

extension ASMentionSelectorViewController : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view,
           touchView.isDescendant(of: view){
            return false
        }
        return true
    }
    
}
