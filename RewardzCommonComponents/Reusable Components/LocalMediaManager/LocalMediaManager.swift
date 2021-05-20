//
//  LocalMediaManager.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import Photos

public class LocalMediaManager {
    fileprivate let imageManager = PHCachingImageManager()
    
    public init(){}
    
    public func fetchImageForAsset(asset: PHAsset, size: CGSize, completion: @escaping((_ assetIdentidfier: String, _ fetchedImage : UIImage?)-> Void)) {
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            completion(asset.localIdentifier, image)
        })
    }
}
