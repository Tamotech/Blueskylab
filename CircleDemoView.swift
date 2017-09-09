//
//  CircleDemoView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/9/3.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class CircleDemoView: UIView {

    var radius:CGFloat = 120
    var amount: Int = 30
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        let angle = 2*CGFloat(Double.pi)/CGFloat(amount)
        for _ in 0..<amount {
            let path = UIBezierPath(ovalIn: CGRect(x: self.centerX-radius/2, y: self.centerY-radius/2, width: radius, height: radius*0.8))
            path.lineWidth = 1
            UIColor.red.setStroke()
            ctx?.addPath(path.cgPath)
//            ctx?.rotate(by: angle)
        }
        ctx?.strokePath()
    }
    
}
