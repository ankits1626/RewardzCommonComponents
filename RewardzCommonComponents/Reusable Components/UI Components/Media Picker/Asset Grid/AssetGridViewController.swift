//
//  AssetGridViewController.swift
//  Cerrapoints SG
//
//  Created by Rewardz on 25/11/17.
//  Copyright © 2017 Rewradz Private Limited. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

public struct LocalSelectedMediaItem : Equatable {
    public static func ==(_ lhs: LocalSelectedMediaItem, _ rhs: LocalSelectedMediaItem) -> Bool {
      return lhs.identifier == rhs.identifier
    }
    public var identifier : String
    public var asset: PHAsset?
    public var mediaType : PHAssetMediaType
    public var croppedImage : UIImage?{
        didSet{
            print("heere")
        }
    }
}

public class PhotosPermissionChecker {
    public init(){}
    
    public func checkPermissions(_ postPermissionsGrantedCompletionBlock :@escaping (() -> Void)) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            postPermissionsGrantedCompletionBlock()
        case .notDetermined:
            askForPermission {
                postPermissionsGrantedCompletionBlock()
            }
        case .restricted:
            fallthrough
        case .denied:
            fallthrough
        case .limited:
            fallthrough
        @unknown default:
            showUserAlertToProvideAccessToPhotos()
        }
    }
    
    private func askForPermission(_ completion: @escaping (() -> Void)){
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                self.checkPermissions {
                    completion()
                }
            }
        }
    }
    
    private func showUserAlertToProvideAccessToPhotos(){
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            let alertVC = UIAlertController(
                title: nil,
                message: "Unable to access photos. Please go to settings and enable photo access to use this service.",
                preferredStyle: .alert)
            
            let leftButtonAction = UIAlertAction(title: "Go to settings", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            alertVC.addAction(leftButtonAction)
            
            let okAction = UIAlertAction(
                title: "Cancel",
                style: .cancel) { (_) in
            }
            alertVC.addAction(okAction)
            topController.present(alertVC, animated: true, completion: nil)
        }
    }
}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

public struct MediaPickerPresentationModel {
    var localMediaManager : LocalMediaManager
    var selectedAssets : [LocalSelectedMediaItem]?
    var assetSelectionCompletion : ((_ assets : [LocalSelectedMediaItem]?) -> Void)?
    var maximumItemSelectionAllowed = 10
    weak var presentingViewController : UIViewController?
    weak var themeManager: CFFThemeManagerProtocol?
    
    public init (
        localMediaManager: LocalMediaManager,
        selectedAssets: [LocalSelectedMediaItem]?,
        assetSelectionCompletion:((_ assets : [LocalSelectedMediaItem]?) -> Void)?, maximumItemSelectionAllowed : Int, presentingViewController: UIViewController?, themeManager: CFFThemeManagerProtocol?){
        self.localMediaManager = localMediaManager
        self.selectedAssets = selectedAssets
        self.assetSelectionCompletion = assetSelectionCompletion
        self.maximumItemSelectionAllowed = maximumItemSelectionAllowed
        self.presentingViewController = presentingViewController
        self.themeManager = themeManager
    }
}

public struct CameraPickerPresentationModel {
    var localMediaManager : LocalMediaManager
    var selectedAssets : [LocalSelectedMediaItem]?
    var assetSelectionCompletion : ((_ assets : [LocalSelectedMediaItem]?) -> Void)?
    var maximumItemSelectionAllowed = 10
    weak var presentingViewController : UIViewController?
    weak var themeManager: CFFThemeManagerProtocol?
    var identifier : String
    public var mediaType : PHAssetMediaType
    public var asset: PHAsset?
    
    public init (
        localMediaManager: LocalMediaManager,
        selectedAssets: [LocalSelectedMediaItem]?,
        assetSelectionCompletion:((_ assets : [LocalSelectedMediaItem]?) -> Void)?, maximumItemSelectionAllowed : Int, presentingViewController: UIViewController?, themeManager: CFFThemeManagerProtocol?, _identifier : String, _mediaType : PHAssetMediaType, _asset : PHAsset){
        self.localMediaManager = localMediaManager
        self.selectedAssets = selectedAssets
        self.assetSelectionCompletion = assetSelectionCompletion
        self.maximumItemSelectionAllowed = maximumItemSelectionAllowed
        self.presentingViewController = presentingViewController
        self.themeManager = themeManager
        self.identifier = _identifier
        self.mediaType = _mediaType
        self.asset = _asset
    }
}

public class AssetGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver {
    @IBOutlet weak var navigationColor: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    @IBOutlet weak var addImageBtn: UIButton!
    var assetSelectionCompletion : ((_ assets : [LocalSelectedMediaItem]?) -> Void)?
    @IBOutlet var uploadButton : UIButton!
    @IBOutlet var collectionView: UICollectionView!
    fileprivate var thumbnailSize: CGSize!
    var selectedAssets = [LocalSelectedMediaItem]()
    var localMediaManager : LocalMediaManager!
    var maximumItemSelectionAllowed = 10
    weak var themeManager: CFFThemeManagerProtocol?
    
    public static func presentMediaPickerStack(presentationModel : MediaPickerPresentationModel){
        let assetGridVC = AssetGridViewController(nibName: "AssetGridViewController", bundle: Bundle(for: AssetGridViewController.self))
        assetGridVC.localMediaManager = presentationModel.localMediaManager
        if let unwrappedAssets = presentationModel.selectedAssets{
            assetGridVC.selectedAssets = unwrappedAssets
        }
        assetGridVC.assetSelectionCompletion = presentationModel.assetSelectionCompletion
        assetGridVC.maximumItemSelectionAllowed = presentationModel.maximumItemSelectionAllowed
        let navVC = UINavigationController(rootViewController: assetGridVC)
        navVC.setNavigationBarHidden(true, animated: false)
        navVC.modalPresentationStyle = .fullScreen
        assetGridVC.themeManager = presentationModel.themeManager
        presentationModel.presentingViewController?.present(navVC, animated: true, completion: nil)
    }
    
    public static func presentCameraPickerStack(presentationModel : CameraPickerPresentationModel){
        let assetGridVC = AssetGridViewController(nibName: "AssetGridViewController", bundle: Bundle(for: AssetGridViewController.self))
        assetGridVC.localMediaManager = presentationModel.localMediaManager
        assetGridVC.assetSelectionCompletion = presentationModel.assetSelectionCompletion
        assetGridVC.maximumItemSelectionAllowed = presentationModel.maximumItemSelectionAllowed
        if let assets = presentationModel.selectedAssets {
            for items in assets {
                assetGridVC.selectedAssets.append(LocalSelectedMediaItem(identifier: items.identifier, asset: items.asset, mediaType: items.mediaType))
            }
        }
        assetGridVC.selectedAssets.append(LocalSelectedMediaItem(identifier: presentationModel.identifier, asset: presentationModel.asset, mediaType: presentationModel.mediaType))
        let cropperVc = CFFImageCropperViewController(nibName: "CFFImageCropperViewController", bundle: Bundle(for: CFFImageCropperViewController.self))
        cropperVc.localMediaManager = assetGridVC.localMediaManager
        cropperVc.selectedAssets = assetGridVC.selectedAssets
        cropperVc.assetSelectionCompletion = assetGridVC.assetSelectionCompletion
        cropperVc.themeManager = presentationModel.themeManager
        let navVC = UINavigationController(rootViewController: assetGridVC)
        navVC.setNavigationBarHidden(true, animated: false)
        navVC.modalPresentationStyle = .fullScreen
        assetGridVC.themeManager = presentationModel.themeManager
        presentationModel.presentingViewController?.present(cropperVc, animated: true, completion: nil)
    }
    
    // MARK: UIViewController / Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.shared().register(self)
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            hideAddMoreButton(for: status)
        } else {}
        setupAfterViewDidLoad()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    private func setupAfterViewDidLoad(){
        self.setupCollectionView()
        uploadButton.setTitleColor(.black, for: .normal)
        addImageBtn.setTitle(" ", for: .normal)
        self.navigationColor.image = UIImage(named: "")
        setupUploadButton()
        titleLabel.text = "ADD PHOTOS".localized
        uploadButton.setTitle("SELECT".localized, for: .normal)
        if let unwrappedThemeManager = themeManager{
            titleLabel.font = unwrappedThemeManager.getHeaderFont()
        }
    }
    
    private func setup(){
        checkPermissions {
            self.setupCollectionView()
        }
    }
    
    func hideAddMoreButton(for status: PHAuthorizationStatus) {
        switch status {
        case .limited:
            self.addImageBtn.isHidden = false
        case .notDetermined:
            self.addImageBtn.isHidden = true
        case .restricted:
            self.addImageBtn.isHidden = true
        case .denied:
            self.addImageBtn.isHidden = true
        case .authorized:
            self.addImageBtn.isHidden = true
        @unknown default:
            self.addImageBtn.isHidden = true
        }
    }
    
    private func checkPermissions(_ completion :@escaping (() -> Void)){
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            setupFetchresult()
            completion()
        case .notDetermined:
            askForPermission {
                self.setupFetchresult()
                completion()
            }
        case .limited:
            fallthrough
        case .restricted:
            fallthrough
        case .denied:
            fallthrough
        @unknown default:
            showUserAlertToProvideAccessToPhotos()
        }
    }
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            self.setupFetchresult()
            self.collectionView.reloadData()
        }
    }
    
    private func showUserAlertToProvideAccessToPhotos(){
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            let alertVC = UIAlertController(
                title: nil,
                message: "Access denied, please go to settings and enable photo access to use this service.",
                preferredStyle: .alert)
            
            let leftButtonAction = UIAlertAction(title: "Go to settings", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            alertVC.addAction(leftButtonAction)
            
            let okAction = UIAlertAction(
                title: "Cancel",
                style: .cancel) { (_) in
                    self.dismiss(animated: true, completion: nil)
            }
            alertVC.addAction(okAction)
            topController.present(alertVC, animated: true, completion: nil)
        }
    }
    
    private func askForPermission(_ completion: @escaping (() -> Void)){
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                self.checkPermissions {
                    completion()
                }
            }
        }
    }
    
    private func setupUploadButton(){
        uploadButton.isHidden = selectedAssets.count == 0
        uploadButton.backgroundColor = themeManager?.getControlActiveColor() ?? .black
        uploadButton.curvedCornerControl()
        uploadButton.setTitleColor(.white, for: .normal)
        uploadButton.titleLabel?.font = .Button
    }
    
    private func setupFetchresult(){
        //PHPhotoLibrary.shared().register(self)
        //if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            allPhotosOptions.includeAssetSourceTypes = .typeUserLibrary
            fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: allPhotosOptions)
       // }
    }
    
    private func setupCollectionView(){
        collectionView.register(UINib(nibName: "GridViewCell", bundle: Bundle(for: GridViewCell.self)), forCellWithReuseIdentifier: "GridViewCell")
        collectionView.reloadData()
    }
    
    @IBAction func addImageBtn(_ sender: Any) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadButtonTapped(_ sender: AnyObject) {
        let cropperVc = CFFImageCropperViewController(nibName: "CFFImageCropperViewController", bundle: Bundle(for: CFFImageCropperViewController.self))
        cropperVc.localMediaManager = localMediaManager
        cropperVc.selectedAssets = selectedAssets
        cropperVc.assetSelectionCompletion = assetSelectionCompletion
        cropperVc.themeManager = themeManager
        navigationController?.pushViewController(cropperVc, animated: true)
    }
    
     private func handleSelectedVideos(selectdImages : [AVAsset]){
        print("@@@@@@@@@@@@@@@@@@@@@@@ save videos")
    }
    
    private func handleSelectedImages(selectdImages : [UIImage]){
        print("@@@@@@@@@@@@@@@@@@@@@@@ save images")
        var imageURLs = [URL]()
        for anImage in selectdImages{
            let saveImageResult = self.saveImageToDocumentsDirectory(anImage)
            if let unwrappedURL = saveImageResult.imageURL{
                imageURLs.append(unwrappedURL)
            }
            if let unwrappedError = saveImageResult.error{
                showToast(message: unwrappedError.localizedDescription)
            }
        }
    }
    
    fileprivate func saveImageToDocumentsDirectory(_ sourceImage : UIImage) -> (imageURL:URL?, error:Error?){
        let directoryPath =  NSHomeDirectory().appending("/Documents/feedAttachedPostImages/")
        if !FileManager.default.fileExists(atPath: directoryPath) {
            do {
                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        let filename = String(format: "%@.jpg",randomString(length: 10))
        let filepath = directoryPath.appending(filename)
        let url = NSURL.fileURL(withPath: filepath)
        do {
            try sourceImage.jpegData(compressionQuality: 1.0)?.write(to: url, options: .atomic)
            return (url, nil)
            
        } catch {
            print(error)
            print("file cant not be save at path \(filepath), with error : \(error)");
            return (nil , error)
        }
    }
    
    private func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateItemSize()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateItemSize()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setup()
    }
        
    private func updateItemSize() {
        
        let viewWidth = view.bounds.size.width
        
        let desiredItemWidth: CGFloat = 100
        let columns: CGFloat = max(floor(viewWidth / desiredItemWidth), 4)
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
    }
    
    // MARK: UICollectionView
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult == nil ? 0 : fetchResult.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let asset = fetchResult.object(at: indexPath.item)
        
        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridViewCell",
                                                            for: indexPath) as? GridViewCell
            else { fatalError("unexpected cell in collection view") }
        
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        cell.playButton.isHidden = asset.mediaType != .video
        
        self.localMediaManager.fetchImageForAsset(asset: asset, size: self.thumbnailSize) { (assetIdentifier, fetchedImage) in
            if cell.representedAssetIdentifier == assetIdentifier && fetchedImage != nil {
                cell.thumbnailImage = fetchedImage
            }
        }
        
        cell.selectedIndicatorView.backgroundColor = UIColor(red: 0, green: 82/255.0, blue: 147/255.0, alpha: 0.8)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        uploadButton.isHidden = selectedAssets.count == 0
        let asset = fetchResult.object(at: indexPath.item)
        (cell as! GridViewCell).selectedIndicatorView.isHidden = !selectedAssets.contains(
            LocalSelectedMediaItem(identifier: asset.localIdentifier, mediaType: asset.mediaType))
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toggleSelectionOfItem(indexpath: indexPath)
    }
    
    fileprivate func toggleSelectionOfItem(indexpath : IndexPath){
        let asset = fetchResult.object(at: indexpath.item)
        
        if selectedAssets.contains(LocalSelectedMediaItem(identifier: asset.localIdentifier, mediaType: asset.mediaType)){
            selectedAssets = selectedAssets.filter(){$0 != LocalSelectedMediaItem(identifier: asset.localIdentifier, mediaType: asset.mediaType)}
        }else{
            if selectedAssets.count < maximumItemSelectionAllowed{
                selectedAssets.append(LocalSelectedMediaItem(identifier: asset.localIdentifier, asset: asset, mediaType: asset.mediaType))
            }else{
                let pluralizedImage = maximumItemSelectionAllowed == 1 ? "image" : "images"
                ErrorDisplayer.showError(errorMsg: "Cannot select more than \(maximumItemSelectionAllowed) \(pluralizedImage)".localized) { (_) in
                }
            }
            
        }
        updateSelectionMarkerForItem(indexpath: indexpath)
    }
    
    fileprivate func updateSelectionMarkerForItem(indexpath : IndexPath){
        uploadButton.isHidden = selectedAssets.count == 0
        if let cell = collectionView.cellForItem(at: indexpath) as? GridViewCell{
            let asset = fetchResult.object(at: indexpath.item)
            cell.selectedIndicatorView.isHidden = !selectedAssets.contains(LocalSelectedMediaItem(identifier: asset.localIdentifier, mediaType: asset.mediaType))
        }else{
            print("$$$$$$$$$$$$$$$$$ no cell found")
        }
    }
    
}

