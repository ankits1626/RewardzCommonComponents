//
//  ASChatBarview.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

public class ASChatBarError {
    static let NoHeightConstraintSet : Error = NSError(
        domain: "com.cff.aschatbarview",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Height constraint is not set for chat bar."]
    )
}
@objc public protocol ASChatBarViewDelegate : class {
    func finishedPresentingOverKeyboard()
    func addAttachmentButtonPressed()
    func removeAttachment()
    func rightButtonPressed(_ chatBar : ASChatBarview)
}

public class ASChatBarview : UIView {
    @IBOutlet public weak var container : UIView?
    @IBOutlet public weak var attachImageButton : UIButton?
    @IBOutlet public weak var sendButton : UIButton?
    @IBOutlet public weak var messageTextView : KMPlaceholderTextView?
    @IBOutlet private weak var placeholderLabel : UILabel?
    @IBOutlet public weak var delegate : ASChatBarViewDelegate?
    var tagPicker : ASMentionSelectorViewController?
    @IBOutlet private weak var heightConstraint : NSLayoutConstraint?
    @IBOutlet private weak var leftContainer : UIView?
    @IBOutlet private weak var leftContainerHeightConstraint : NSLayoutConstraint?
    @IBOutlet private weak var leftContainerWidthConstraint : NSLayoutConstraint?
    var taggedMessaged : String = ""
    public override var backgroundColor: UIColor?{
        didSet{
            container?.backgroundColor = backgroundColor
        }
    }
    lazy var tap: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(dismiss))
    }()
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    lazy var maxHeight: NSLayoutConstraint = {
        let _bottomConstraint =   NSLayoutConstraint(
            item: messageTextView!,
            attribute: NSLayoutConstraint.Attribute.height,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: nil,
            attribute: NSLayoutConstraint.Attribute.height,
            multiplier: 1,
            constant: 0)
        _bottomConstraint.priority = UILayoutPriority.defaultHigh
        return _bottomConstraint
    }()

    private let kAttachmentContainerWidth : CGFloat = 100
    private let kAttachmentContainerHeight : CGFloat = 80
    private let kAttachmentContainerTopInset : CGFloat = 5
    private let kAttachmentContainerBottomInset : CGFloat = 5
    private let kDefaultAttachmentContainerWidth : CGFloat = 44
    private let kDefaultAttachmentContainerHeight  : CGFloat = 44
    
    public var placeholder: String?{
        didSet{
            placeholderLabel?.text = placeholder
        }
    }
    
    public var placeholderColor : UIColor?{
        didSet{
            placeholderLabel?.textColor = placeholderColor
        }
    }
    
    public var placeholderFont : UIFont?{
        didSet{
            placeholderLabel?.font = placeholderFont
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonSetup()
        setupCoordinator(messageTextView)
    }

    private func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardAppearance),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardAppearance),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func registerForTextChangeNotification(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textChanged),
            name: UITextView.textDidChangeNotification,
            object: nil
        )
    }

    private func commonSetup(){
        xibSetup()
        registerForKeyboardNotifications()
        registerForTextChangeNotification()
    }
    
    func registerTextView() {
        if ASMentionCoordinator.shared.targetTextview == nil{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.setupCoordinator(self.messageTextView)
            })
        }
    }

    private var previousnumberOfLines : Int!
    private let maxNumberOflines = 4

    @objc private func textChanged(){
        registerTextView()
        if let txtview = messageTextView{
            placeholderLabel?.isHidden = !txtview.text.isEmpty
            attachImageButton?.isEnabled = !txtview.text.isEmpty
            sendButton?.isEnabled = !txtview.text.isEmpty
            if (previousnumberOfLines == nil ) || (previousnumberOfLines != txtview.getNumberOfLines()) || (txtview.getNumberOfLines() == maxNumberOflines){
                previousnumberOfLines = txtview.getNumberOfLines()
                if txtview.getNumberOfLines() >= maxNumberOflines{
                    maxHeight.constant = txtview.frame.size.height
                    messageTextView?.addConstraint(maxHeight)
                    txtview.isScrollEnabled = true
                    txtview.setNeedsFocusUpdate()
                    txtview.invalidateIntrinsicContentSize()
                }else{
                    txtview.isScrollEnabled = false
                    if txtview.constraints.contains(maxHeight){
                        txtview.removeConstraint(maxHeight)
                    }
                    txtview.invalidateIntrinsicContentSize()
                }
            }
        }
    }
    
    private func setupCoordinator(_ targetTextView: UITextView?){
        targetTextView?.delegate = ASMentionCoordinator.shared
        ASMentionCoordinator.shared.loadInitialText(targetTextView: targetTextView)
        ASMentionCoordinator.shared.textUpdateListener = self
    }
    
    
    @objc private func handleKeyboardAppearance(notification: NSNotification) {
//        superview?.addGestureRecognizer(tap)
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
        var bottomInset : CGFloat = 0
        if #available(iOS 11.0, *) {
            //TO:DO: Needs to be refactored
            bottomInset = self.superview?.superview?.superview?.safeAreaInsets.bottom ?? 34
        }
        bottomConstraint.constant = isKeyboardShowing ?  keyboardFrame.height - bottomInset : 0
        UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.superview?.layoutIfNeeded()
        }) { (completed) in
            if isKeyboardShowing{
                self.delegate?.finishedPresentingOverKeyboard()
            }
        }
    }

    @objc private func dismiss(){
        superview?.removeGestureRecognizer(tap)
        messageTextView?.resignFirstResponder()
    }

    func getMessage() -> String? {
        return messageTextView?.text
    }

    func activate()  {
        messageTextView?.becomeFirstResponder()
        leftButtonTapped()
    }

    func disable() throws {
        if let constraint = heightConstraint{
            let newConstraint = NSLayoutConstraint(
                item: constraint.firstItem as Any,
                attribute: constraint.firstAttribute,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: constraint.secondItem,
                attribute: constraint.secondAttribute,
                multiplier: constraint.multiplier,
                constant: 0
            )
            self.removeConstraint(constraint)
            heightConstraint = newConstraint
            self.addConstraint(newConstraint)
            self.layoutIfNeeded()
        }else{
            throw ASChatBarError.NoHeightConstraintSet
        }
    }

    func enable() throws {
        if let constraint = heightConstraint{
            let newConstraint = NSLayoutConstraint(
                item: constraint.firstItem as Any,
                attribute: constraint.firstAttribute,
                relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual,
                toItem: constraint.secondItem,
                attribute: constraint.secondAttribute,
                multiplier: constraint.multiplier,
                constant: 44
            )
            self.removeConstraint(constraint)
             heightConstraint = newConstraint
            self.addConstraint(newConstraint)
            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.layoutIfNeeded()
            }) { (completed) in

            }
        }else{
            throw ASChatBarError.NoHeightConstraintSet
        }
    }

    deinit {
        superview?.addGestureRecognizer(tap)
    }
}

extension ASChatBarview{
    @IBAction private func leftButtonTapped(){
        //addAttachedImageView()
        delegate?.addAttachmentButtonPressed()
    }

    @objc private func removeAttachedImage(){
        removeAttachedImageView()
        textChanged()
        delegate?.removeAttachment()
    }

    @IBAction private func rightButtonTapped(){
        removeAttachedImageView()
        delegate?.rightButtonPressed(self)
        messageTextView?.text = nil
        textChanged()
        messageTextView?.resignFirstResponder()
    }

    private func removeAttachedImageView(){
        //attachedImageView.removeFromSuperview()
        leftContainerWidthConstraint?.constant = kDefaultAttachmentContainerWidth
        leftContainerHeightConstraint?.constant = kDefaultAttachmentContainerHeight
        heightConstraint?.constant = kDefaultAttachmentContainerHeight
    }

}

extension ASChatBarview{
    func clearChatBar() {
    
    }
}
extension ASChatBarview : ASMentionCoordinatortextUpdateListener{
    func textUpdated() {
        taggedMessaged = ASMentionCoordinator.shared.getPostableTaggedText() ?? ""
    }
}
