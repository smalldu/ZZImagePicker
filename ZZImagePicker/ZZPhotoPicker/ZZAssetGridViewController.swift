//
//  ZZAssetGridViewController.swift
//  ZZImagePicker
//
//  Created by duzhe on 16/4/27.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit
import Photos

let zz_sw:CGFloat = UIScreen.mainScreen().bounds.width
let zz_sh:CGFloat = UIScreen.mainScreen().bounds.height

class ZZAssetGridViewController: UIViewController {
    
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var toolBar:UIToolbar!

    @IBOutlet weak var preview: UIBarButtonItem!
    @IBOutlet weak var sendItem: UIBarButtonItem!
    
    /// 后去到的结果 存放的PHAsset
    var assetsFetchResults:PHFetchResult!
    
    /// 带缓存的图片管理对象
    var imageManager:PHCachingImageManager!
    
    /// 小图大小
    var assetGridThumbnailSize:CGSize!
    
    /// 预缓存Rect
    var previousPreheatRect:CGRect!
    
    /// 最多可以选择的个数
    var maxSelected:Int = 9
    
    /// 点击完成时的回调
    var completeHandler:((assets:[PHAsset])->())?
    
    lazy var selectedLayer:ZZImageSelectedLabel = {
        let tmpLayer = ZZImageSelectedLabel(toolBar:self.toolBar)
        return tmpLayer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if assetsFetchResults == nil {
            // 如果没有传入值 则获取所有资源
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
            assetsFetchResults = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image,options: allPhotosOptions)
        }
        
       
        
        // 初始化和重置缓存
        self.imageManager = PHCachingImageManager()
        self.resetCachedAssets()
        // 监听资源改变 （可以不要 如果不用删除和修改图片的话）
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        // 获取流布局对象并设置itemSize 设置允许多选
        let layout = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
        layout.itemSize = CGSize(width: UIScreen.mainScreen().bounds.size.width/3-1,height: UIScreen.mainScreen().bounds.size.width/3-1)
        self.collectionView.allowsMultipleSelection = true
        
        let rightBarItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ZZAssetGridViewController.cancel))
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        self.preview.action = #selector(ZZAssetGridViewController.previewImage)
        self.sendItem.action = #selector(ZZAssetGridViewController.finishSelect)
        
        self.disableItems()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 计算出小图大小 （ 为targetSize做准备 ）
        let scale = UIScreen.mainScreen().scale
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        assetGridThumbnailSize = CGSizeMake( cellSize.width*scale , cellSize.height*scale)
    }
    
    // 是否页面加载完毕 ， 加载完毕后再做缓存 否则数值可能有误
    var didLoad = false
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        didLoad = true
    }
    
    private func enableItems(){
        preview.enabled = true
        sendItem.enabled = true
    }
    
    private func disableItems(){
        preview.enabled = false
        sendItem.enabled = false
    }
    deinit{
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    /**
    重置缓存
     */
    func resetCachedAssets(){
        self.imageManager.stopCachingImagesForAllAssets()
        self.previousPreheatRect = CGRectZero
    }
    
    /**
     取消
     */
    func cancel() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     获取已选择个数
     
     - returns: count
     */
    func selectedCount() -> Int {
        return self.collectionView.indexPathsForSelectedItems()?.count ?? 0
    }
}

extension ZZAssetGridViewController{


    // TODO - 预览
    func previewImage() {
        // 预览
        var assets:[PHAsset] = []
        if let indexPaths = self.collectionView.indexPathsForSelectedItems(){
            for indexPath in indexPaths{
                assets.append(assetsFetchResults[indexPath.row] as! PHAsset)
            }
        }
        
        let vc = ZZAssetPreviewVC(assets:assets)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    /**
     点击完成，取出已选择的图片资源 调用闭包
     */
    func finishSelect(){
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
    
}

//MARK: - PHPhotoLibraryChangeObserver 图片删除或者修改开始后触发的代理 如果没有删除或者修改操作可以删掉这段和前面注册的代码
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

//MARK: - UICollectionViewDataSource,UICollectionViewDelegate
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
            let sc = self.selectedCount()
            selectedLayer.num = sc
            if sc == 0{
                self.disableItems()
            }
            cell.showAnim()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ZZGridViewCell{
            let sc = self.selectedCount()
            if sc > self.maxSelected {
                // 如果选择的个数大于最大选择数 设置为不选中状态
                collectionView.deselectItemAtIndexPath(indexPath, animated: false)
                selectedLayer.tooMoreAnimate()
            }else{
                selectedLayer.num = sc
                if sc > 0 && !self.sendItem.enabled{
                    self.enableItems()
                }
                cell.showAnim()
            }
        }
    }
    
    /**
     在滚动中不断更新缓存
     */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.updateCachedAssets()
    }
    
    /**
     更新缓存资源
     */
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



