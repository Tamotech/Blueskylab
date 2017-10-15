//
//  NotificationCenterCell.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/9.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import Kingfisher

class NotificationCenterCell: UITableViewCell {

    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var iv: UIImageView!
    
    @IBOutlet weak var contentLb: UILabel!
    
    @IBOutlet weak var dateLb: UILabel!
    @IBOutlet weak var readDetailBtn: UIButton!
    
    @IBOutlet weak var notificationNewTagView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func updateCell(data: NotificationItem) {
        titleLb.text = data.title
        if data.preimg.characters.count > 0 {
            let rc = ImageResource(downloadURL: URL(string: data.preimg)!)
            iv.kf.setImage(with: rc)
        }
        contentLb.text = data.description
        dateLb.text = data.dateStr()
        notificationNewTagView.isHidden = (data.readflag == 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func handleTapReadDetailBtn(_ sender: UIButton) {
        
    }
}
