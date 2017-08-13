//
//  BottomWechatShareView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/30.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class BottomWechatShareView: BaseView {

    
    let containerHeight:CGFloat = 186
    @IBOutlet weak var bottonConsttaint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        
    }
    
    func show() {
        
        self.frame = UIScreen.main.bounds
        keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.3) {
            self.bottonConsttaint.constant = 0
            self.backgroundColor = UIColor(white: 0, alpha: 0.5)
            self.layoutIfNeeded()
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: { 
            self.bottonConsttaint.constant = -self.containerHeight
            self.backgroundColor = UIColor(white: 0, alpha: 0)
            self.layoutIfNeeded()

        }) { (success) in
            self.removeFromSuperview()
        }
    }
    
    @IBAction func handleTapWechatBtn(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func handleTapWechatCircleBtn(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func handleCancelBtn(_ sender: Any) {
        self.dismiss()
    }

}
