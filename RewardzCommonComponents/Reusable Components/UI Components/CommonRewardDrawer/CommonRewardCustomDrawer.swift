//
//  CommonRewardCustomDrawer.swift
//  RewardzCommonComponents
//
//  Created by Suyesh Kandpal on 18/05/22.
//

import UIKit

public typealias RewardActionBlock = () -> Void
public class CommonRewardCustomDrawerError {
    static let UnableToGetTopViewController = NSError(
        domain: "com.rewardz.CommonRewardCustomDrawerError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Unable to get top view controller"]
    )
    
    static let MaximumActionCountError = NSError(
        domain: "com.rewardz.CommonRewardCustomDrawerError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Maximum operations breached while setting drawer actions."]
    )
}

public class CommonRewardCustomDrawerAction {
    let title : String
    let buttonActionBlock: RewardActionBlock
    
    public init(title : String, buttonActionBlock:@escaping RewardActionBlock) {
        self.title = title
        self.buttonActionBlock = buttonActionBlock
    }
}

public struct CommonRewardCustomDrawerSetupModel {
    public var drawerImage : UIImage?
    public var headerTitleText : NSAttributedString?
    public var subHeaderText : String?
    public var isSubHeaderBackgroundDisplayed : Bool = false
    public var selectedRewardName : String?
    public var selectedRewardImage : String?
    public let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    public let mediaFetcher : CFFMediaCoordinatorProtocol
    public var selectedRewardQuantity : String?
    
    public init(drawerImage : UIImage?, headerTitleText : NSAttributedString?, subHeaderText : String?, isSubHeaderBackgroundDisplayed : Bool = false, selectedRewardName : String, selectedRewardImage : String, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol,mediaFetcher : CFFMediaCoordinatorProtocol,selectedRewardQuantity : String = "1"){
        self.drawerImage = drawerImage
        self.headerTitleText = headerTitleText
        self.subHeaderText = subHeaderText
        self.isSubHeaderBackgroundDisplayed = isSubHeaderBackgroundDisplayed
        self.selectedRewardImage = selectedRewardImage
        self.selectedRewardName = selectedRewardName
        self.networkRequestCoordinator = networkRequestCoordinator
        self.mediaFetcher = mediaFetcher
        self.selectedRewardQuantity = selectedRewardQuantity
    }
}

public class CommonRewardCustomDrawer: UIViewController {
    private var drawerActions : [CommonRewardCustomDrawerAction]!{
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
    @IBOutlet private weak var rewardQuantity : UILabel?
    @IBOutlet private weak var rewardName : UILabel?
    @IBOutlet private weak var secondLabelContainer : UIView?
    @IBOutlet private var actionButtons : [BlockButton]!
    @IBOutlet private weak var secondLabelContainerTopConstraint : NSLayoutConstraint?
    @IBOutlet private weak var secondLabelTopConstraint : NSLayoutConstraint?
//    @IBOutlet private weak var firstActionButton : BlockButton?
//    @IBOutlet private weak var secondActionButton : BlockButton?
//    @IBOutlet private weak var thirdActionButton : BlockButton?
    
    private let drawerSetupModel : CommonRewardCustomDrawerSetupModel
    
    public init(_ setupModel : CommonRewardCustomDrawerSetupModel) {
        self.drawerSetupModel = setupModel
        super.init(nibName: "CommonRewardCustomDrawer", bundle: Bundle(for: CommonRewardCustomDrawer.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.drawerTopImage?.roundCorners(corners: .allCorners, radius: 8.0)
        self.drawerTopImage?.curvedBorderedControl(borderColor: .lightGray, borderWidth: 1.0)
        self.drawerTopImage?.curvedCornerControl()
    }
    
    private func setupUI(){
        self.rewardName?.text = drawerSetupModel.selectedRewardName
        if let unwrappedDisplayImage = drawerSetupModel.selectedRewardImage,
           let baseUrl = self.drawerSetupModel.networkRequestCoordinator.getBaseUrlProvider().baseURLString() {
            if let displayImageUrl = URL(string: baseUrl + unwrappedDisplayImage){
                drawerSetupModel.mediaFetcher.fetchImageAndLoad(self.drawerTopImage, imageEndPoint: displayImageUrl)
            }
        }else{
            self.drawerTopImage?.image = drawerSetupModel.drawerImage
        }
        if drawerSetupModel.selectedRewardQuantity == "0" {
            self.rewardQuantity?.text = "Quantity : 1"
        }else{
            self.rewardQuantity?.text = "Quantity : \(drawerSetupModel.selectedRewardQuantity ?? "")"
        }
        
        self.firstLabel?.attributedText = drawerSetupModel.headerTitleText
        self.seconLabel?.text = drawerSetupModel.subHeaderText
//        secondLabelContainer?.backgroundColor = .clear
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
                actionButton.setTitleColor(.getControlColor(), for: .normal)
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
            slideInTransitioningDelegate.direction = .bottom(height: 599.0)
            transitioningDelegate = slideInTransitioningDelegate
            modalPresentationStyle = .custom
            topviewController.present(self, animated: true, completion: nil)
        }else{
            throw CommonRewardCustomDrawerError.UnableToGetTopViewController
        }
    }
    
    public func addDrawerActions(_ drawerActions : [CommonRewardCustomDrawerAction]) throws {
        if drawerActions.count > actionButtons.count{
            throw CommonRewardCustomDrawerError.MaximumActionCountError
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
        print("<<<<<<<<<<<<<<<<<<<<< CommonRewardCustomDrawerError deinit called")
    }
    
}

extension CommonRewardCustomDrawer{
    @IBAction private func close(){
        dismiss(animated: true, completion: nil)
    }
}
