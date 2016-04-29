//
//  ZZGridViewCell.swift
//  ZZImagePicker
//
//  Created by duzhe on 16/4/27.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit

public class ZZGridViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var selectedImageView:UIImageView!
    public override var selected: Bool {
        didSet{
            if selected {
                selectedImageView.image = UIImage(named: "zz_image_cell_selected")
                
                
            }else{
                selectedImageView.image = UIImage(named: "zz_image_cell")
            }
        }
    }
    
    func showAnim() {
        UIView.animateKeyframesWithDuration(0.4, delay: 0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.2, animations: {
                self.selectedImageView.transform = CGAffineTransformMakeScale(0.7, 0.7)
            })
            UIView.addKeyframeWithRelativeStartTime(0.2, relativeDuration: 0.4, animations: {
                self.selectedImageView.transform = CGAffineTransformIdentity
            })
            }, completion: nil)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
    }

}
