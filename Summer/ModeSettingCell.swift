//
//  ModeSettingCell.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/21.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class ModeSettingCell: UITableViewCell {

    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var modeSwitch: UISwitch!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBAction func modeSwitchValueChange(_ sender: UISwitch) {
    }
    
    
}
