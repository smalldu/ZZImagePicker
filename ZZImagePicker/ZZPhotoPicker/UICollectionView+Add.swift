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

extension UIView{
    
    var zz_height:CGFloat{
        set(v){
            self.frame.size.height = v
        }
        get{
            return self.frame.size.height
        }
    }
    
    var zz_width:CGFloat{
        set(v){
            self.frame.size.width = v
        }
        get{
            return self.frame.size.width
        }
    }
    
    func zz_snapShotImage()->UIImage{
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0)
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let snap = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return snap;
    }
    
    var zz_size:CGSize{
        set(v){
            self.frame.size = v
        }
        get{
            return self.frame.size
        }
    }
    
    public var zz_left:CGFloat{
        set(new){
            self.frame.origin.x = new
        }
        get{
            return self.frame.origin.x
        }
    }
    
    public var zz_right:CGFloat{
        set(new){
            self.frame.origin.x = new
        }
        get{
            return  self.frame.origin.x + self.frame.size.width
        }
    }
    
    public var zz_top:CGFloat{
        set(v){
            frame.origin.y = v
        }
        get{
            return self.frame.origin.y
        }
    }
    
    public var zz_bottom:CGFloat{
        set(v){
            self.frame.origin.y = v - self.frame.size.height
        }
        get{
            return self.frame.origin.y + self.frame.size.height
        }
    }
    
    
    public var zz_origin:CGPoint{
        set(v){
            self.frame.origin = v
        }
        get{
            return self.frame.origin
        }
    }
    
    //查找vc
    func responderViewController() -> UIViewController {
        var responder: UIResponder! = nil
        for var next = self.superview; (next != nil); next = next!.superview {
            responder = next?.nextResponder()
            if (responder!.isKindOfClass(UIViewController)){
                return (responder as! UIViewController)
            }
        }
        return (responder as! UIViewController)
    }
    
    func zz_removeAllSubviews(){
        for item in self.subviews{
            item.removeFromSuperview()
        }
    }
}









