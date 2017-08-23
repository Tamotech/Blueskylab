//
//  WindModeAjustor.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/13.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import Kingfisher


protocol WindModeAjustorDelegate {
    func selectItem(mode: UserWindSpeedConfig)
}

/// 调节风量的圆环组件
/// 有放大缩小两种模式
class WindModeAjustor: UIView {

    
    var mode: UserWindSpeedConfig = UserWindSpeedConfig()
    let iconView: UIImageView = UIImageView()
    let windLevelLabel: UILabel = UILabel()
    let leftLb: UILabel = UILabel()
    let rightLb: UILabel = UILabel()
    let ovalOutsideView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "ovalOutside"))
    let rulerView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "ovalRuler"))
    let pointView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "windModePoint"))
    let itemLabel: UILabel = UILabel()
    
    var delegate: WindModeAjustorDelegate?
    
    let minLevel: CGFloat = 0
    let maxLevel: CGFloat = 100
    
    init(frame: CGRect, mode: UserWindSpeedConfig) {
        super.init(frame: frame)
        self.mode = mode
        self.addSubview(ovalOutsideView)
        ovalOutsideView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(0)
        }
        
        //转轮
        self.addSubview(rulerView)
        rulerView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(0)
        }

        if mode.isAdd {
            iconView.image = #imageLiteral(resourceName: "iconAdd_darkblue")
        }
        else {
            let rc = ImageResource(downloadURL: URL(string: mode.icon2)!)
            iconView.kf.setImage(with: rc)    
        }
        self.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY).offset(-20)
            make.width.height.equalTo(35)
        }
        
        windLevelLabel.text = "\(mode.value)"
        windLevelLabel.textColor = UIColor(hexString: "3b74db")
        windLevelLabel.font = UIFont.systemFont(ofSize: 21)
        self.addSubview(windLevelLabel)
        windLevelLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY).offset(10)
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
        
        
        itemLabel.textColor = UIColor(hexString: "3b74db")
        itemLabel.font = UIFont.systemFont(ofSize: 15)
        itemLabel.text = mode.name
        self.addSubview(itemLabel)
        itemLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.bottom).offset(-18)
            make.centerX.equalTo(self.snp.centerX)
        }
        
        self.addSubview(pointView)
        pointView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(0)
        }
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(handleTapGes(tap:)))
        self.addGestureRecognizer(tapGes)
        
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesOnPoint(pan:)))
        pointView.isUserInteractionEnabled = true
        pointView.addGestureRecognizer(panGes)
        
        
        if mode.isAdd {
            rulerView.isHidden = true
            pointView.isHidden = true
            itemLabel.isHidden = true
//            ovalOutsideView.isHidden = true
            windLevelLabel.isHidden = true
            leftLb.isHidden = true
            rightLb.isHidden = true
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    /// 变换模式
    ///
    /// - Parameter smallMode: 是否是小图标模式
    func transformToSmall(smallMode: Bool) {
        
        if smallMode {
            iconView.snp.remakeConstraints({ (make) in
                make.centerX.equalTo(self.snp.centerX)
                make.centerY.equalTo(self.snp.centerY)
                make.size.equalTo(CGSize(width: 35, height: 35))
            })
            if mode.icon2.characters.count>0 {
                let rc = ImageResource(downloadURL: URL(string: mode.icon2)!)
                iconView.kf.setImage(with: rc)
            }
            self.windLevelLabel.alpha = 0
            self.leftLb.alpha = 0
            self.rightLb.alpha = 0
            self.itemLabel.alpha = 0
            self.rulerView.alpha = 0
            self.pointView.alpha = 0
            
        }
        else {
            iconView.snp.remakeConstraints({ (make) in
                make.centerX.equalTo(self.snp.centerX)
                make.centerY.equalTo(self.snp.centerY).offset(-20)
                make.size.equalTo(CGSize(width: 30, height: 30))
            })
            if mode.icon3.characters.count > 0 {
                let rc = ImageResource(downloadURL: URL(string: mode.icon3)!)
                iconView.kf.setImage(with: rc)
            }
            self.windLevelLabel.alpha = 1
            self.leftLb.alpha = 1
            self.rightLb.alpha = 1
            self.itemLabel.alpha = 1
            self.rulerView.alpha = 1
            self.pointView.alpha = 1
            
        }
        
        
    }


    func handlePanGesOnPoint(pan: UIPanGestureRecognizer) {
        if pan.state == .changed {
            let pt = pan.location(in: self)
            print("pt ---- [\(pt.x), \(pt.y)]")
            let center = rulerView.center
            let startAngle: CGFloat = CGFloat(190*Double.pi/180)
            //            let endAngle: CGFloat = CGFloat(350*Double.pi/180)
            
            //计算角度
            //print("x - y [\(pt.x-center.x), \(pt.y-center.y)]")
            var x:CGFloat = pt.x - center.x
            let y:CGFloat = center.y - pt.y
            if x == 0 {
                x = 0.001
            }
            //print("x - y [\(x), \(y)]")
            let angle = atan2(y, x)
            
            rotateToAngle(angle: startAngle - angle)
            
            
        }
    }
    
    func handleTapGes(tap: UITapGestureRecognizer) {
        if delegate != nil {
            delegate!.selectItem(mode: mode)
        }
    }
    
    
    //MARK: - private
    func rotateToAngle(angle: CGFloat) {
        //print("旋转角度 ----- \(180*angle/CGFloat(Double.pi))度")
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
