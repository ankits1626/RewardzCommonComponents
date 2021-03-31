//
//  CFFMediaViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 03/07/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class CFFImageCropperViewController: UIViewController {
    @IBOutlet private weak var selectedPhotosCollectionView : UICollectionView?
    @IBOutlet private var proceedButton : UIButton!
    @IBOutlet private var mainCropperContainer : UIView!
    @IBOutlet private var titleLabel : UILabel!
    
    var selectedAssets : [LocalSelectedMediaItem] = [LocalSelectedMediaItem]()
    weak var localMediaManager : LocalMediaManager?
    var assetSelectionCompletion : ((_ assets : [LocalSelectedMediaItem]?) -> Void)?
    private var mainCropper : CFFMainCropperViewController!
    weak var themeManager: CFFThemeManagerProtocol?
    private var currentlySelectedIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addMainCropper()
        loadImage(index: 0)
    }
    
    private func setup(){
        configureTitleLabel()
        setupCollectionView()
        setupProceedButton()
    }
    
    private func configureTitleLabel(){
        if let unwrappedThemeManager = themeManager{
            titleLabel.font = unwrappedThemeManager.getHeaderFont()
        }
    }
    
    private func addMainCropper(){
        mainCropper = CFFMainCropperViewController(nibName: "CFFMainCropperViewController", bundle: Bundle(for: CFFMainCropperViewController.self))
        mainCropper.cropperDelegate = self
        mainCropper.themeManager = themeManager
        mainCropper.view.frame = mainCropperContainer.bounds
        addChild(mainCropper)
        mainCropperContainer.addSubview(mainCropper.view)
        NSLayoutConstraint.activate([
        mainCropper.view.leadingAnchor.constraint(equalTo: mainCropperContainer.leadingAnchor),
        mainCropper.view.trailingAnchor.constraint(equalTo: mainCropperContainer.trailingAnchor),
        mainCropper.view.topAnchor.constraint(equalTo: mainCropperContainer.topAnchor),
        mainCropper.view.bottomAnchor.constraint(equalTo: mainCropperContainer.bottomAnchor)
        ])
        mainCropper.didMove(toParent: self)
    }
    
    private func setupCollectionView(){
        selectedPhotosCollectionView?.register(
            UINib(nibName: "MediaItemCollectionViewCell", bundle: Bundle(for: MediaItemCollectionViewCell.self)),
            forCellWithReuseIdentifier: "MediaItemCollectionViewCell"
        )
        selectedPhotosCollectionView?.dataSource = self
        selectedPhotosCollectionView?.delegate = self
        selectedPhotosCollectionView?.reloadData()
    }
    
    private func setupProceedButton(){
        proceedButton.backgroundColor = themeManager?.getControlActiveColor() ?? .black
        proceedButton.curvedCornerControl()
        proceedButton.setTitleColor(.white, for: .normal)
        proceedButton.titleLabel?.font = .Button
    }
    
    @IBAction private func backButtonTapped(){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func doneButtonTapped(){
        dismiss(animated: true) {
            if let unwrappedCompletion = self.assetSelectionCompletion{
                unwrappedCompletion(self.selectedAssets)
            }
        }
    }
}

extension CFFImageCropperViewController  : UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "MediaItemCollectionViewCell",
        for: indexPath) as! MediaItemCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let mediaItemCell =  cell as? MediaItemCollectionViewCell{
            mediaItemCell.removeButton?.isHidden = false
            mediaItemCell.editTransparentView?.isHidden = true
            mediaItemCell.curvedCornerControl()
            mediaItemCell.removeButton?.isHidden = true
            mediaItemCell.mediaCoverImageView?.curvedCornerControl()
            mediaItemCell.mediaCoverImageView?.contentMode = .scaleAspectFit
            if indexPath.row == currentlySelectedIndex{
                mediaItemCell.mediaCoverImageView?.curvedBorderedControl(borderColor: themeManager?.getControlActiveColor() ?? .black, borderWidth: 2.0)
            }else{
                mediaItemCell.mediaCoverImageView?.curvedBorderedControl()
            }
            loadImage(index: indexPath.row, cell: mediaItemCell, imageView: mediaItemCell.mediaCoverImageView)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let deselectedIndex = currentlySelectedIndex
        currentlySelectedIndex = indexPath.item
        loadImage(index: indexPath.row)
        collectionView.reloadItems(at: [
            IndexPath(item: deselectedIndex, section: 0),
            IndexPath(item: currentlySelectedIndex, section: 0)
        ])
    }
    
    private func loadImage(index :Int){
        mainCropper.loadImage(mediaItem: selectedAssets[index])
    }
    
    private func loadImage(index :Int, cell: MediaItemCollectionViewCell, imageView: UIImageView?){
        if let croppedImage = selectedAssets[index].croppedImage{
            imageView?.image = croppedImage
        }else{
            if let asset = selectedAssets[index].asset{
                localMediaManager?.fetchImageForAsset(asset: asset, size: (cell.bounds.size), completion: { (_, fetchedImage) in
                   imageView?.image = fetchedImage
                })
            }
        }
    }
}

extension CFFImageCropperViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 82, height: 76)
    }
}

extension CFFImageCropperViewController : CFFMainCropperDelegate{
    func finishedCropping(_ selectedMediaItem: LocalSelectedMediaItem) {
        if let index = selectedAssets.indexes(of: selectedMediaItem).first{
            selectedAssets[index] = selectedMediaItem
            selectedPhotosCollectionView?.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}


