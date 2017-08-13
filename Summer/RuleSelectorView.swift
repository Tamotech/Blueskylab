//
//  RuleSelectorView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/6/24.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import SnapKit

typealias selectRulerCallback = (CGFloat)->()
class RuleSelectorView: UIView, UIScrollViewDelegate {

    var selectedValueAction:selectRulerCallback?
    var cellLength:Int = 1        // 一格的长度
    var totalLength:Int = 200     // 总长度
    var cellRuleCount:Int = 10        // 一格分为多少小格
    let rulerGap:CGFloat = 10          // 最小刻度宽度
    var scrollView:UIScrollView
    var rulerColor:UIColor
    var currentValue: CGFloat = 0
    lazy var rulerLayer:CAShapeLayer = {
        () -> CAShapeLayer in
        let layer = CAShapeLayer()
        return layer
    }()
    
    override init(frame: CGRect) {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        rulerColor = UIColor(ri: 220, gi: 220, bi: 220)!
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, cellLength: Int, totalLength:Int, cellRuleCount:Int, defaultValue:CGFloat, tintColor: UIColor) {
        self.init(frame: frame)
        self.currentValue = defaultValue
        self.rulerColor = tintColor
        self.tintColor = tintColor
        self.cellLength = cellLength
        self.totalLength = totalLength
        let width = CGFloat(totalLength*cellRuleCount*cellLength)*rulerGap
        self.scrollView.contentSize = CGSize(width: width, height: frame.size.height)
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.delegate = self
        self.addSubview(scrollView)
        self.drawRuler(defaultValue: defaultValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawRuler(defaultValue: CGFloat) {
        self.rulerLayer.frame = self.scrollView.bounds
        self.rulerLayer.strokeColor = self.rulerColor.cgColor
        self.rulerLayer.lineWidth = 1
        let longRulerLayer = CAShapeLayer()
        longRulerLayer.strokeColor = self.rulerColor.cgColor
        longRulerLayer.frame = self.rulerLayer.bounds
        longRulerLayer.lineWidth = 2
        self.rulerLayer.addSublayer(longRulerLayer)
        let path1 = UIBezierPath()
        let path2 = UIBezierPath()
        let top:CGFloat = 10
        let shortRulerHeight:CGFloat = 16
        let longRulerHeight:CGFloat = 30
        path1.move(to: CGPoint(x: 0, y: top))
        path1.addLine(to: CGPoint(x: self.scrollView.contentSize.width, y: top))
        for i in 0..<totalLength*cellRuleCount*cellLength {
            let x = CGFloat(i)*rulerGap
            if i % self.cellRuleCount == 0 && (i != 0 && i != totalLength*cellRuleCount*cellLength-1){
                path2.move(to: CGPoint(x: x, y: top))
                path2.addLine(to: CGPoint(x: x, y: top+longRulerHeight))
                let label = UILabel()
                label.text = String(i/cellRuleCount)
                label.sizeToFit()
                label.font = UIFont.systemFont(ofSize: 15)
                label.textColor = tintColor
                label.center = CGPoint(x: x, y: top+longRulerHeight+15)
                self.scrollView.addSubview(label)
            }
            else if i % (self.cellRuleCount/2) == 0 {
                path2.move(to: CGPoint(x: x, y: top))
                path2.addLine(to: CGPoint(x: x, y: top+shortRulerHeight))
            }
            else{
                path1.move(to: CGPoint(x: x, y: top))
                path1.addLine(to: CGPoint(x: x, y: top+shortRulerHeight))
            }
            
        }
        self.rulerLayer.path = path1.cgPath
        longRulerLayer.path = path2.cgPath
        self.scrollView.layer.addSublayer(self.rulerLayer)
        
        //中心刻度
        let centerLine = UIView(frame: CGRect(x: self.centerX-1, y: top+0.5, width: 2, height: longRulerHeight))
        centerLine.backgroundColor = self.tintColor
        self.addSubview(centerLine)
        
        //计算默认的刻度位置
        let centerX = defaultValue*CGFloat(self.cellLength)*CGFloat(self.cellRuleCount)*self.rulerGap-self.scrollView.width/2
        self.scrollView.contentOffset = CGPoint(x: centerX, y: 0)
    }
    

    //MARK:- scrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        self.handleScrollOffsetChangeAction(offset: offset, end: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        self.handleScrollOffsetChangeAction(offset: offset, end:false)
    }
    
    
    /// 根据scroll的滚动计算刻度位置
    ///
    /// - Parameter offset: offset
    /// - Parameter end: 停止滚动强制取整
    func handleScrollOffsetChangeAction(offset:CGPoint, end:Bool) {
        
        let centerValue = CGFloat(Int(offset.x+self.scrollView.width/2)/Int(self.rulerGap))/CGFloat(self.cellRuleCount)
        let newOffsetX = centerValue*CGFloat(self.cellRuleCount)*self.rulerGap-self.scrollView.width/2
        let offset1 = CGPoint(x: newOffsetX, y:offset.y)
        if end {
            scrollView.contentOffset = offset1
        }
        //计算刻度值
        if self.selectedValueAction != nil {
            self.selectedValueAction!(centerValue)
        }
        self.currentValue = centerValue

    }
}
