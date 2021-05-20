/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Collection view cell for displaying an asset.
*/

import UIKit

class GridViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var selectedIndicatorView: UIView!
    @IBOutlet var selectedIndicatorImageView: UIImageView!
    @IBOutlet var playButton: UIButton!

    var representedAssetIdentifier: String!

    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImage = nil
        selectedIndicatorView.isHidden = true
        //selectedIndicatorImageView.image = nil
    }
}
