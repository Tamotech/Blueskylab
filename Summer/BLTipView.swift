//
//  BLTipView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/10.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import SnapKit

class BLTipView: UIView {

    
    var msgLabel: UILabel?
    var iconView: UIImageView?
    
    init(frame: CGRect, msg: String, icon: UIImage?, textColor: UIColor, bgColor: UIColor) {
        super.init(frame: frame)
        msgLabel = UILabel()
        msgLabel?.text = msg
        msgLabel?.textColor = textColor
        msgLabel?.numberOfLines = 0
        msgLabel?.font = UIFont.systemFont(ofSize: 12)
        msgLabel?.textAlignment = .center
        self.addSubview(msgLabel!)
        msgLabel?.snp.makeConstraints({ (make) in
            make.top.bottom.equalTo(0)
            make.left.equalTo(6)
            make.right.equalTo(-6)
        })
        
        self.backgroundColor = bgColor
        
        if icon != nil {
            iconView = UIImageView(image: icon!)
            iconView?.sizeToFit()
            self.addSubview(iconView!)
            iconView?.snp.makeConstraints({ (make) in
                make.right.equalTo(-8)
                make.centerY.equalTo(msgLabel!.snp.centerY)
                make.size.equalTo(iconView!.size)
            })
            
            let line = UIView()
            line.backgroundColor = textColor
            self.addSubview(line)
            line.snp.makeConstraints({ (make) in
                make.width.equalTo(1)
                make.top.bottom.equalTo(0)
                make.right.equalTo(iconView!.snp.left).offset(-8)
            })
            
            msgLabel?.snp.remakeConstraints({ (make) in
                make.right.equalTo(line.snp.left).offset(-6)
                make.left.equalTo(6)
                make.top.bottom.equalTo(0)
            })
        }
        
        self.cornerRadius = 8
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
