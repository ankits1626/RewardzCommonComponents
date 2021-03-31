//
//  CFFMediaBrowserViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 27/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

public class CFFMediaBrowserViewController: UIViewController {
    @IBOutlet private weak var mediaCollectionView : UICollectionView?
    @IBOutlet private weak var downloadButton : UIButton?
    
    private let mediaList : [MediaItemProtocol]
    private let mediaFetcher : CFFMediaCoordinatorProtocol
    private let selectedIndex : Int
    
    public  init(mediaList : [MediaItemProtocol], mediaFetcher : CFFMediaCoordinatorProtocol, selectedIndex : Int) {
        self.mediaList = mediaList
        self.mediaFetcher = mediaFetcher
        self.selectedIndex = selectedIndex
        super.init(nibName: "CFFMediaBrowserViewController", bundle: Bundle(for: CFFMediaBrowserViewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        setupCollectionView()
    }
    
    private func setupCollectionView(){
        mediaCollectionView?.alpha = 0
        mediaCollectionView?.register(
            UINib(nibName: "MediaItemCollectionViewCell", bundle: Bundle(for: MediaItemCollectionViewCell.self)),
            forCellWithReuseIdentifier: "MediaItemCollectionViewCell"
        )
        mediaCollectionView?.dataSource = self
        mediaCollectionView?.delegate = self
        mediaCollectionView?.reloadData()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mediaCollectionView?.scrollToItem(
            at: IndexPath(item: selectedIndex, section: 0),
            at: UICollectionView.ScrollPosition.centeredHorizontally,
            animated: false
        )
        mediaCollectionView?.alpha = 1
    }
    
    @IBAction private func closeBowser(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func downloadMedia(){
        if let centralIndexpath = mediaCollectionView?.centerCellIndexPath,
            let cell = mediaCollectionView?.cellForItem(at: centralIndexpath) as? MediaItemCollectionViewCell,
            let image = cell.mediaCoverImageView?.image{
            downloadButton?.isHidden = true
            PhotosPermissionChecker().checkPermissions {[weak self] in
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self?.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("download complete")
        if let unwrappedError = error{
            ErrorDisplayer.showError(errorMsg: unwrappedError.localizedDescription) { (_) in
            }
        }else{
            ErrorDisplayer.showError(errorMsg: "Image downloaded successfully.") { (_) in
            }
        }
        downloadButton?.isHidden = false
    }
}

extension CFFMediaBrowserViewController : UICollectionViewDataSource, UICollectionViewDelegate{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "MediaItemCollectionViewCell",
        for: indexPath) as! MediaItemCollectionViewCell
        let mediaItemUrl = mediaList[indexPath.row].getCoverImageUrl()
        mediaFetcher.fetchImageAndLoad(cell.mediaCoverImageView, imageEndPoint: mediaItemUrl ?? "")
        cell.mediaCoverImageView?.curvedCornerControl()
        cell.mediaCoverImageView?.contentMode = .scaleAspectFit
        let mediaType = mediaList[indexPath.row].getMediaType()
        if mediaType == .Video{
             cell.playButton?.isHidden = false
        }else{
            cell.playButton?.isHidden = true
        }
        return cell
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        mediaCollectionView?.alpha = 1
    }
}

extension CFFMediaBrowserViewController : UICollectionViewDelegateFlowLayout{
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.width)
    }
}
