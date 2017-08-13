//
//  BaseActionSheetView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/6/29.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import SnapKit

class BaseActionSheetView: UIView {

    
    let animationTime:TimeInterval = 0.3
    let sheetHeight: CGFloat = 270
    let bgView: UIView! = UIView(frame: UIScreen.main.bounds)
    let containerView: UIView! = UIView()
    let confirmBtn: UIButton! = UIButton()
    let cancelButton: UIButton! = UIButton()
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
    
    init(customView: UIView!, titleString: String?) {
        super.init(frame: UIScreen.main.bounds)
        bgView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        bgView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapBgView(_:)))
        bgView.addGestureRecognizer(tap)
        self.addSubview(bgView)
        
        containerView.backgroundColor = .white
        self.addSubview(containerView)
        containerView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: sheetHeight)
        
        let line = UIView()
        line.backgroundColor = gray232
        containerView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(55)
            make.height.equalTo(1)
        }
        
        confirmBtn.setTitleColor(themeColor, for: .normal)
        confirmBtn.setTitle(NSLocalizedString("Confirm", comment: ""), for: .normal)
        confirmBtn.addTarget(self, action: #selector(handleTapConfirmBtn(_:)), for: .touchUpInside)
        containerView.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 80, height: 55))
            make.right.top.equalTo(0)
        }
        
        cancelButton.setTitleColor(gray155, for: .normal)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        cancelButton.addTarget(self, action: #selector(handleTapCancelBtn(_:)), for: .touchUpInside)
        containerView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 80, height: 55))
            make.top.left.equalTo(0)
        }
        
        if titleString != nil {
            let titleLabel = UILabel()
            titleLabel.textColor = gray72
            titleLabel.font = UIFont.systemFont(ofSize: 17)
            titleLabel.textAlignment = .center
            titleLabel.text = titleString!
            containerView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints({ (make) in
                make.top.equalTo(0)
                make.left.equalTo(cancelButton.right)
                make.right.equalTo(confirmBtn.left)
                make.height.equalTo(55)
            })
        }
        
        containerView.addSubview(customView)
        customView.clipsToBounds = true
        customView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(55)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        keyWindow?.addSubview(self)
        self.bgView.alpha = 0
        
        UIView.animate(withDuration: animationTime, animations: {
            self.bgView.alpha = 1
            self.containerView.bottom = self.height
        }) { (finish) in
            
        }
    }
    
    func dismiss() {
        
        UIView.animate(withDuration: animationTime, animations: {
            self.bgView.alpha = 0
            self.containerView.top = screenHeight
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
    
    //MARK: actions
    func handleTapBgView(_:UITapGestureRecognizer) {
        self.dismiss()
    }
    
    func handleTapCancelBtn(_:UIButton) {
        self.dismiss()
    }
    
    func handleTapConfirmBtn(_:UIButton) {
        self.dismiss()
    }


}
