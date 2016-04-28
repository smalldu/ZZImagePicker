//
//  ZZPhotoViewController.swift
//  ZZImagePicker
//
//  Created by duzhe on 16/4/27.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit
import Photos

class ZZPhotoViewController: UIViewController {
    
    //所有PhotoKit的对象都继承自PHObject 基础类，公用接口只提供一个localIdentifier属性
    //PHAsset代表用户照片库中的单个资源，提供asset的元数据
    //PHAssetCollection 是 PHCollection 的子类
    //PHCollectionList代表一组PHCollection
    //fetchXXX  这些方法不是异步的 返回PHFetchResult对象
    @IBOutlet weak var tableView:UITableView!
    var completeHandler:((assets:[PHAsset])->())?
    var sectionFetchResults:[PHFetchResult] = []
    var sectionLocalizedTitles:[String] = []
    
    var maxSelected:Int = 9
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let allPhotos = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image,options: allPhotosOptions)
        
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.AlbumRegular, options: nil)
        
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
        
        sectionFetchResults = [allPhotos,smartAlbums,topLevelUserCollections]
        sectionLocalizedTitles = ["","智能相册","专辑"]
        
        // 注册监听
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    
    deinit{
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    var firstLoad = false
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "照片库"
        
        let leftBarItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action:#selector(ZZPhotoViewController.cancel) )
        self.navigationItem.rightBarButtonItem = leftBarItem
    }
    
    func  cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if firstLoad{
            return
        }else{
            firstLoad = true
        }
        if let zzAssetGridVc = self.storyboard?.instantiateViewControllerWithIdentifier("zzAssetGridVC") as? ZZAssetGridViewController{
            zzAssetGridVc.assetsFetchResults = sectionFetchResults.first
            zzAssetGridVc.completeHandler = completeHandler
            zzAssetGridVc.maxSelected = self.maxSelected
            self.navigationController?.pushViewController(zzAssetGridVc, animated: false)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showAllPhotos"{
            
            guard let assetGridViewController = segue.destinationViewController as? ZZAssetGridViewController, cell = sender as? UITableViewCell else{
                return
            }
            assetGridViewController.completeHandler = completeHandler
            assetGridViewController.title = cell.textLabel?.text
            assetGridViewController.maxSelected = self.maxSelected
            guard  let indexPath = self.tableView.indexPathForCell(cell) else { return }
            let fetchResult = self.sectionFetchResults[indexPath.section]
            
            if let x = fetchResult.firstObject where x is PHAsset{
                
                assetGridViewController.assetsFetchResults = fetchResult
                
            }else if let x = fetchResult.firstObject where x is PHAssetCollection{
                
                let collection = fetchResult[indexPath.row] as! PHAssetCollection
                let assetsFetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
                assetGridViewController.assetsFetchResults = assetsFetchResult
                
            }else{
                return
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

//MARK: - PHPhotoLibraryChangeObserver
extension ZZPhotoViewController:PHPhotoLibraryChangeObserver{
    //PHChange提供了changeDetailsForObject(…)和changDetailsForFetchResult(...)方法能够通过传入需要观察跟踪的PHObject或PHFetchResult对象来跟踪变化。
    func photoLibraryDidChange(changeInstance: PHChange) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            var updatedSectionFetchResults = self.sectionFetchResults
            var reloadRequired = false
            
            for i in 0..<self.sectionFetchResults.count{
                if let changeDetails = changeInstance.changeDetailsForFetchResult(self.sectionFetchResults[i]){
                    // 有改变则替换
                    updatedSectionFetchResults[i] = changeDetails.fetchResultAfterChanges
                    reloadRequired = true
                }
            }
            
            if reloadRequired {
                dispatch_async(dispatch_get_main_queue(), {
                    self.sectionFetchResults = updatedSectionFetchResults
                    self.tableView.reloadData()
                })
            }
            
        }
    }
}

//MARK: - UITableViewDelegate,UITableViewDataSource
extension ZZPhotoViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionFetchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let fetchResult = self.sectionFetchResults[indexPath.section]
        if indexPath.section == 0{
            cell.textLabel?.text = "所有照片 (\(fetchResult.count))"
        }else{
            let collection:PHAssetCollection = fetchResult[indexPath.row] as! PHAssetCollection
            let assetsFetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
            cell.textLabel?.text = "\(collection.localizedTitle!) (\(assetsFetchResult.count))"
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        return self.sectionFetchResults[section].count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionLocalizedTitles[section]
    }
    
}



