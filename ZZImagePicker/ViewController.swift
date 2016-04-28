//
//  ViewController.swift
//  ZZImagePicker
//
//  Created by duzhe on 16/4/12.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "测试"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goPhoto(sender: AnyObject) {
        self.zz_presentPhotoVC(4){ (assets) in
            print(assets.count)
        }   
    }

}



