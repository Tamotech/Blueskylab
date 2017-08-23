//
//  WindModeControllView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/10.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

protocol WindModeSelectDelegate {
    
    func clickAddMode()
}

class WindModeControllView: UIView, WindModeAjustorDelegate {
    
    var modeManager: WindModeManager = WindModeManager()
    var scrollView: UIScrollView = UIScrollView()
    var childCompoents: [WindModeAjustor] = []
    var currentMode: UserWindSpeedConfig = UserWindSpeedConfig()
    let leftSpace: CGFloat = 25
    let width1: CGFloat = 62
    let width2: CGFloat = 146
    var delegate: WindModeSelectDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        self.addSubview(scrollView)
        modeManager.completeLoadModeConfig = {[weak self]() in
            self?.refreshItemViews()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    //MARK: - ajustorDelegate
    
    func selectItem(mode: UserWindSpeedConfig) {
        currentMode = mode
        if mode.isAdd {
            if delegate != nil {
                delegate?.clickAddMode()
            }
        }
        else {
            refreshItemViews()
        }
    }
    
    
    //MARK: - private
    
    func refreshItemViews() {
        
        if modeManager.windUserConfigList.count == 0 {
            return
        }
        
        if childCompoents.count == 0 {
            
            for mode in modeManager.windUserConfigList {
              
                let ajustor = WindModeAjustor(frame: .zero, mode: mode)
                ajustor.delegate = self
                childCompoents.append(ajustor)
                scrollView.addSubview(ajustor)
                
            }
            
            let addConfig = UserWindSpeedConfig()
            addConfig.isAdd = true
            let addAjustor = WindModeAjustor(frame: .zero, mode: addConfig)
            addAjustor.delegate = self
            childCompoents.append(addAjustor)
            scrollView.addSubview(addAjustor)

        }
        
        var i = 0
        for ajustor in childCompoents {
            if i == 0 {
                ajustor.snp.remakeConstraints({ (make) in
                    make.left.equalTo(leftSpace)
                    make.centerY.equalTo(self.scrollView.snp.centerY)
                    if ajustor.mode.id == currentMode.id {
                        make.width.height.equalTo(width2)
                    }
                    else {
                        make.width.height.equalTo(width1)
                    }
                })
            }
            else {
                let lastView = childCompoents[i-1]
                ajustor.snp.remakeConstraints({ (make) in
                    make.left.equalTo(lastView.snp.right).offset(leftSpace)
                    make.centerY.equalTo(self.scrollView.snp.centerY)
                    
                    if i == childCompoents.count - 1 {
                        make.width.height.equalTo(width1)
                        make.right.equalTo(self.scrollView.right).offset(-leftSpace)
                    }
                    else if ajustor.mode.id == currentMode.id {
                        make.width.height.equalTo(width2)
                    }
                    else {
                        make.width.height.equalTo(width1)
                    }
                })
            }
            i = i + 1
            let scrollSizeWidth = CGFloat(childCompoents.count - 1)*width1+width2+CGFloat(childCompoents.count+1)*leftSpace
            scrollView.contentSize = CGSize(width: scrollSizeWidth, height: frame.size.height)

        }
        
        if currentMode.id == "" {
            currentMode = modeManager.windUserConfigList.first!
        }
    
        UIView.animate(withDuration: 0.3) {
            for ajustorView in self.childCompoents {
                ajustorView.transformToSmall(smallMode: (ajustorView.mode.id != self.currentMode.id))
            }
            self.layoutIfNeeded()
        }
    }
}
