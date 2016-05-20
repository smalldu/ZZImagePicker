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

    private func authorize(status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus())->Bool{
        switch status {
        case .Authorized:
            return true
        case .NotDetermined:
            // 请求授权
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.authorize(status)
                })
            })
        default: ()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alertController = UIAlertController(title: "访问相册受限",
                message: "点击“设置”，允许访问您的相册",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title:  "取消", style: .Cancel, handler:nil)
            
            let settingsAction = UIAlertAction(title: "设置", style: .Default, handler: { (action) -> Void in
                let url = NSURL(string: UIApplicationOpenSettingsURLString)
                if let url = url where UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        })
        }
        return false
    }
    
    func zz_presentPhotoVC(maxSelected:Int,completeHandler:((assets:[PHAsset])->())?) -> ZZPhotoViewController?{
        guard authorize() else { return nil }
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











