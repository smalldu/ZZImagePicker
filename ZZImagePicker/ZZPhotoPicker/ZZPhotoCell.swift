//
//  ZZPhotoCell.swift
//  ZZImagePicker
//
//  Created by duzhe on 16/4/29.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit

class ZZPhotoCell: UITableViewCell {

    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var countLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutMargins = UIEdgeInsetsZero
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
