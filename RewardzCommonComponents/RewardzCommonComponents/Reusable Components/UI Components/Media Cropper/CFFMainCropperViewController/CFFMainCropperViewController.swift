//
//  CFFMainCropperViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/07/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import Photos

protocol CFFMainCropperDelegate : class {
    func finishedCropping(_ selectedMediaItem : LocalSelectedMediaItem)
}

class CFFMainCropperViewController: UIViewController {
    @IBOutlet private var resetButton : UIButton!
    @IBOutlet private var doneButton : UIButton!
    @IBOutlet private var rotateButton : UIButton!
    @IBOutlet private var rotateButtonContainer : UIView!
    private var currentlyProcessingMediaItem : LocalSelectedMediaItem!
    weak var cropperDelegate: CFFMainCropperDelegate?
    weak var themeManager: CFFThemeManagerProtocol?
    
    // MARK: IBOutlets
    
    @IBOutlet weak var scrollContainerView: UIView!
    @IBOutlet weak var scrollView: FAScrollView!
    
    
    @IBAction func zoom(_ sender: Any) {
        scrollView.zoom()
    }
    
    
    func loadImage(mediaItem : LocalSelectedMediaItem)  {
        currentlyProcessingMediaItem = mediaItem
        if let croppedImage = mediaItem.croppedImage{
            self.displayImageInScrollView(image: croppedImage)
        }else if let unwrappedAsset = mediaItem.asset{
            FAImageLoader.imageFrom(asset: unwrappedAsset, size: PHImageManagerMaximumSize) { (image) in
                DispatchQueue.main.async {
                    self.displayImageInScrollView(image: image)
                }
            }
        }
    }
    
    func displayImageInScrollView(image:UIImage){
        self.scrollView.imageToDisplay = image
    }
    
    // MARK: Public Properties
    
    var imageViewToDrag: UIImageView!
    var indexPathOfImageViewToDrag: IndexPath!
    
    let cellWidth = ((UIScreen.main.bounds.size.width)/3)-1
    
    
    // MARK: Private Properties
    
    private let imageLoader = FAImageLoader()
    private var croppedImage: UIImage? = nil
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        setupUI()
    }
    
    private func setupUI(){
        resetButton.titleLabel?.font = .Button
        resetButton.setTitleColor(.buttonColor, for: .normal)
        
        doneButton.titleLabel?.font = .Highlighter1
        doneButton.setTitleColor(.buttonColor, for: .normal)
        doneButton.borderedControl(borderColor: .borderColor, borderWidth: 2.0)
        
        rotateButtonContainer.backgroundColor = .grayBackGroundColor()
        rotateButtonContainer.curvedCornerControl()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Functions
    
    
    private func captureVisibleRect() -> UIImage{
        
        var croprect = CGRect.zero
        let xOffset = (scrollView.imageToDisplay?.size.width)! / scrollView.contentSize.width;
        let yOffset = (scrollView.imageToDisplay?.size.height)! / scrollView.contentSize.height;
        
        croprect.origin.x = scrollView.contentOffset.x * xOffset;
        croprect.origin.y = scrollView.contentOffset.y * yOffset;
        
        let normalizedWidth = (scrollView?.frame.width)! / (scrollView?.contentSize.width)!
        let normalizedHeight = (scrollView?.frame.height)! / (scrollView?.contentSize.height)!
        
        croprect.size.width = scrollView.imageToDisplay!.size.width * normalizedWidth
        croprect.size.height = scrollView.imageToDisplay!.size.height * normalizedHeight
        
        let toCropImage = scrollView.imageView.image?.fixImageOrientation()
        let cr: CGImage? = toCropImage?.cgImage?.cropping(to: croprect)
        let cropped = UIImage(cgImage: cr!)
        
        return cropped
        
    }
    private func isSquareImage() -> Bool{
        let image = scrollView.imageToDisplay
        if image?.size.width == image?.size.height { return true }
        else { return false }
    }
    
    
    // MARK: Public Functions
    
    
    func replicate(_ image:UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage?.copy() else {
            return nil
        }
        
        return UIImage(cgImage: cgImage,
                       scale: image.scale,
                       orientation: image.imageOrientation)
    }
    
    
    @IBAction func crop(_ sender: Any) {
        currentlyProcessingMediaItem.croppedImage = captureVisibleRect()
        cropperDelegate?.finishedCropping(currentlyProcessingMediaItem)
    }
    
    @IBAction func reset(_ sender: Any){
        currentlyProcessingMediaItem.croppedImage = nil
        loadImage(mediaItem: currentlyProcessingMediaItem)
        cropperDelegate?.finishedCropping(currentlyProcessingMediaItem)
    }
    
    @IBAction func rotate90ClockWise(_ sender: Any){
        displayImageInScrollView(image: (scrollView.imageToDisplay?.rotate(radians: CGFloat(Double.pi/2)))!)
    }
    
}
