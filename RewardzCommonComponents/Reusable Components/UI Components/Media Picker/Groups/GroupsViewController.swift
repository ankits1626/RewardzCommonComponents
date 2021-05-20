//
//  GroupsViewController.swift
//  Cerrapoints SG
//
//  Created by Rewardz on 25/11/17.
//  Copyright © 2017 Rewradz Private Limited. All rights reserved.
//

import UIKit
import Photos

class GroupsViewController: UIViewController {
    enum Section: Int {
        case allPhotos = 0
        case smartAlbums
        static let count = 2
    }
    
    enum CellIdentifier: String {
        case allPhotos, collection
    }
    
    var allPhotos: PHFetchResult<PHAsset>!
    var smartAlbums: PHFetchResult<PHAssetCollection>!
    var userCollections: PHFetchResult<PHCollection>!
    let sectionLocalizedTitles = ["", NSLocalizedString("Smart Albums", comment: "")]
    @IBOutlet var groupsTableView : UITableView?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        groupsTableView?.register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: "Cell")
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        PHPhotoLibrary.shared().register(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: PHPhotoLibraryChangeObserver
extension GroupsViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Check each of the three top-level fetches for changes.
            
            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
                // Update the cached fetch result.
                allPhotos = changeDetails.fetchResultAfterChanges
                // (The table row for this one doesn't need updating, it always says "All Photos".)
            }
            
            // Update the cached fetch results, and reload the table sections to match.
            if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
                smartAlbums = changeDetails.fetchResultAfterChanges
                groupsTableView?.reloadSections(IndexSet(integer: Section.smartAlbums.rawValue), with: .automatic)
            }
        }
    }
}

extension GroupsViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .allPhotos: return 1
        case .smartAlbums: return smartAlbums.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! GroupCell
        switch Section(rawValue: indexPath.section)! {
        case .allPhotos:
            cell.titleText!.text = NSLocalizedString("All Photos", comment: "")
            return cell
            
        case .smartAlbums:
            let collection = smartAlbums.object(at: indexPath.row)
            cell.titleText!.text = collection.localizedTitle
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionLocalizedTitles[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let assetGridVC = AssetGridViewController(nibName: "AssetGridViewController", bundle: nil)
        self.navigationController?.pushViewController(assetGridVC, animated: true)
    }
}

