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
                self.hidden = true
            }else{
                self.hidden = false
                self.text = "\(num)"
                animateSelf()
            }
        }
    }
    init(toolBar:UIToolbar) {
        super.init(frame:CGRectMake(zz_sw - 67 , 12 , 20, 20))
        self.backgroundColor = UIColor(red: 0x09/255, green: 0x8b/255, blue: 0x54/255, alpha: 1)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.textAlignment = .Center
        self.font = UIFont.systemFontOfSize(15)
        self.textColor = UIColor.whiteColor()
        toolBar.addSubview(self)
    }
    
    /**
     改变数字的动画
     */
    func animateSelf() {
        self.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    /**
     超出最大选择输时动画
     */
    func tooMoreAnimate(){
        
        UIView.animateKeyframesWithDuration(0.4, delay: 0, options: UIViewKeyframeAnimationOptions.CalculationModeLinear, animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.1, animations: {
                self.backgroundColor = UIColor.redColor()
                self.transform = CGAffineTransformMakeTranslation(-3, 0)
            })
            UIView.addKeyframeWithRelativeStartTime(0.1, relativeDuration: 0.2, animations: {
                self.transform = CGAffineTransformMakeTranslation(3, 0)
            })
            UIView.addKeyframeWithRelativeStartTime(0.2, relativeDuration: 0.3, animations: {
                self.transform = CGAffineTransformMakeTranslation(-3, 0)
            })
            UIView.addKeyframeWithRelativeStartTime(0.3, relativeDuration: 0.4, animations: {
                self.transform = CGAffineTransformMakeTranslation(3, 0)
            })
        }){ b in
            UIView.animateWithDuration(0.025, animations: {
                self.transform = CGAffineTransformIdentity
                self.backgroundColor = UIColor(red: 0x09/255, green: 0x8b/255, blue: 0x54/255, alpha: 1)
            })
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
