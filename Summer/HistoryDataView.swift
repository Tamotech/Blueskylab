//
//  HistoryDataView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/9/17.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class HistoryDataView: UIView {

   
    var dataArr: [AQIData] = []
    var maximum: CGFloat = 500
    ///当前选中序号
    var currentIndex: Int = 0
    
    func updateView(dataArr: [AQIData], maximum: CGFloat) {
        
        self.dataArr = dataArr
        self.maximum = maximum
        self.currentIndex = dataArr.count-1
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        
        if dataArr.count == 0 {
            return
        }
        
//        let ctx = UIGraphicsGetCurrentContext()
        let leftMargin: CGFloat = 20.0
        let bottom0: CGFloat = self.height-20
        let width0 = (self.width-leftMargin*2)/CGFloat(dataArr.count)
        let height0 = self.height-40-70

        
        var minAQI: CGFloat = 100000
        var maxAQI: CGFloat = 0
        
        //绘制日期
        
        for (i, data) in dataArr.enumerated() {
            let dateStr = data.getDateStr()
            let point0 = CGPoint(x: leftMargin+CGFloat(2*i)*width0/2, y: bottom0-20)
            let attr = [NSForegroundColorAttributeName: gray72!,
                        NSFontAttributeName: UIFont.systemFont(ofSize: 10.0)]
            dateStr.draw(at: point0, withAttributes: attr)
            if data.max > maxAQI {
                maxAQI = data.max
            }
            if data.min < minAQI {
                minAQI = data.min
            }
        }
        
        if dataArr.first?.value != -1 {
            //天
            var aqis: [CGPoint] = []
            for (i, data) in dataArr.enumerated() {
                let x = leftMargin+CGFloat(2*i+1)*width0/2
                let y1 = self.height-70-data.value/maximum*height0
                aqis.append(CGPoint(x: x, y: y1))
            }
            
            //绘制最大点与最小点的坐标
            
            let path1 = UIBezierPath(rect: CGRect(x: -1, y: -1, width: screenWidth+2, height: self.height+2))
            themeColor!.setStroke()
            path1.lineWidth = 1
            path1.move(to: aqis.first!)
            path1.addBezierThroughPoints(aqis)
            path1.stroke()
            
            //当前选中的天 绘制虚线
            let pt = aqis[currentIndex]
            let ctx = UIGraphicsGetCurrentContext()
            ctx?.setStrokeColor(themeColor!.cgColor)
            ctx?.setLineWidth(1)
            ctx?.move(to: pt)
            let endPt = CGPoint(x: pt.x, y: self.height - 60)
            ctx?.addLine(to: endPt)
            let arr: [CGFloat] = [5,5]
            ctx?.setLineDash(phase: 0, lengths: arr)
            ctx?.drawPath(using: .stroke)
            
            //白色圆点
            ctx?.setFillColor(themeColor!.cgColor)
            ctx?.fillEllipse(in: CGRect(x: pt.x-3, y: pt.y-3, width: 6, height: 6))
            ctx?.drawPath(using: .fill)
            
            //最大最小值
            let attr = [NSForegroundColorAttributeName: gray72!,
                        NSFontAttributeName: UIFont.systemFont(ofSize: 12.0)]
            let currentData = dataArr[currentIndex]
            let value = "\(currentData.value)"
            value.draw(at: CGPoint.init(x: pt.x+4, y: pt.y-25), withAttributes: attr)
            
        }
        else{
            var maxPoints: [CGPoint] = []
            var minPoints: [CGPoint] = []
            for (i, data) in dataArr.enumerated() {
                let x = leftMargin+CGFloat(2*i+1)*width0/2
                let y1 = self.height-70-data.min/maximum*height0
                let y2 = self.height-70-data.max/maximum*height0
                minPoints.append(CGPoint(x: x, y: y1))
                maxPoints.append(CGPoint(x: x, y: y2))
                
            }
            //绘制最大点与最小点的坐标
            
            let path1 = UIBezierPath(rect: CGRect(x: -1, y: -1, width: screenWidth+2, height: self.height+2))
            themeColor!.setStroke()
            path1.move(to: maxPoints.first!)
            path1.lineWidth = 1
            path1.addBezierThroughPoints(maxPoints)
            path1.stroke()
            
            let path2 = UIBezierPath(rect: CGRect(x: -1, y: -1, width: screenWidth+2, height: self.height+2))
            path2.lineWidth = 1
            path2.move(to: minPoints.first!)
            path2.addBezierThroughPoints(minPoints)
            path2.stroke()
            
            //当前选中的天 绘制虚线
            let pt = maxPoints[currentIndex]
            let ctx = UIGraphicsGetCurrentContext()
            ctx?.setStrokeColor(themeColor!.cgColor)
            ctx?.setLineWidth(1)
            ctx?.move(to: pt)
            let endPt = CGPoint(x: pt.x, y: self.height - 60)
            ctx?.addLine(to: endPt)
            let arr: [CGFloat] = [5,5]
            ctx?.setLineDash(phase: 0, lengths: arr)
            ctx?.drawPath(using: .stroke)
            
            //白色圆点
            let mpt = minPoints[currentIndex]
            ctx?.setFillColor(themeColor!.cgColor)
            ctx?.fillEllipse(in: CGRect(x: pt.x-3, y: pt.y-3, width: 6, height: 6))
            ctx?.fillEllipse(in: CGRect(x: mpt.x-3, y: mpt.y-3, width: 6, height: 6))
            ctx?.drawPath(using: .fill)
            
            //最大最小值
            let attr = [NSForegroundColorAttributeName: gray72!,
                        NSFontAttributeName: UIFont.systemFont(ofSize: 12.0)]
            let currentData = dataArr[currentIndex]
            let max = "\(currentData.max)" as NSString
            let min = "\(currentData.min)" as NSString
            max.draw(at: CGPoint.init(x: pt.x+4, y: pt.y-25), withAttributes: attr)
            min.draw(at: CGPoint.init(x: mpt.x+4, y: mpt.y+10), withAttributes: attr)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dataArr.count > 0 {
            let width0 = (screenWidth-40)/CGFloat(dataArr.count)
            let point = touches.first!.location(in: self)
            currentIndex = Int((point.x-20)/width0)
            if currentIndex >= dataArr.count {
                currentIndex = dataArr.count-1
            }
            self.setNeedsDisplay()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dataArr.count > 0 {
            let width0 = (screenWidth-40)/CGFloat(dataArr.count)
            let point = touches.first!.location(in: self)
            currentIndex = Int((point.x-20)/width0)
            if currentIndex >= dataArr.count {
                currentIndex = dataArr.count-1
            }
            self.setNeedsDisplay()
        }
    }
    
}
