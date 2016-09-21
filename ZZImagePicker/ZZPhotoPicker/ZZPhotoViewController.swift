//
//  ZZPhotoViewController.swift
//  ZZImagePicker
//
//  Created by duzhe on 16/4/27.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit
import Photos

class ZZImageItem {
    
    var fetchResult:PHFetchResult<PHAsset>
    var title:String?
    
    init(title:String?,fetchResult:PHFetchResult<PHAsset>){
        self.title = title
        self.fetchResult = fetchResult
    }
    
}

class ZZPhotoViewController: UIViewController {
    
    //所有PhotoKit的对象都继承自PHObject 基础类，公用接口只提供一个localIdentifier属性
    //PHAsset代表用户照片库中的单个资源，提供asset的元数据
    //PHAssetCollection 是 PHCollection 的子类
    //PHCollectionList代表一组PHCollection
    //fetchXXX  这些方法不是异步的 返回PHFetchResult对象
    @IBOutlet weak var tableView:UITableView!
    var completeHandler:((_ assets:[PHAsset])->())?
    var items:[ZZImageItem] = []
    var sectionLocalizedTitles:[String] = []
    
    var maxSelected:Int = 9
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let allPhotosOptions = PHFetchOptions()
//        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        let allPhotos = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image,options: allPhotosOptions)
        
        let smartOptions = PHFetchOptions()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.albumRegular, options: smartOptions)
        self.convertCollection(smartAlbums as! PHFetchResult<AnyObject>)
     
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        self.convertCollection(topLevelUserCollections as! PHFetchResult<AnyObject>)
        
        self.items.sort { (item1, item2) -> Bool in
            return item1.fetchResult.count > item2.fetchResult.count
        }
        // 注册监听
        PHPhotoLibrary.shared().register(self)
    }
    
    fileprivate func convertCollection(_ collection:PHFetchResult<AnyObject>){
        
        for i in 0..<collection.count{
            let resultsOptions = PHFetchOptions()
            resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            resultsOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            guard let c = collection[i] as? PHAssetCollection else { return }
            let assetsFetchResult = PHAsset.fetchAssets(in: c , options: resultsOptions)
            if assetsFetchResult.count > 0{
                items.append(ZZImageItem(title: c.localizedTitle, fetchResult: assetsFetchResult))
            }
        }
        
    }
    
    
    deinit{
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    var firstLoad = false
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "照片库"
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 55
        let leftBarItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action:#selector(ZZPhotoViewController.cancel) )
        self.navigationItem.rightBarButtonItem = leftBarItem
    }
    
    func  cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstLoad{
            return
        }else{
            firstLoad = true
        }
        if let zzAssetGridVc = self.storyboard?.instantiateViewController(withIdentifier: "zzAssetGridVC") as? ZZAssetGridViewController{
            zzAssetGridVc.assetsFetchResults = self.items.first?.fetchResult
            zzAssetGridVc.completeHandler = completeHandler
            zzAssetGridVc.maxSelected = self.maxSelected
            self.navigationController?.pushViewController(zzAssetGridVc, animated: false)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showAllPhotos"{
            
            guard let assetGridViewController = segue.destination as? ZZAssetGridViewController, let cell = sender as? ZZPhotoCell else{
                return
            }
            assetGridViewController.completeHandler = completeHandler
            assetGridViewController.title = cell.titleLabel.text
            assetGridViewController.maxSelected = self.maxSelected
            guard  let indexPath = self.tableView.indexPath(for: cell) else { return }
            let fetchResult = self.items[(indexPath as NSIndexPath).row].fetchResult
            
            if let _ = fetchResult.firstObject{
                assetGridViewController.assetsFetchResults = fetchResult
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
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.global().async {
            var updatedSectionFetchResults = self.items
            var reloadRequired = false
            
            for i in 0..<self.items.count{
                if let changeDetails = changeInstance.changeDetails(for: self.items[i].fetchResult as! PHFetchResult<PHObject>){
                    // 有改变则替换
                    updatedSectionFetchResults[i].fetchResult = changeDetails.fetchResultAfterChanges as! PHFetchResult<PHAsset>
                    reloadRequired = true
                }
            }
            
            if reloadRequired {
                DispatchQueue.main.async(execute: {
                    self.items = updatedSectionFetchResults
                    self.tableView.reloadData()
                })
            }
            
        }
    }
}

//MARK: - UITableViewDelegate,UITableViewDataSource
extension ZZPhotoViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZZPhotoCell
        let item = self.items[(indexPath as NSIndexPath).row]
        cell.titleLabel.text = "\(item.title ?? "") "
        cell.countLabel.text = "（\(item.fetchResult.count)）"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}



