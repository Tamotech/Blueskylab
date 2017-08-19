//
//  BaseAlertView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/16.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class BaseAlertView: BaseView {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var descButton: UIButton!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.layer.cornerRadius = 10

    }
    
    
    /// 设置弹窗样式
    ///
    /// - Parameters:
    ///   - msg: 描述
    ///   - img: 图片
    ///   - actionTitle: 底部按钮文字
    ///   - needClose: 是否需要close
    public func setupView(msg: String?, img: UIImage?, actionTitle: String?, needClose: Bool) {
        if img != nil {
            imageView.image = img
            imageView.isHidden = false
        }
        else {
            imageView.isHidden = true
        }
        if msg != nil {
            messageLabel.text = msg
            messageLabel.isHidden = false
        }
        else {
            messageLabel.isHidden = true
        }
        
        if actionTitle != nil {
            descButton.setTitle(actionTitle!, for: .normal)
        }
        closeButton.isHidden = !needClose
    }
    
    public func show(autodismiss: Bool, transparent: Bool) {
        let bgView = UIView()
        bgView.frame = UIScreen.main.bounds
        if transparent {
            bgView.backgroundColor = UIColor.clear
        }
        else {
            bgView.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        }
        self.center = keyWindow!.center
        bgView.addSubview(self)
        keyWindow!.addSubview(bgView)
        
    }
    
    public func dismiss() {
        self.superview?.removeFromSuperview()
    }
    
    @IBAction func handleTapCloseButton(_ sender: UIButton) {
        self.dismiss()
    }
 
    @IBAction func handleTapDescButton(_ sender: UIButton) {
        self.dismiss()
    }
}
