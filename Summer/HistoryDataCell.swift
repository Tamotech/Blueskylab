//
//  HistoryDataCell.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/6.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class HistoryDataCell: UITableViewCell {

    
    @IBOutlet weak var colorDotView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var aqiNameLabel: UILabel!
    @IBOutlet weak var aqiLevelLabel: UILabel!
    
    @IBOutlet weak var temWindLabel: UILabel!
    
    @IBOutlet weak var levelLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(data: CityAQIData) {
        
        dateLabel.text = data.dateStr
        colorDotView.backgroundColor = UIColor(hexString: data.aqilevelcoler)
        aqiLevelLabel.text = "\(Int(data.aqi))"
        aqiLevelLabel.textColor = UIColor(hexString: data.aqilevelcoler)
        temWindLabel.text = "\(Int(data.temp))°C \(Int(data.wse))级风"
        temWindLabel.textColor = UIColor(hexString: data.aqilevelcoler)
        levelLabel.text = data.aqilevelname
        levelLabel.textColor = UIColor(hexString: data.aqilevelcoler)
    }
    
}
