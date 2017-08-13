//
//  WXActionSheetView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/6/21.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

typealias selectItemCallback = (Int, String) ->()


/// 自定义的actionSheet选择器
class WXActionSheetView: UIView {

    
    var bgView:UIView!
    var containerView:UIScrollView!
    var itemButtons:Array<UIButton>!
    var titleLabel:UILabel!
    var cancelButton:UIButton!
    var selectItemAction:selectItemCallback?
    let rowHeight:CGFloat = 50
    let titleHeight:CGFloat = 50
    let cancelHeight:CGFloat = 51
    let animationTime:CGFloat = 0.2
    
    init(items:Array<String>, title:String?, cancelTitle:String?) {
        
        super.init(frame:UIScreen.main.bounds)
        bgView = UIView(frame: UIScreen.main.bounds)
        bgView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.addSubview(bgView)
        
        containerView = UIScrollView()
        containerView.backgroundColor = UIColor.white
        self.addSubview(containerView)
        
        itemButtons = []
        
        var y:CGFloat = 0
        if (title != nil) {
            titleLabel = UILabel(frame: CGRect(x: 0, y: y, width: screenWidth, height: titleHeight))
            titleLabel.text = title!
            titleLabel.textColor = UIColor.darkGray
            titleLabel.font = UIFont.systemFont(ofSize: 15)
            titleLabel.textAlignment = .center
            containerView.addSubview(titleLabel)
            y += titleHeight
        }
        for i in 0..<items.count {
            let name = items[i]
            let button = UIButton(frame: CGRect(x: 0, y: y, width: screenWidth, height: rowHeight))
            button.tag = i
            button.setTitle(name, for: UIControlState.normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.setTitleColor(UIColor(ri:72, gi:72, bi:72), for: .normal)
            button.addTarget(self, action: #selector(handleTapButton(button:)), for: UIControlEvents.touchUpInside)
            containerView.addSubview(button)
            
            let line = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 0.5))
            line.backgroundColor = UIColor(ri: 232, gi: 232, bi: 232)
            button.addSubview(line)
            self.itemButtons.append(button)
            y += rowHeight
        }
        if cancelTitle != nil {
            let cancelView = UIView(frame:CGRect(x: 0, y: y, width: screenWidth, height: cancelHeight))
            cancelView.backgroundColor = UIColor(ri: 232, gi: 232, bi: 232)
            containerView.addSubview(cancelView)
            cancelButton = UIButton(frame: CGRect(x: 0, y: 1, width: screenWidth, height: cancelHeight-1))
            cancelButton.tag = -1
            cancelButton.setTitle(cancelTitle, for: .normal)
            cancelButton.setTitleColor(UIColor(ri:155, gi:155, bi:155), for: .normal)
            cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            cancelButton.backgroundColor = UIColor.white
            cancelButton.addTarget(self, action: #selector(handleTapButton(button:)), for: UIControlEvents.touchUpInside)
            cancelView.addSubview(cancelButton)
            y += cancelHeight
        }
        containerView.contentSize = CGSize(width: screenWidth, height: y)
        
        if y > self.height-20 {
            y = self.height-20
        }
        containerView.frame = CGRect(x: 0, y: self.height-y, width: screenWidth, height: y)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func show() {
        keyWindow?.addSubview(self)
        containerView.top = self.height
        bgView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.bgView.alpha = 1
            self.containerView.top = self.height-self.containerView.height
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.8, animations: { 
            self.bgView.alpha = 0
            self.containerView.top = self.height
        }) { (true) in
            self.removeFromSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.dismiss()
        super.touchesBegan(touches, with: event)
    }

    
    //Mark: action
    func handleTapButton(button:UIButton) {
        
        if self.selectItemAction != nil {
            if button.tag > 0 && button.tag < self.itemButtons.count {
                self.selectItemAction!(button.tag, (button.titleLabel?.text)!)
            }
        }
        self.dismiss()
    }
}
