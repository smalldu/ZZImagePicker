//
//  ZZImageSelectedLayer.swift
//  ZZImagePicker
//
//  Created by duzhe on 16/4/29.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit

class ZZImageSelectedLabel: UILabel {

    var num:Int = 0{
        didSet{
            if num == 0{
                self.isHidden = true
            }else{
                self.isHidden = false
                self.text = "\(num)"
                animateSelf()
            }
        }
    }
    init(toolBar:UIToolbar) {
        super.init(frame:CGRect(x: zz_sw - 67 , y: 12 , width: 20, height: 20))
        self.backgroundColor = UIColor(red: 0x09/255, green: 0x8b/255, blue: 0x54/255, alpha: 1)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.textAlignment = .center
        self.font = UIFont.systemFont(ofSize: 15)
        self.textColor = UIColor.white
        toolBar.addSubview(self)
    }
    
    /**
     改变数字的动画
     */
    func animateSelf() {
        self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: {
                self.transform = CGAffineTransform.identity
            }, completion: nil)
    }
    
    /**
     超出最大选择输时动画
     */
    func tooMoreAnimate(){
        
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1, animations: {
                self.backgroundColor = UIColor.red
                self.transform = CGAffineTransform(translationX: -3, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.2, animations: {
                self.transform = CGAffineTransform(translationX: 3, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.3, animations: {
                self.transform = CGAffineTransform(translationX: -3, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.4, animations: {
                self.transform = CGAffineTransform(translationX: 3, y: 0)
            })
        }){ b in
            UIView.animate(withDuration: 0.025, animations: {
                self.transform = CGAffineTransform.identity
                self.backgroundColor = UIColor(red: 0x09/255, green: 0x8b/255, blue: 0x54/255, alpha: 1)
            })
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
