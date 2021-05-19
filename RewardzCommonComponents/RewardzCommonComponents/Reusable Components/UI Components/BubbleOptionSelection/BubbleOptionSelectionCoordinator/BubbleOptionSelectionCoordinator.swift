//
//  BubbleOptionSelectionCoordinator.swift
//  Cerrapoints SG
//
//  Created by Rewardz on 02/11/19.
//  Copyright © 2019 Rewradz Private Limited. All rights reserved.
//

import Foundation

protocol BubbleOptionSelectionListener : class {
    func manageItemSelection(_ selectedIndex : Int, delectedIndex : Int?)
}

class BubbleOptionSelectionCoordinator {
    private var selectedItems = [Int]()
    private var isMultipleSelectionAllowed = false
    private weak var selectionListener : BubbleOptionSelectionListener?
    
    init(isMultipleSelectionAllowed : Bool, selectionListener : BubbleOptionSelectionListener?) {
        self.isMultipleSelectionAllowed = isMultipleSelectionAllowed
        self.selectionListener = selectionListener
    }
    
    func toggleSelection(_ index : Int){
        if let selectedItemIndex = selectedItems.firstIndex(of: index){
            print(">>>>>>>>>> item deselected at \(index)")
            selectedItems.remove(at: selectedItemIndex)
            selectionListener?.manageItemSelection(0, delectedIndex: index)
        }else{
            print("<<<<<<< item selected at \(index)")
            if isMultipleSelectionAllowed{
                selectedItems.append(index)
                selectionListener?.manageItemSelection(index, delectedIndex: nil)
            }else{
                let previouslySelectedItem = selectedItems.first
                selectedItems = [index]
                selectionListener?.manageItemSelection(index, delectedIndex: previouslySelectedItem)
            }
        }
    }
    
    func isItemSelected(_ index : Int) -> Bool{
        return selectedItems.firstIndex(of: index) != nil
    }
}
