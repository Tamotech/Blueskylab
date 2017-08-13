//
//  NotificationCenterCell.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/9.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class NotificationCenterCell: UITableViewCell {

    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var iv: UIImageView!
    
    @IBOutlet weak var contentLb: UILabel!
    
    @IBOutlet weak var dateLb: UILabel!
    @IBOutlet weak var readDetailBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func handleTapReadDetailBtn(_ sender: UIButton) {
    }
}
