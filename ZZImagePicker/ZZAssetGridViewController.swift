//
//  ZZAssetGridViewController.swift
//  ZZImagePicker
//
//  Created by duzhe on 16/4/27.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit
import Photos

class ZZAssetGridViewController: UIViewController {
    
    @IBOutlet weak var collectionView:UICollectionView!
    
    var assetsFetchResults:PHFetchResult!
    var imageManager:PHCachingImageManager!
    var assetGridThumbnailSize:CGSize!
    var previousPreheatRect:CGRect!
    var maxSelected:Int = 9
    var completeHandler:((assets:[PHAsset])->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if assetsFetchResults == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            assetsFetchResults = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image,options: allPhotosOptions)
        }
        
        self.imageManager = PHCachingImageManager()
        self.resetCachedAssets()
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor.whiteColor()
        let layout = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
        layout.itemSize = CGSize(width: UIScreen.mainScreen().bounds.size.width/3-1,height: UIScreen.mainScreen().bounds.size.width/3-1)
        self.collectionView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let scale = UIScreen.mainScreen().scale
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        assetGridThumbnailSize = CGSizeMake( cellSize.width*scale , cellSize.height*scale)
    }
    
    var didLoad = false
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        didLoad = true
    }
    
    deinit{
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    func resetCachedAssets(){
        self.imageManager.stopCachingImagesForAllAssets()
        self.previousPreheatRect = CGRectZero
    }
    
    @IBAction func complete(sender: AnyObject) {
        var assets:[PHAsset] = []
        if let indexPaths = self.collectionView.indexPathsForSelectedItems(){
            for indexPath in indexPaths{
                assets.append(assetsFetchResults[indexPath.row] as! PHAsset)
            }
        }
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: { 
            self.completeHandler?(assets:assets)
        })
    }
 
    func selectedCount() -> Int {
        return self.collectionView.indexPathsForSelectedItems()?.count ?? 0
    }
}


extension ZZAssetGridViewController:PHPhotoLibraryChangeObserver{
    
    func photoLibraryDidChange(changeInstance: PHChange) {
        
        guard let collectionChanges = changeInstance.changeDetailsForFetchResult(self.assetsFetchResults) else { return }
        dispatch_async(dispatch_get_main_queue()) { 
            self.assetsFetchResults = collectionChanges.fetchResultAfterChanges
            let collectionView = self.collectionView
            if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves{
                collectionView.reloadData()
            }else{
                collectionView.performBatchUpdates({
                        if let removedIndexes = collectionChanges.removedIndexes where removedIndexes.count > 0{
                            collectionView.deleteItemsAtIndexPaths(removedIndexes.zz_indexPathsFromIndexesWithSection(0))
                        }
                        if let insertedIndexes = collectionChanges.insertedIndexes where insertedIndexes.count > 0{
                            collectionView.insertItemsAtIndexPaths(insertedIndexes.zz_indexPathsFromIndexesWithSection(0))
                        }
                        
                        if let changedIndexes = collectionChanges.changedIndexes where changedIndexes.count > 0{
                            collectionView.reloadItemsAtIndexPaths(changedIndexes.zz_indexPathsFromIndexesWithSection(0))
                        }
                    
                    }, completion: nil)
            }
            self.resetCachedAssets()
        }
        
    }
    
}

extension ZZAssetGridViewController:UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetsFetchResults.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ZZGridViewCell
        let asset = self.assetsFetchResults[indexPath.row] as! PHAsset
        
        self.imageManager.requestImageForAsset(asset, targetSize: assetGridThumbnailSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, nfo) in
            cell.imageView.image = image
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ZZGridViewCell{
            cell.showAnim()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ZZGridViewCell{
//            print(self.selectedCount())
            if self.selectedCount() > self.maxSelected {
                collectionView.deselectItemAtIndexPath(indexPath, animated: false)
            }else{
                cell.showAnim()
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.updateCachedAssets()
    }
    
    func updateCachedAssets()  {
        
        let isViewVisible = self.isViewLoaded() && didLoad
        
        if !isViewVisible{
            // 没有加载完成前 取的数据有误
            return
        }
        
        var preheatRect = self.collectionView.bounds
        preheatRect = CGRectInset(preheatRect, 0, -0.5*CGRectGetHeight(preheatRect))
        
        let delta = abs(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect))
        if delta > CGRectGetHeight(self.collectionView.bounds) / 3.0{
            
            var addedIndexPaths = [NSIndexPath]()
            var removedIndexPaths = [NSIndexPath]()
            self.computeDifferenceBetweenRect(self.previousPreheatRect, andRect: preheatRect, removedHandler: { (removedRect) in
                    let indexPaths = self.collectionView.zz_indexPathsForElementsInRect(removedRect)
                    removedIndexPaths = removedIndexPaths.filter({ (indexPath) -> Bool in
                        return !indexPaths.contains(indexPath)
                    })
                }, addedHandler: { (addedRect) in
                    let indexPaths = self.collectionView.zz_indexPathsForElementsInRect(addedRect)
                    indexPaths.forEach({ (indexPath) in
                        addedIndexPaths.append(indexPath)
                    })
            })
            
            let assetsToStartCaching = self.assetsAtIndexPaths(addedIndexPaths)
            let assetsToStopCaching = self.assetsAtIndexPaths(removedIndexPaths)
            
            self.imageManager.startCachingImagesForAssets(assetsToStartCaching, targetSize: assetGridThumbnailSize, contentMode: PHImageContentMode.AspectFill, options: nil)
            self.imageManager.stopCachingImagesForAssets(assetsToStopCaching, targetSize: assetGridThumbnailSize, contentMode: PHImageContentMode.AspectFill, options: nil)
            
            self.previousPreheatRect = preheatRect
        }
    }
    
    func computeDifferenceBetweenRect(oldRect:CGRect, andRect newRect:CGRect,removedHandler:((removedRect:CGRect)->())?,addedHandler:((addedRect:CGRect)->())?) {
        
        if CGRectIntersectsRect(newRect, oldRect){ //判断两个矩形是否相交
            
            let oldMaxY = CGRectGetMaxY(oldRect)
            let oldMinY = CGRectGetMinY(oldRect)
            let newMaxY = CGRectGetMaxY(newRect)
            let newMinY = CGRectGetMinY(newRect)
            if newMaxY>oldMaxY{
                let rectToAdd = CGRectMake(newRect.origin.x, oldMaxY , newRect.size.width, newMaxY-oldMaxY)
                addedHandler?(addedRect: rectToAdd)
            }
            
            if oldMinY > newMinY {
                let rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY))
                addedHandler?(addedRect:rectToAdd)
            }
            
            if newMaxY < oldMaxY {
                let rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY))
                removedHandler?(removedRect:rectToRemove);
            }
            
            if oldMinY < newMinY {
                let rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY))
                removedHandler?(removedRect:rectToRemove)
            }
            
        }else{
            addedHandler?(addedRect: newRect);
            removedHandler?(removedRect:oldRect);
        }
    }
    
    func assetsAtIndexPaths(indexPaths:[NSIndexPath]) -> [PHAsset] {
        var assets = [PHAsset]()
        for indexPath in indexPaths{
            let asset = self.assetsFetchResults[indexPath.row]
            assets.append(asset as! PHAsset)
        }
        return assets
    }
    
}



