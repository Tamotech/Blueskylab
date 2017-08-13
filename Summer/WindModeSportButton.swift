//
//  WindModeSportView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/10.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import SnapKit


protocol SportButtonDelegate {
    func selectedSport()
}

/// 运动模式 可以调节送风量
class WindModeSportButton: UIButton {

    var bgView: UIImageView = UIImageView(image: UIImage(named: "windModeRunBg"))
    var pointView: UIImageView = UIImageView(image: UIImage(named: "windModePoint"))
    var windLevelLabel: UILabel = UILabel()
    
    let runIcon = UIImageView(image: UIImage(named: "icon-run-small"))
    let leftLb = UILabel()
    let rightLb = UILabel()
    let bottomLb = UILabel()
    
    let minLevel: CGFloat = 0
    let maxLevel: CGFloat = 100
    
    var delegate: SportButtonDelegate?
    
    var mode: WindMode = WindMode.WindModeSport
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.addSubview(bgView)
        self.addSubview(pointView)
        bgView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self)
        }
        pointView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self)
        }

        self.addSubview(runIcon)
        runIcon.snp.makeConstraints { (make) in
            make.top.equalTo(35)
            make.centerX.equalTo(self.snp.centerX)
        }
        
        windLevelLabel.text = "60"
        windLevelLabel.textColor = UIColor(hexString: "3b74db")
        windLevelLabel.font = UIFont.systemFont(ofSize: 21)
        self.addSubview(windLevelLabel)
        windLevelLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY).offset(6)
        }
        
        
        leftLb.textColor = UIColor(hexString: "333333")
        leftLb.font = UIFont.systemFont(ofSize: 7.0)
        leftLb.text = NSLocalizedString("SendWindAmount", comment: "")
        self.addSubview(leftLb)
        leftLb.snp.makeConstraints { (make) in
            make.right.equalTo(windLevelLabel.snp.left)
            make.centerY.equalTo(windLevelLabel.snp.centerY)
        }
        
        
        rightLb.textColor = UIColor(hexString: "333333")
        rightLb.font = UIFont.systemFont(ofSize: 7.0)
        rightLb.text = "L/min"
        self.addSubview(rightLb)
        rightLb.snp.makeConstraints { (make) in
            make.left.equalTo(windLevelLabel.snp.right)
            make.centerY.equalTo(windLevelLabel.snp.centerY)
        }
        
        
        bottomLb.textColor = UIColor(hexString: "3b74db")
        bottomLb.font = UIFont.systemFont(ofSize: 15)
        bottomLb.text = NSLocalizedString("Sport", comment: "")
        self.addSubview(bottomLb)
        bottomLb.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.bottom).offset(-18)
            make.centerX.equalTo(self.snp.centerX)
        }
        
        
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesOnPoint(pan:)))
        pointView.isUserInteractionEnabled = true
        pointView.addGestureRecognizer(panGes)
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(handleTapGes(tap:)))
        pointView.addGestureRecognizer(tapGes)
    }
    
    func transformToSmall(smallMode: Bool) {
        
        if smallMode {
            self.runIcon.isHidden = true
            self.windLevelLabel.isHidden = true
            self.leftLb.isHidden = true
            self.rightLb.isHidden = true
            self.bottomLb.isHidden = true
            
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                self.runIcon.isHidden = false
                self.windLevelLabel.isHidden = false
                self.leftLb.isHidden = false
                self.rightLb.isHidden = false
                self.bottomLb.isHidden = false
    
            })
        }

        
    }
    
    func handlePanGesOnPoint(pan: UIPanGestureRecognizer) {
        if pan.state == .changed {
            let pt = pan.location(in: self)
            print("pt ---- [\(pt.x), \(pt.y)]")
            let center = pointView.center
            let startAngle: CGFloat = CGFloat(190*Double.pi/180)
//            let endAngle: CGFloat = CGFloat(350*Double.pi/180)
            
            //计算角度
            //print("x - y [\(pt.x-center.x), \(pt.y-center.y)]")
            var x:CGFloat = pt.x - center.x
            let y:CGFloat = center.y - pt.y
            if x == 0 {
                x = 0.001
            }
            print("x - y [\(x), \(y)]")
            let angle = atan2(y, x)
            
            rotateToAngle(angle: startAngle - angle)
            
            
        }
    }
    
    func handleTapGes(tap: UITapGestureRecognizer) {
        if delegate != nil {
            delegate!.selectedSport()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - private
    func rotateToAngle(angle: CGFloat) {
        print("旋转角度 ----- \(180*angle/CGFloat(Double.pi))度")
        var angleDu = 180*angle/CGFloat(Double.pi)
        if angleDu > 190 && angleDu < 350 {
            //非法角度
            return
        }
        pointView.transform = CGAffineTransform.init(rotationAngle: angle)
        if angleDu >= 350 {
            angleDu = angleDu - 360
        }
        angleDu = angleDu + 10
        let level = angleDu/200*maxLevel
        windLevelLabel.text = String(Int(level))
    }
    
    
}
