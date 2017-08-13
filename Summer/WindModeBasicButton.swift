//
//  WindModeBasicView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/11.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import SnapKit

class WindModeBasicButton: UIButton {
    
    var mode: WindMode = .WindModeDefault
    var iconView = UIImageView()
    
    init(frame: CGRect, mode:WindMode) {
        super.init(frame: frame)
        
        //let modeName = WindModeModel.modeName(mode: mode)
        let icon = WindModeModel.modeIcon(mode: mode)
        iconView.image = icon
        self.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.top.right.left.bottom.equalTo(0)
        }
        
//        titleLabel.text = modeName
//        titleLabel.font = UIFont.systemFont(ofSize: 15)
//        titleLabel.textColor = UIColor(hexString: "333333", alpha: 0.7)
//        titleLabel.textAlignment = .center
//        self.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(self.modeButton.snp.bottom).offset(10)
//            make.centerX.equalTo(self.snp.centerX)
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
