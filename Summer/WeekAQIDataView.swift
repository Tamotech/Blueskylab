//
//  WeekAQIDataView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/17.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

let dataViewHeight: CGFloat = 225


/// 最近一周的曲线图
class WeekAQIDataView: UIView {

    var recentData: RecentWeekAQI?
    var textLbs: [UILabel] = []
    let maxAQILb = UILabel()
    let minAQILb = UILabel()
    
    ///当前选中的天
    var currentIndex = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let lbWidth: CGFloat = 60.0
        let lbHeight: CGFloat = 60.0
        let cy: CGFloat = dataViewHeight - lbHeight/2
        for i in 0..<5 {
            let cx: CGFloat = screenWidth*(2*CGFloat(i)+1)/10.0
            let lb = UILabel(frame: CGRect(x: 0, y: 0, width: lbWidth, height: lbHeight))
            lb.center = CGPoint(x: cx, y: cy)
            lb.numberOfLines = 3
            lb.textAlignment = .center
            lb.font = UIFont.systemFont(ofSize: 13.0)
            lb.textColor = UIColor(white: 1, alpha: 0.7)
            self.addSubview(lb)
            textLbs.append(lb)
            
        }
        maxAQILb.font = UIFont.systemFont(ofSize: 13)
        maxAQILb.textColor = UIColor.white
        self.addSubview(maxAQILb)
        minAQILb.font = UIFont.systemFont(ofSize: 13)
        minAQILb.textColor = UIColor.white
        self.addSubview(minAQILb)
    }
    
    func updateView(data: RecentWeekAQI) {
        recentData = data
        self.setNeedsDisplay()
    }
    
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        guard let data = recentData else {
            return
        }
        if data.recentAQIs.count != 7 {
            return;
        }
        //绘制曲线
        var maxPoints: [CGPoint] = []
        var minPoints: [CGPoint] = []
        let height = dataViewHeight - 60
        
        let pkPoint = data.peakValue()
        let maxAQI = CGFloat(pkPoint.0)*1.5
        for i in 0..<7 {
            
            if (i > 0 && i < 6) {
                let lb = textLbs[i-1]
                lb.text = getDateName(index: i-1)
            }
            
            var cx: CGFloat = 0
           
            
            cx = screenWidth*(2*CGFloat(i-1)+1)/10.0
            
            let aqi = data.recentAQIs[i]
            let cy1 = height - 10 - (height-30)*CGFloat(aqi.aqiMax)/maxAQI
            let cy2 = height - 10 - (height-30)*CGFloat(aqi.aqiMin)/maxAQI
            let p1 = CGPoint(x: cx, y: cy1)
            let p2 = CGPoint(x: cx, y: cy2)
            maxPoints.append(p1)
            minPoints.append(p2)
        }
        
        //绘制最大点与最小点的坐标
        
        let path1 = UIBezierPath(rect: CGRect(x: -1, y: -1, width: screenWidth+2, height: self.height+2))
        UIColor.white.setStroke()
        path1.lineWidth = 1
        path1.addBezierThroughPoints(maxPoints)
        path1.stroke()
        
        let path2 = UIBezierPath(rect: CGRect(x: -1, y: -1, width: screenWidth+2, height: self.height+2))
        path2.lineWidth = 1
        path2.addBezierThroughPoints(minPoints)
        path2.stroke()
        
        
        //绘制最大与最小位置的数值
        let cy1 = height - 10 - (height-30)*CGFloat(pkPoint.0)/maxAQI - 10
        let cy2 = height - 10 - (height-30)*CGFloat(pkPoint.1)/maxAQI + 10
        var cx1: CGFloat = 0.0
        var cx2: CGFloat = 0.0
        if (pkPoint.2 == 0) {
            cx1 = 30
        }
        else if pkPoint.2 == 6 {
            cx1 = screenWidth-30
        }
        else {
            cx1 = screenWidth*(2*CGFloat(pkPoint.2)-1)/10.0
        }
        if (pkPoint.3 == 0) {
            cx2 = screenWidth - 30
        }
        else if pkPoint.3 == 6 {
            cx2 = screenWidth-30
        }
        else {
            cx2 = screenWidth*(2*CGFloat(pkPoint.3)-1)/10.0
        }
        maxAQILb.text = String(format: "%d", pkPoint.0)
        maxAQILb.sizeToFit()
        maxAQILb.center = CGPoint(x: cx1, y: cy1)
        minAQILb.text = String(format: "%d", pkPoint.1)
        minAQILb.center = CGPoint(x: cx2, y: cy2)
        minAQILb.sizeToFit()
        
        //当前选中的天 绘制虚线
        let pt = maxPoints[currentIndex]
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setStrokeColor(UIColor(white: 1, alpha: 0.8).cgColor)
        ctx?.setLineWidth(1)
        ctx?.move(to: pt)
        let endPt = CGPoint(x: pt.x, y: dataViewHeight - 60)
        ctx?.addLine(to: endPt)
        let arr: [CGFloat] = [5,5]
        ctx?.setLineDash(phase: 0, lengths: arr)
        ctx?.drawPath(using: .stroke)
        
        //白色圆点
        let mpt = minPoints[currentIndex]
        ctx?.setFillColor(UIColor(white: 1, alpha: 1).cgColor)
        ctx?.fillEllipse(in: CGRect(x: pt.x-3, y: pt.y-3, width: 6, height: 6))
        ctx?.fillEllipse(in: CGRect(x: mpt.x-3, y: mpt.y-3, width: 6, height: 6))
        ctx?.drawPath(using: .fill)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let pt = touches.first?.location(in: self)
        currentIndex = Int((pt?.x)!/CGFloat(screenWidth/5))+1
        self.setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let pt = touches.first?.location(in: self)
        currentIndex = Int((pt?.x)!/CGFloat(screenWidth/5))+1
        self.setNeedsDisplay()
    }
    
    //MARK: - private
    func getDateName(index: Int) -> String {
        let aqi = recentData?.recentAQIs[index]
        let min = String(format: "%d", aqi?.aqiMin ?? 0)
        let max = String(format: "%d", aqi?.aqiMax ?? 0)
        var dateName = ""
        switch index {
        case 0:
            dateName = NSLocalizedString("Yesterday", comment: "")+"\n"+max+"\n"+min
            break
        case 1:
            dateName = NSLocalizedString("Today", comment: "")+"\n"+max+"\n"+max
            break
        case 2:
            dateName = NSLocalizedString("Tomorrow", comment: "")+"\n"+max+"\n"+min
            break
        case 3:
            dateName = (aqi?.dateStrWithShort() ?? "")+"\n"+max+"\n"+min
            break
        case 4:
            dateName = (aqi?.dateStrWithShort() ?? "")+"\n"+max+"\n"+min
            break
        case 5:
            dateName = (aqi?.dateStrWithShort() ?? "")+"\n"+max+"\n"+min
            break
        default:
            dateName = ""
        }
        
        return dateName
    }

}
