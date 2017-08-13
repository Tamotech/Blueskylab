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
    
    var modes: [WindModeModel] = []
    var scrollView: UIScrollView = UIScrollView()
    var childCompoents: [WindModeAjustor] = []
    var currentMode: WindMode = .WindModeSport
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
        let modes: [WindMode] = [WindMode.WindModeIntelligent,
                                 WindMode.WindModeWalk,
                                 WindMode.WindModeSport,
                                 WindMode.WindModeDrive,
                                 WindMode.WindModeRest,
                                 WindMode.WindModeAdd]
        var i = 0
        for mode in modes {
            
            let ajustor = WindModeAjustor(frame: .zero, mode: mode)
            ajustor.delegate = self
            childCompoents.append(ajustor)
            scrollView.addSubview(ajustor)
            
            if i == 0 {
                ajustor.snp.makeConstraints({ (make) in
                    make.left.equalTo(leftSpace)
                    make.centerY.equalTo(self.scrollView.snp.centerY)
                    make.width.height.equalTo(width1)
                })
            }
            else {
                let lastView = childCompoents[i-1]
                ajustor.snp.makeConstraints({ (make) in
                    make.left.equalTo(lastView.snp.right).offset(leftSpace)
                    make.centerY.equalTo(self.scrollView.snp.centerY)
                    make.width.height.equalTo(width1)
                    if i == modes.count - 1 {
                        make.right.equalTo(self.scrollView.right).offset(-leftSpace)
                    }
                })
                
            }
            i = i + 1
        }
        
        let scrollSizeWidth = CGFloat(childCompoents.count - 1)*width1+width2+CGFloat(childCompoents.count+1)*leftSpace
        scrollView.contentSize = CGSize(width: scrollSizeWidth, height: frame.size.height)
        
//        //TODO
        self.refreshItemViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    //MARK: - ajustorDelegate
    
    func selectItem(mode: WindMode) {
        currentMode = mode
        refreshItemViews()
    }
    
    
    //MARK: - private
    
    func refreshItemViews() {
        
        if childCompoents.count == 0 {
            return
        }
        if (currentMode == WindMode.WindModeAdd) {
            // click add
            if delegate != nil {
                delegate?.clickAddMode()
            }
            
            return
        }
        for ajustorView in childCompoents {
            
            if ajustorView.mode == currentMode {
                ajustorView.snp.updateConstraints({ (make) in
                    make.width.height.equalTo(self.width2)
                })
            }
            else {
                ajustorView.snp.updateConstraints({ (make) in
                    make.width.height.equalTo(self.width1)
                })
            }
        }
        UIView.animate(withDuration: 0.3) {
            for ajustorView in self.childCompoents {
                ajustorView.transformToSmall(smallMode: (ajustorView.mode != self.currentMode))
            }
            self.layoutIfNeeded()
        }
    }
}
