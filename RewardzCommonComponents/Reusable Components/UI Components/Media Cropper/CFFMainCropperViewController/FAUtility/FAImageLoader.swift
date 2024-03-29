//
//  FAImageLoader.swift
//  FAImageCropper
//
//  Created by Fahid Attique on 12/02/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import UIKit
import Photos

typealias Success = (_ photos:[PHAsset])->Void

public class FAImageLoader: NSObject {
    
    private var assets = [PHAsset]()
    private var success:Success? = nil
    
    func loadPhotos(success:Success!){
        self.success = success
        loadAllPhotos()
    }
    
    public func loadAllPhotos() {
        
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        fetchResult.enumerateObjects({ (object, index, stop) -> Void in
            self.assets.append(object)
            if self.assets.count == fetchResult.count{ self.success!(self.assets) }
        })
    }
    
    public static func imageFrom(asset:PHAsset, size:CGSize, success:@escaping (_ photo:UIImage)->Void){

        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { (image, attributes) in
            if let unwrappedImage = image{
                success(unwrappedImage)
            }else{
                ErrorDisplayer.showError(errorMsg: "This image cannot be selected".localized) { (_) in}
            }
        })
    }
}
