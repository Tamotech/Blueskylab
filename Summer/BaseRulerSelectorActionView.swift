//
//  BaseRulerSelectorActionView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/6/25.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import SnapKit

private let viewHeight:CGFloat = 375

typealias FinishSelectValue = (CGFloat) -> ()

/// 带有刻度编辑的actionSheet
class BaseRulerSelectorActionView: UIView {

    var containerView:UIView!
    var bgView:UIView!
    var closeBtn:UIButton!
    var titleLabel:UILabel!
    var valueLabel:UILabel!     //数值
    var unitLabel:UILabel!      //单位
    var ruler:RuleSelectorView!
    var confirmBtn:UIButton!
    let animationTime = 0.2
    var finishSelectAction: FinishSelectValue?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    convenience init(title:String, unit:String, defaultValue:CGFloat) {
        
        self.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.clear
        
        self.bgView = UIView()
        self.bgView.backgroundColor = translucentBGColor
        self.addSubview(self.bgView)
        self.bgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        
        self.containerView = UIView(frame: CGRect(x: 0, y: self.height, width: self.width, height: viewHeight))
        self.containerView.backgroundColor = UIColor.white
        self.addSubview(self.containerView)
        
        self.closeBtn = UIButton()
        closeBtn.setImage(UIImage(named: "close_gray"), for: .normal)
        self.closeBtn.addTarget(self, action: #selector(handleTapCloseBtn(_:)), for: .touchUpInside)
        self.containerView.addSubview(self.closeBtn)
        self.closeBtn.snp.makeConstraints { (make) in
            make.left.top.equalTo(0)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        
        self.titleLabel = UILabel()
        self.titleLabel.text = title
        self.titleLabel.textColor = gray72
        self.titleLabel.font = UIFont.systemFont(ofSize: 17)
        self.titleLabel.textAlignment = .center
        self.titleLabel.sizeToFit()
        self.containerView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.containerView.centerX)
            make.top.equalTo(18)
        }
        
        let totalLength = 250
        let cellLength = 1
        self.ruler = RuleSelectorView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 100), cellLength: cellLength, totalLength: totalLength, cellRuleCount: 10, defaultValue:defaultValue, tintColor: gray155!)
        self.containerView.addSubview(self.ruler)
        self.ruler.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.centerY.equalTo(self.containerView.height/2+30)
            make.size.equalTo(CGSize(width: screenWidth, height: 100))
        }
        
        self.valueLabel = UILabel()
        self.valueLabel.textColor = gray72
        self.valueLabel.text = String.init(format: "%.1f", defaultValue)
        self.valueLabel.font = UIFont.boldSystemFont(ofSize: 36)
        self.valueLabel.textAlignment = .center
        self.containerView.addSubview(self.valueLabel)
        self.valueLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.ruler.snp.top).offset(-15)
            make.centerX.equalTo(self.ruler.centerX)
            make.height.equalTo(40)
            make.width.greaterThanOrEqualTo(40)
        }
        
        self.unitLabel = UILabel()
        self.unitLabel.textColor = gray155
        self.unitLabel.text = unit
        self.unitLabel.textAlignment = .center
        self.containerView.addSubview(self.unitLabel)
        self.unitLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.valueLabel.snp.bottom).offset(-4)
            make.left.equalTo(self.valueLabel.snp.right)
            make.height.equalTo(20)
        }
        
        self.confirmBtn = UIButton()
        self.confirmBtn.setTitle(NSLocalizedString("Confirm", comment: "default"), for: .normal)
        self.confirmBtn.setTitleColor(UIColor.white, for: .normal)
        self.confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.confirmBtn.addTarget(self, action: #selector(handleTapConfirmBtn(_:)), for: .touchUpInside)
        self.confirmBtn.backgroundColor = themeColor
        self.confirmBtn.layer.cornerRadius = 22
        self.confirmBtn.layer.shadowColor = gray155?.cgColor
        self.confirmBtn.layer.shadowRadius = 3
        self.confirmBtn.layer.shadowOpacity = 0.6
        self.confirmBtn.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.containerView.addSubview(self.confirmBtn)
        self.confirmBtn.snp.makeConstraints { (make) in
            make.left.equalTo(25)
            make.right.equalTo(-25)
            make.bottom.equalTo(-30)
            make.height.equalTo(44)
        }
        
        self.ruler.selectedValueAction = {(value:CGFloat) in
            print(value)
            self.valueLabel.text = value.description
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        keyWindow?.addSubview(self)
        self.bgView.alpha = 0
        
        UIView.animate(withDuration: animationTime, animations: {
            self.containerView.frame = CGRect(x: 0, y: self.height-viewHeight, width: screenWidth, height: viewHeight)
            self.bgView.alpha = 1
        }) { (finish) in
            
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: animationTime, animations: {
            self.bgView.alpha = 0
            self.containerView.frame = CGRect(x: 0, y: self.height, width: screenWidth, height: viewHeight)
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
    //MARK: actions
    func handleTapCloseBtn(_:UIButton) {
        self.dismiss()
    }
    
    func handleTapConfirmBtn(_:UIButton) {
        if self.finishSelectAction != nil {
            self.finishSelectAction!(self.ruler.currentValue)
        }
        self.dismiss()
    }
}
