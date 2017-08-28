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
    
    @IBOutlet weak var starButton: UIButton!
    
    
    var config: UserWindSpeedConfig?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBAction func modeSwitchValueChange(_ sender: UISwitch) {
        config?.hideflag = sender.isOn ? 0 : 1
    }
    
    func updateCellWithConfig(config: UserWindSpeedConfig) {
        self.config = config
        if config.icon1.characters.count > 0 && config.type == "fixed" {
            let rc = ImageResource(downloadURL: URL(string: config.icon1)!)
            iconView.kf.setImage(with: rc)
        }
        else if config.type == "custom" {
            let img = config.customIcon(color: themeColor!)
            iconView.image = img
        }
        nameLabel.text = config.name
        valueLabel.text = "\(config.value)"
        modeSwitch.setOn(config.hideflag == 0, animated: false)
        starButton.isSelected = (config.defaultflag == 1)
    }
    
    
    @IBAction func handleSelectStarButton(_ sender: UIButton) {
        
        sender.isSelected = true
        config?.defaultflag = 1
        for co in SessionManager.sharedInstance.windModeManager.windUserConfigList {
            if co.id != config?.id {
                co.defaultflag = 0
            }
        }
        let owner = self.ownerController() as! ModeSettingController
        owner.tableView.reloadData()
    }
    
}
