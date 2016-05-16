//
//  UICollectionView+Add.swift
//  ZZImagePicker
//
//  Created by duzhe on 16/4/27.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit
import Photos

extension UICollectionView{
    
    func zz_indexPathsForElementsInRect(rect:CGRect) -> [NSIndexPath] {
        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElementsInRect(rect)
        if let allLayoutAttributes = allLayoutAttributes where  allLayoutAttributes.count == 0 {
            var indexPaths = [NSIndexPath]()
            for attr in allLayoutAttributes{
                let indexPath = attr.indexPath
                indexPaths.append(indexPath)
            }
            return indexPaths
        }else {
            return []
        }
        
    }
    
}

extension NSIndexSet{
    
    func zz_indexPathsFromIndexesWithSection(section:Int)->[NSIndexPath]{
        
        var indexPaths = [NSIndexPath]()
        
        self.enumerateIndexesUsingBlock { (idx, b) in
            indexPaths.append(NSIndexPath(forItem: idx, inSection: section))
        }
        return indexPaths
        
    }
    
}

extension UIViewController{

    func zz_presentPhotoVC(maxSelected:Int,completeHandler:((assets:[PHAsset])->())?) -> ZZPhotoViewController?{
        if let vc = UIStoryboard(name: "ZZImage", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("photoVC") as? ZZPhotoViewController{
            vc.completeHandler = completeHandler
            vc.maxSelected = maxSelected
            let nav = UINavigationController(rootViewController: vc)
            self.presentViewController(nav, animated: true, completion: nil)
            return vc
        }
        return nil
    }
    
    
}











