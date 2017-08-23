//
//  ModeSettingCell.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/21.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import Kingfisher

class ModeSettingCell: UITableViewCell {

    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var modeSwitch: UISwitch!
    
    var config: UserWindSpeedConfig?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBAction func modeSwitchValueChange(_ sender: UISwitch) {
    }
    
    func updateCellWithConfig(config: UserWindSpeedConfig) {
        self.config = config
        let rc = ImageResource(downloadURL: URL(string: config.icon1)!)
        iconView.kf.setImage(with: rc)
        nameLabel.text = config.name
        valueLabel.text = "\(config.value)"
        modeSwitch.setOn(config.hideflag == 0, animated: false)
    }
}
