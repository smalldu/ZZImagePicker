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
    
    func zz_indexPathsForElementsInRect(_ rect:CGRect) -> [IndexPath] {
        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElements(in: rect)
        if let allLayoutAttributes = allLayoutAttributes ,  allLayoutAttributes.count == 0 {
            var indexPaths = [IndexPath]()
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

extension IndexSet{
    
    func zz_indexPathsFromIndexesWithSection(_ section:Int)->[IndexPath]{
        
        var indexPaths = [IndexPath]()
        
        self.forEach { (idx) in
            indexPaths.append(IndexPath(item: idx, section: section))
        }
        return indexPaths
        
    }
    
}

extension UIViewController{

    fileprivate func authorize(_ status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus())->Bool{
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            // 请求授权
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    _ = self.authorize(status)
                })
            })
        default: ()
        DispatchQueue.main.async(execute: { () -> Void in
            let alertController = UIAlertController(title: "访问相册受限",
                message: "点击“设置”，允许访问您的相册",
                preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title:  "取消", style: .cancel, handler:nil)
            
            let settingsAction = UIAlertAction(title: "设置", style: .default, handler: { (action) -> Void in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if let url = url , UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            
            self.present(alertController, animated: true, completion: nil)
        })
        }
        return false
    }
    
    func zz_presentPhotoVC(_ maxSelected:Int,completeHandler:((_ assets:[PHAsset])->())?) -> ZZPhotoViewController?{
        guard authorize() else { return nil }
        if let vc = UIStoryboard(name: "ZZImage", bundle: Bundle.main).instantiateViewController(withIdentifier: "photoVC") as? ZZPhotoViewController{
            vc.completeHandler = completeHandler
            vc.maxSelected = maxSelected
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
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
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let snap = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return snap!;
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
        var next = self.superview
        while next != nil {
            responder = next?.next
            if responder.isKind(of: UIViewController.self) {
                return (responder as! UIViewController)
            }
            next = next?.superview
        }
        
        return (responder as! UIViewController)
    }
    
    
    func zz_removeAllSubviews(){
        for item in self.subviews{
            item.removeFromSuperview()
        }
    }
}









