//
//  ASCustomDrawerViewController.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 01/04/21.
//

import UIKit

public typealias ActionBlock = () -> Void
public class ASCustomDrawerViewControllerError {
    static let UnableToGetTopViewController = NSError(
        domain: "com.rewardz.ASCustomDrawerViewControllerError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Unable to get top view controller"]
    )
    
    static let MaximumActionCountError = NSError(
        domain: "com.rewardz.ASCustomDrawerViewControllerError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Maximum operations breached while setting drawer actions."]
    )
}

public class ASDrawerAction {
    let title : String
    let buttonActionBlock: ActionBlock
    
    public init(title : String, buttonActionBlock:@escaping ActionBlock) {
        self.title = title
        self.buttonActionBlock = buttonActionBlock
    }
}

public struct ASDrawerSetupModel {
    public var drawerImage : UIImage?
    public var headerTitleText : NSAttributedString?
    public var subHeaderText : String?
    public var isSubHeaderBackgroundDisplayed : Bool = false
    
    public init(drawerImage : UIImage?, headerTitleText : NSAttributedString?, subHeaderText : String?, isSubHeaderBackgroundDisplayed : Bool = false){
        self.drawerImage = drawerImage
        self.headerTitleText = headerTitleText
        self.subHeaderText = subHeaderText
        self.isSubHeaderBackgroundDisplayed = isSubHeaderBackgroundDisplayed
    }
}

public class ASCustomDrawerViewController: UIViewController {
    private var drawerActions : [ASDrawerAction]!{
        didSet{
            if drawerActions != nil{
                setupActionButtons()
            }
        }
    }
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    @IBOutlet private weak var drawerTopImage : UIImageView?
    @IBOutlet private weak var firstLabel : UILabel?
    @IBOutlet private weak var seconLabel : UILabel?
    @IBOutlet private weak var secondLabelContainer : UIView?
    @IBOutlet private var actionButtons : [BlockButton]!
    @IBOutlet private weak var secondLabelContainerTopConstraint : NSLayoutConstraint?
    @IBOutlet private weak var secondLabelTopConstraint : NSLayoutConstraint?
//    @IBOutlet private weak var firstActionButton : BlockButton?
//    @IBOutlet private weak var secondActionButton : BlockButton?
//    @IBOutlet private weak var thirdActionButton : BlockButton?
    
    private let drawerSetupModel : ASDrawerSetupModel
    
    public init(_ setupModel : ASDrawerSetupModel) {
        self.drawerSetupModel = setupModel
        super.init(nibName: "ASCustomDrawerViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        //actionButtons = [firstActionButton!, secondActionButton!, thirdActionButton!]
        self.drawerTopImage?.image = drawerSetupModel.drawerImage
        self.firstLabel?.attributedText = drawerSetupModel.headerTitleText
        self.seconLabel?.text = drawerSetupModel.subHeaderText
        secondLabelContainer?.backgroundColor = drawerSetupModel.isSubHeaderBackgroundDisplayed ? UIColor.getConfirmationStackColor() : .clear
        secondLabelContainer?.curvedCornerControl()
        secondLabelContainerTopConstraint?.constant = drawerSetupModel.isSubHeaderBackgroundDisplayed ? 19 : 0
        secondLabelTopConstraint?.constant = drawerSetupModel.isSubHeaderBackgroundDisplayed ? 19 : 0
    }
    
    private func setupActionButtons(){
        for (index, element) in drawerActions.enumerated(){
            let actionButton = actionButtons[index]
            actionButton.setTitle(element.title, for: .normal)
            actionButton.handleControlEvent(event: .touchUpInside, buttonActionBlock: element.buttonActionBlock)
            actionButton.isHidden = false
            if index == 0{
                actionButton.setTitleColor(.white, for: .normal)
                actionButton.curvedCornerControl()
                actionButton.backgroundColor = .getControlColor()
            }else{
                actionButton.setTitleColor(.black, for: .normal)
                actionButton.curvedBorderedControl()
                actionButton.backgroundColor = .white
            }
            
        }
    }
    
    private func setup(){
        view.clipsToBounds = true
        view.roundCorners(corners: [.topLeft, .topRight], radius: 5)
        setupUI()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    public func presentDrawer() throws{
        if let topviewController : UIViewController = UIApplication.topViewController(){
            slideInTransitioningDelegate.direction = .bottom(height: 540.7)
            transitioningDelegate = slideInTransitioningDelegate
            modalPresentationStyle = .custom
            topviewController.present(self, animated: true, completion: nil)
        }else{
            throw ASCustomDrawerViewControllerError.UnableToGetTopViewController
        }
    }
    
    public func addDrawerActions(_ drawerActions : [ASDrawerAction]) throws {
        if drawerActions.count > actionButtons.count{
            throw ASCustomDrawerViewControllerError.MaximumActionCountError
        }else{
            self.drawerActions = drawerActions
        }
    }
    
    override public func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        actionButtons = nil
        drawerActions = nil
        super.dismiss(animated: flag, completion: completion)
    }
    
    deinit {
        print("<<<<<<<<<<<<<<<<<<<<< ASCustomDrawerViewControllerError deinit called")
    }
    
}

extension ASCustomDrawerViewController{
    @IBAction private func close(){
        dismiss(animated: true, completion: nil)
    }
}
