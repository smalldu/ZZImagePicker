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
        self.view.backgroundColor = UIColor.black
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = self.view.bounds.size
        layout.scrollDirection = .horizontal
        self.automaticallyAdjustsScrollViewInsets = false
        // automaticallyAdjustsScrollViewInsets这个属性默认将controller上所有的scrollView都向下偏移64，由于笔者被其所坑，找了三天bug才找出它来，所以一定要慎用此属性。
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        //        collectionView.frame.origin.y =
        self.view.addSubview(collectionView)
        //        collectionView.frame = self.view.bounds
        collectionView.backgroundColor = UIColor.black
        self.collectionView.register(ZZPhotoPreviewCell.self, forCellWithReuseIdentifier: "ZZPhotoPreviewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.isPagingEnabled = true
        // Do any additional setup after loading the view.
    }
    fileprivate var context = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // 计算出小图大小 （ 为targetSize做准备 ）
        let scale = UIScreen.main.scale
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        assetGridThumbnailSize = CGSize(width: cellSize.width*scale , height: cellSize.height*scale)
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.none)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



extension ZZAssetPreviewVC:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ZZPhotoPreviewCell", for:  indexPath) as! ZZPhotoPreviewCell
        let asset = self.assets[(indexPath as NSIndexPath).row]
        self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize, contentMode: PHImageContentMode.aspectFill, options: nil) { (image, nfo) in
            cell.imageView.image = image
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? ZZPhotoPreviewCell{
            cell.calSize()
        }
    }
    
}


