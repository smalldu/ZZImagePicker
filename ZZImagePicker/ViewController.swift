//
//  ViewController.swift
//  ZZImagePicker
//
//  Created by duzhe on 16/4/12.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "测试"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goPhoto(sender: AnyObject) {
        
        
        authorize()
        
        
    }

    
    func authorize(status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()){
        switch status {
        case .Authorized:
            self.zz_presentPhotoVC(6){ (assets) in
                print(assets.count)
            }
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
    }
}



