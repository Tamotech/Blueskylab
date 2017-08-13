//
//  DateSegmentView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/6.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class DateSegmentView: BaseView {
    
    lazy var itemLabels:[UILabel] = {
       
        var labels:[UILabel] = []
        let items = [NSLocalizedString("Day", comment: ""),
                     NSLocalizedString("Week", comment: ""),
                     NSLocalizedString("Month", comment: ""),
                     NSLocalizedString("Year", comment: "")]
        let width = (screenWidth-60)/4.0
        for i in 0...3 {
            let x = CGFloat(i)*width
            let label = UILabel()
            label.text = items[i]
            label.frame = CGRect(x: x, y: 0, width: width, height: 30)
            label.textColor = themeColor
            label.textAlignment = .center
            label.alpha = (i == 0 ? 1 : 0.5)
            labels.append(label)
        }
        return labels
    
    }()
    
    lazy var indicatorView:UIView = {
        let view = UIView()
        let width = (screenWidth-60)/4.0
        view.frame = CGRect(x: 0, y: 0, width: width, height: 30)
        view.layer.borderColor = themeColor?.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 15
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.addSubview(indicatorView)
        for label in itemLabels {
            self.addSubview(label)
        }
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hexString: "009cde", alpha: 0.5)?.cgColor
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let width = (screenWidth-60)/4.0
        let point = touches.first?.location(in: self)
        let index = Int(point!.x/width)
        
        UIView.animate(withDuration: 0.3, animations: { 
            for i in 0...3 {
                let label = self.itemLabels[i]
                if i == index {
                    label.alpha = 1
                }
                else {
                    label.alpha = 0.5
                }
                self.indicatorView.centerX = (CGFloat(index)+0.5)*width
            }
        }) { (success) in
            
        }
        
        
        super.touchesBegan(touches, with: event)
    }
}
