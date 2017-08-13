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
        closeButton.isHidden = !needClose
    }
    
    public func show(autodismiss: Bool, bgAlpha: CGFloat) {
        let bgView = UIView()
        bgView.frame = UIScreen.main.bounds
        bgView.backgroundColor = UIColor(white: 0, alpha: 0)
        
        
    }
    
    public func dismiss() {
        
    }
    
    @IBAction func handleTapCloseButton(_ sender: UIButton) {
        self.dismiss()
    }
 
    @IBAction func handleTapDescButton(_ sender: UIButton) {
        
    }
}
