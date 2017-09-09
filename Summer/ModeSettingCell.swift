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
    
    @IBOutlet weak var currentModeLabel: UILabel!
    
    var config: UserWindSpeedConfig?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBAction func modeSwitchValueChange(_ sender: UISwitch) {
        config?.hideflag = sender.isOn ? 0 : 1
        config!.update { (success, msg) in
            
        }
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
        let isCurrentMode = SessionManager.sharedInstance.windModeManager.getCurrentMode().id == config.id
        currentModeLabel.isHidden = !isCurrentMode
        modeSwitch.isHidden = !currentModeLabel.isHidden
        modeSwitch.setOn(config.hideflag == 0, animated: false)
        starButton.isSelected = (config.defaultflag == 1)
    }
    
    
    @IBAction func handleSelectStarButton(_ sender: UIButton) {
        
        SessionManager.sharedInstance.windModeManager.bringToTop(config: config!)
        NotificationCenter.default.post(name: kWindModeConfigDidChangeOrderNotify, object: nil)
        self.starButton.isSelected = true
        let owner = self.ownerController() as! ModeSettingController
        let topCell = owner.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ModeSettingCell
        topCell.starButton.isSelected = false
        let indexPath = owner.tableView.indexPath(for: self)
        owner.tableView.moveRow(at: indexPath!, to: IndexPath(row: 0, section: 0))
    }
    
}
