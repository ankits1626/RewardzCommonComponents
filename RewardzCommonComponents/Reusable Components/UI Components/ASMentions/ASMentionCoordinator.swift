//
//  ASMentionCoordinator.swift
//  MentionsPOC
//
//  Created by Ankit Sachan on 06/12/20.
//

import UIKit

protocol ASMentionCoordinatortextUpdateListener : class {
    func textUpdated()
}

class ASMentionCoordinator: NSObject{
    weak var textUpdateListener : ASMentionCoordinatortextUpdateListener?
    weak var delegate : PostEditorCellFactoryDelegate?
    static let shared = ASMentionCoordinator()
    weak var targetTextview : UITextView?
    
    private var currentTagRange : NSRange?
    
    func getPresentableMentionText(_ text : String?, completion: ((_ attr: NSAttributedString?) -> Void)) {
        if let unwrappedText = text{
            ASMentionTextParser.shared.parse(unwrappedText) { (mentions, unwrppedCleanedString) in
                let attr = ASMentionPresenter.shared.updatePresentationOfText(
                    text: NSAttributedString(string: unwrppedCleanedString!),
                    mentions: mentions
                )
                completion(attr)
            }
        }else{
            completion(nil)
        }
    }
    
    func loadInitialText(targetTextView: UITextView?) {
        self.targetTextview = targetTextView
        configureTextView()
        currentTagRange = nil
        if let existingText = targetTextview?.text{
            ASMentionTextParser.shared.parse(existingText, completion: { (mentions, cleanedString)  in
                if let unwrppedCleanedString = cleanedString{
                    ASMentionStore.shared.updateStoreAfterTextLoad(mentions)
                    targetTextView?.attributedText =  ASMentionPresenter.shared.updatePresentationOfText(text: NSAttributedString(string: unwrppedCleanedString), mentions: mentions)
                }else{
                    print("<<<<<< noting to load after loadInitialText")
                }
            })
        }
    }
    
    public func clearMentionsTextView() {
        ASMentionStore.shared.clearAllMentions()
    }
    
    private func configureTextView(){
        targetTextview?.autocorrectionType = .no
        targetTextview?.autocapitalizationType = .none
    }
    
    func getAttributedText() -> NSAttributedString? {
        if let unwrppedCleanedString = targetTextview?.text{
            let attr =  ASMentionPresenter.shared.updatePresentationOfText(text: NSAttributedString(string: unwrppedCleanedString), mentions: ASMentionStore.shared.mentions)
            targetTextview?.attributedText = attr
            return attr
        }else{
            return nil
        }
    }
    
    func updateTextView() {
        targetTextview?.attributedText = getAttributedText()
    }
    
    func getPostableTaggedText() -> String? {
        if var text = targetTextview?.attributedText.string{
            var offsetAfterMentionUpdate = 0
            var mentions = ASMentionStore.shared.mentions
            mentions?.sort(by: { (a, b) -> Bool in
                return a.range.location < b.range.location
            })
            mentions?.forEach({ (aMention) in
                let start = text.utf16.index(text.utf16.startIndex , offsetBy: aMention.range.location + offsetAfterMentionUpdate)
                let end = text.utf16.index(start, offsetBy: aMention.range.length)
                let postableTag = aMention.getPostableMention()
                offsetAfterMentionUpdate = offsetAfterMentionUpdate +  postableTag.count - aMention.range.length
                text.replaceSubrange(start..<end, with: postableTag)
            })
            return text
        }else{
            return nil
        }
    }
}

extension ASMentionCoordinator : UITextViewDelegate{
    
    @objc private func handleKeyboardDismiss(){
        targetTextview?.resignFirstResponder()
        delegate?.dismissUserListForTagging(completion: {})
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        print("<<<<<<<< changed selection")
        hideTagPickerIfRequired(textView: textView)
        delegate?.updateTagPickerFrame(textView)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        let r = textView.selectedRange
        updateTextView()
        textView.selectedRange = NSMakeRange(r.location , 0)
        textUpdateListener?.textUpdated()
        self.showTagPickerIfRequired(textView: textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("\(range) -- \(text)")
        let attributes : [NSAttributedString.Key: Any] = [
            .font : UIFont.Caption2,
            .foregroundColor : UIColor.black
        ]
        textView.typingAttributes = attributes
        if let intersectingMentions =  ASMentionStore.shared.clearIntersectingMentions(range),
           let startRange = intersectingMentions.first?.range,
           let endRange = intersectingMentions.last?.range,
           let val = textView.text{
            let updateRange = NSMakeRange(
                min(startRange.location, range.location) ,
                max((endRange.location - startRange.location ) + endRange.length, range.length)
            )
            let start = textView.text.utf16.index(val.utf16.startIndex, offsetBy: updateRange.location)
            let end = textView.text.utf16.index(start, offsetBy: updateRange.length)
           
            textView.text.replaceSubrange(start..<end, with: text)
            handleTextUpdate(textView: textView, range: updateRange, text: text)
            textView.selectedRange = NSMakeRange(updateRange.location+1 , 0)
            return false
        }else{
            handleTextUpdate(textView: textView, range: range, text: text)
        }
        return true
    }
    
    private func handleTextUpdate(textView: UITextView, range: NSRange, text: String){
        if range.length > 0{
            if text == ""{
                ASMentionStore.shared.updateStoreAfterTextDeletion(range)
            }else{
                ASMentionStore.shared.updateStoreAfterTextReplacement(range, replacementTextLength: text.count)
            }
//            updateTextView()
            
        }else{
            print("\(text) has been added in range \(NSMakeRange(range.location, text.count))")
            ASMentionStore.shared.updateStoreAfterTextAddition(NSMakeRange(range.location, text.count))
        }
        //textUpdateListener?.textUpdated()
    }
    
    private func checkIfTagPickerNeedsToBeDisplayed(_ tagStartingRange : NSRange, inputText : String){
        if inputText == "@"{
            print("*********  activate tagging")
            currentTagRange = tagStartingRange
        }
    }

}

extension ASMentionCoordinator{
    func showTagPickerIfRequired(textView: UITextView){
        let endPosition = textView.selectedRange.location
        let substring = textView.text.substring(to: endPosition)
        if let lastTag = substring.lastTagOccurence("@"),
           lastTag.tag.count>2{
            let searchKey = lastTag.tag.substring(from: 1)
            print("show picker for key \(searchKey)")
            if let _ = textView.selectedTextRange {
                delegate?.showUserListForTagging(searckKey: searchKey, textView: textView, pickerDelegate: self)
            }
            
        }
    }
    
    func hideTagPickerIfRequired(textView: UITextView) {
        let endPosition = textView.selectedRange.location
        let substring = textView.text.substring(to: endPosition)
        if let _ = substring.lastTagOccurence("@"){
        }else{
            delegate?.dismissUserListForTagging(completion: {})
        }
    }
}

extension ASMentionCoordinator : TagUserPickerDelegate{
    func didFinishedPickingUser(_ user: ASTaggedUser, replacementText: String){
        delegate?.dismissUserListForTagging(completion: {
            if let endPosition = targetTextview?.selectedRange.location,
               let substring = targetTextview?.text.substring(to: endPosition),
               let lastTag = substring.lastTagOccurence("@"),
               let val = self.targetTextview?.text{
                print("<<<<<<<<<<< update started after user selection >>>>>>>>>>>>>>>>")
                let start = val.utf16.index(val.utf16.startIndex, offsetBy: lastTag.tagRange.location)
                let end = val.utf16.index(start, offsetBy: lastTag.tagRange.length)
                self.targetTextview!.text.replaceSubrange(start..<end, with: user.displayName)
                let mention = ASMention(user.getTagMarkup(), startPosition: lastTag.tagRange.location)
                ASMentionStore.shared.updateStorAfterNewMention(mention, offset: lastTag.tag.count)
                updateTextView()
                self.targetTextview!.selectedRange = NSMakeRange(lastTag.tagRange.location + user.displayName.count , 0)
                print("<<<<<<<<<<< update ended after user selection >>>>>>>>>>>>>>>>")
                textUpdateListener?.textUpdated()
            }
        })
        
    }
}

