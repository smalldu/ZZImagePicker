//
//  ZZAssetPreviewVCViewController.swift
//  ZZImagePicker
//  预览
//  Created by duzhe on 16/5/3.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit
import Photos

class ZZAssetPreviewVC: UIViewController {

    
    var assets:[PHAsset]
    var collectionView:UICollectionView!
    
    /// 带缓存的图片管理对象
    var imageManager:PHCachingImageManager
    var assetGridThumbnailSize:CGSize!
    
    init(assets:[PHAsset]){
        self.assets = assets
        self.imageManager = PHCachingImageManager()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = self.view.bounds.size
        layout.scrollDirection = .Horizontal
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.frame.origin.y = 64
        self.view.addSubview(collectionView)
        collectionView.frame = self.view.bounds
        collectionView.backgroundColor = UIColor.blackColor()
        self.collectionView.registerClass(ZZPhotoPreviewCell.self, forCellWithReuseIdentifier: String(ZZPhotoPreviewCell))
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.pagingEnabled = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // 计算出小图大小 （ 为targetSize做准备 ）
        let scale = UIScreen.mainScreen().scale
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        assetGridThumbnailSize = CGSizeMake(cellSize.width*scale , cellSize.height*scale)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



extension ZZAssetPreviewVC:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(ZZPhotoPreviewCell), forIndexPath:  indexPath) as! ZZPhotoPreviewCell
        let asset = self.assets[indexPath.row]
        self.imageManager.requestImageForAsset(asset, targetSize: assetGridThumbnailSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, nfo) in
            cell.imageView.image = image
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets.count
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = cell as? ZZPhotoPreviewCell{
            cell.calSize()
        }
    }
    
}


