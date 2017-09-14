//
//  AwesomeCircleView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/9/2.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class AwesomeCircleView: UIView {

    
    var layers: [CALayer] = []
    var circleLength: CGFloat = 200
    let circleNum = 30
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        circleLength = frame.size.width
        for _ in 0..<circleNum {
            let layer = CAShapeLayer()
            let centerX = frame.size.width/2
            let centerY = frame.size.width/2
            layer.frame = CGRect(x: centerX-circleLength/2, y: centerY-circleLength/2, width: circleLength, height: circleLength)
            layer.borderWidth = 0
            layer.borderColor = UIColor.white.cgColor
            //let path = UIBezierPath(ovalIn: CGRect(x: centerX-circleLength/2, y: centerY-circleLength/2, width: circleLength, height: circleLength))
            let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: circleLength, height: circleLength))
            
            layer.path = path.cgPath
//            layer.cornerRadius = circleLength/2
            layer.strokeColor = UIColor.white.cgColor
            layer.fillColor = UIColor.clear.cgColor
//            let angle = CGFloat(i * 360/circleNum)*CGFloat(Double.pi/180)
//            layer.transform = CATransform3DMakeScale(0.8, 1, 1)
//            layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
            self.layer.addSublayer(layer)
            layers.append(layer)
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func startAnimation() {
        
        
        for i in 0..<circleNum {
            let layer = self.layers[i] as! CAShapeLayer
//            let centerX = self.frame.size.width/2
//            let centerY = self.frame.size.width/2
            //layer.position = CGPoint(x: centerX, y: centerY)
//            let path = UIBezierPath(ovalIn: CGRect(x: centerX-self.circleLength/2, y: centerY-self.circleLength/2, width: self.circleLength, height: self.circleLength*1))
//            layer.path = path.cgPath
//            //            layer.cornerRadius = circleLength/2
//            layer.strokeColor = UIColor.black.cgColor
//            layer.fillColor = UIColor.clear.cgColor
            
            layer.removeAllAnimations()
            let animation1 = CABasicAnimation(keyPath: "transform.scale.x")
            animation1.repeatCount = MAXFLOAT
//          animation1.beginTime = 0.05*Double(i)+CACurrentMediaTime()
            animation1.duration = 3
            animation1.fromValue = 0.6
            animation1.toValue = 1.0
            animation1.autoreverses = true
            animation1.isRemovedOnCompletion = true
            layer.add(animation1, forKey: "scalex")
            
            
            let animation3 = CABasicAnimation(keyPath: "transform.rotation.z")
            animation3.repeatCount = MAXFLOAT
            animation3.beginTime = 0.1*Double(i)+CACurrentMediaTime()
            animation3.duration = 2
            animation3.fromValue = 0
            animation3.toValue = Double.pi*2
            animation3.autoreverses = false
            animation3.isRemovedOnCompletion = true
            layer.add(animation3, forKey: "rotation")
            
            
            let animation4 = CABasicAnimation(keyPath: "opacity")
            animation4.repeatCount = MAXFLOAT
            animation4.beginTime = 0.05*Double(i)+CACurrentMediaTime()
            animation4.duration = 4
            animation4.fromValue = 0.6
            animation4.toValue = 0.3
            animation4.autoreverses = true
            animation4.isRemovedOnCompletion = true
            layer.add(animation4, forKey: "opacity")
            
        }
        
        //随机粒子
        for _ in 0..<circleNum {
            let radius = CGFloat(arc4random()%10+5)
            //随机半径  1-1.5r
            let r1 = circleLength/2+CGFloat(0.5*CGFloat(arc4random()%UInt32(circleLength/2)))
            //随机角度0-2pi
            let ra = Double(arc4random()%UInt32(Double.pi*2.0*1000))/1000.0
            let x0 = r1*CGFloat(sin(ra))+circleLength/2
            let y0 = r1*CGFloat(cos(ra))+circleLength/2
            
            //终点位置
            let x1 = circleLength/2*CGFloat(sin(ra))+circleLength/2
            let y1 = circleLength/2*CGFloat(cos(ra))+circleLength/2
            
            //随机透明度
            let op = CGFloat(arc4random()%6+3)/10.0
            
            let pLayer = CALayer()
            pLayer.frame = CGRect(x: x0, y: y0, width: radius, height: radius)
            pLayer.position = CGPoint(x: x0, y: y0)
            pLayer.backgroundColor = UIColor.init(white: 1, alpha: op).cgColor
            pLayer.cornerRadius = radius
            self.layer.addSublayer(pLayer)
            
            let animation5 = CABasicAnimation(keyPath: "position")
            animation5.duration = 3
            animation5.fromValue = CGPoint(x: x0, y: y0)
            animation5.toValue = CGPoint(x: x1, y: y1)
            animation5.repeatCount = 2
            animation5.autoreverses = false
            animation5.isRemovedOnCompletion = true
            pLayer.add(animation5, forKey: "position")
            
            let animation6 = CABasicAnimation(keyPath: "opacity")
            animation6.duration = 3
            animation6.fromValue = op
            animation6.toValue = 0.3
            animation6.repeatCount = 2
            animation6.autoreverses = false
            animation6.isRemovedOnCompletion = true
            pLayer.add(animation6, forKey: "opacity")
            
        }
    
        
        
    }
    
    override func removeFromSuperview() {
        for layer in layers {
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }
        super.removeFromSuperview()
    }
}
