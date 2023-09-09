/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Collection view cell for displaying an asset.
*/

import UIKit

public class GridViewCell: UICollectionViewCell {

    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var selectedIndicatorView: UIView!
    @IBOutlet public var selectedIndicatorImageView: UIImageView!
    @IBOutlet public var playButton: UIButton!

    public var representedAssetIdentifier: String!

    public var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    

    public override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImage = nil
        selectedIndicatorView.isHidden = true
        //selectedIndicatorImageView.image = nil
    }
}
