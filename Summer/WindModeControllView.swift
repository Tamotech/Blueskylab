//
//  WindModeControllView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/10.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import AMPopTip

protocol WindModeSelectDelegate: class {
    
    func clickAddMode()
    func defaultModeDidChange(mode: UserWindSpeedConfig)
}

//模式控制面板
class WindModeControllView: UIView, WindModeAjustorDelegate {
    
    var modeManager: WindModeManager = SessionManager.sharedInstance.windModeManager
    var scrollView: UIScrollView = UIScrollView()
    var childCompoents: [WindModeAjustor] = []
    //var currentMode: UserWindSpeedConfig = UserWindSpeedConfig()
    let leftSpace: CGFloat = 25
    let width1: CGFloat = 62
    let width2: CGFloat = 146
    weak var delegate: WindModeSelectDelegate?
    //10-06砍掉的需求
//    lazy var addAjustor: WindModeAjustor = {
//
//        let addConfig = UserWindSpeedConfig()
//        addConfig.id = "addModeId"
//        addConfig.isAdd = true
//        let a = WindModeAjustor(frame: CGRect.init(x: 0, y: 0, width: 62, height: 62), mode: addConfig)
//        return a
//    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        self.addSubview(scrollView)
        
//        addAjustor.delegate = self
//        scrollView.addSubview(addAjustor)
    
        modeManager.completeLoadModeConfig = {[weak self]() in
            self?.refreshItemViews()
            if self?.delegate != nil {
                self?.delegate?.defaultModeDidChange(mode:
                    (self?.modeManager.getCurrentMode())!)
                self?.selectItem(mode: (self?.modeManager.getCurrentMode())!)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleModeDidChangeNoti(n:)), name: kWindModeConfigDidChangeNotify, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReceiveDeleteModeNoti(n:)), name: kWindModeConfigDidDeleteNotify, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleChangeCommenMode(n:)), name: kWindModeConfigDidChangeOrderNotify, object: nil)

        SessionManager.sharedInstance.windModeManager = modeManager
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - ajustorDelegate
    
    func selectItem(mode: UserWindSpeedConfig) {
        modeManager.currentMode = mode
        if mode.isAdd {
            if delegate != nil {
                delegate?.clickAddMode()
            }
        }
        else {
            refreshItemViews()
        }
        
        if mode.name == NSLocalizedString("Intelligence", comment: "") {
            BLSBluetoothManager.shareInstance.switchToIntelligenceModeForMask()
        }
        else {
            BLSBluetoothManager.shareInstance.ajustSpeed(mode: mode)
        }
    }
    
    func hideItem(item: WindModeAjustor) {
        
        
        if modeManager.getCurrentMode().id != item.mode.id {
            
            //防止重复弹窗
            for v in self.subviews {
                if v is PopTip {
                    return;
                }
            }
            let popTip = PopTip()
            popTip.padding = 4
            popTip.cornerRadius = 6
            popTip.shouldShowMask = true
            popTip.maskColor = UIColor.init(white: 0, alpha: 0.1)
            popTip.bubbleColor = UIColor.white
            popTip.textColor = themeColor!
            popTip.edgeMargin = 10
            popTip.tapHandler = {[weak self](popTip)in
                //隐藏
                let index = self?.childCompoents.index(of: item)
                item.removeFromSuperview()
                ///Notice: 此处 item.mode 与 modemanager 中的 mode 可能数据源不匹配,因为 modeManager 数据更新后没有同步到 Ajustor 中
                item.mode.hideflag = 1
                for m in (self?.modeManager.windUserConfigList)! {
                    if m.id == item.mode.id {
                        m.hideflag = 1
                        break
                    }
                }
                
                if item.mode.id == self?.modeManager.getCurrentMode().id {
                    //重新选择一个默认模式
                    self?.modeManager.resetCurrentMode()
                }
                self?.childCompoents.remove(at: index!)
                self?.refreshItemViews()
            }
            let frame = self.convert(item.frame, from: item.superview)
            popTip.show(text: NSLocalizedString("Hide", comment: ""), direction: .down, maxWidth: 120, in: self, from: frame)
            
        }
    }
    
    
    
    //MARK: - notification
    func handleModeDidChangeNoti(n: Notification) {
        refreshItemViews()
    }
    
    func handleReceiveDeleteModeNoti(n: Notification) {
        let dic = n.object as? [String: String]
        if dic != nil {
            let id = dic!["id"]
            var index = 0
            for com in childCompoents {
                if com.mode.id == id {
                    com.removeFromSuperview()
                    childCompoents.remove(at: index)
                    return
                }
                index = index+1
            }
        }
    }
    
    ///改变常用模式
    func handleChangeCommenMode(n: Notification) {
        //常用模式提前
        if modeManager.windUserConfigList.first?.id != childCompoents.first?.mode.id && modeManager.windUserConfigList.first?.defaultflag == 1 {
            for (i, co) in childCompoents.enumerated() {
                if co.mode.defaultflag == 1 && i != 0 {
                    swap(&childCompoents[i], &childCompoents[0])
                    break
                }
            }
            refreshItemViews()
        }
    }
    
    
    //MARK: - private
    
    func refreshItemViews() {
        
//        if modeManager.windUserConfigList.count == 0 {
//            addAjustor.snp.remakeConstraints({ (make) in
//                make.left.equalTo(self.scrollView.snp.left).offset(leftSpace)
//                make.centerY.equalTo(self.scrollView.snp.centerY)
//                make.width.height.equalTo(width1)
//                make.right.equalTo(self.scrollView.snp.right).offset(-leftSpace)
//            })
//            addAjustor.transformToSmall(smallMode: true)
//            return
//        }
        
        //if childCompoents.count == 0 {
            
        for mode in modeManager.windUserConfigList {
          
            if mode.valueMax<mode.value {
                mode.value = mode.valueMax
            }
            if mode.hideflag != 1 && !self.containsMode(mode: mode) {
                let ajustor = WindModeAjustor(frame: .zero, mode: mode)
                ajustor.delegate = self
                childCompoents.append(ajustor)
                scrollView.addSubview(ajustor)
            }
            else if mode.hideflag == 1 && self.containsMode(mode: mode) {
                //移除
                self.removeComponent(mode: mode)
            }
            else {
                //更新模式视图
                for ajustor in childCompoents {
                    if ajustor.mode.id == mode.id {
                        ajustor.updateView(config: mode)
                    }
                }
            }
            if mode.id == modeManager.getCurrentMode().id {
                if delegate != nil {
                    delegate?.defaultModeDidChange(mode: mode)
                }
            }
            
        }
        
        var i = 0
        for ajustor in childCompoents {
            if i == 0 {
                ajustor.snp.remakeConstraints({ (make) in
                    make.left.equalTo(leftSpace)
                    make.centerY.equalTo(self.scrollView.snp.centerY)
                    if ajustor.mode.id == modeManager.getCurrentMode().id {
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
                    
                    if ajustor.mode.id == modeManager.getCurrentMode().id {
                        make.width.height.equalTo(width2)
                    }
                    else {
                        make.width.height.equalTo(width1)
                    }
                })
            }
            i = i + 1
            ajustor.setAngle(value: ajustor.mode.value)
            

        }
        
        //addAjustor  10-06 砍掉的需求
//        let lastView = childCompoents.last!
//        addAjustor.snp.remakeConstraints({ (make) in
//            make.left.equalTo(lastView.snp.right).offset(leftSpace)
//            make.centerY.equalTo(self.scrollView.snp.centerY)
//            make.width.height.equalTo(width1)
//            make.right.equalTo(self.scrollView.snp.right).offset(-leftSpace)
//        })
//        addAjustor.transformToSmall(smallMode: true)
        
        let scrollSizeWidth = CGFloat(childCompoents.count-1)*width1+width2+CGFloat(childCompoents.count+2)*leftSpace
        scrollView.contentSize = CGSize(width: scrollSizeWidth, height: frame.size.height)
        
    
        UIView.animate(withDuration: 0.3) {
            for ajustorView in self.childCompoents {
                ajustorView.transformToSmall(smallMode: (ajustorView.mode.id != self.modeManager.getCurrentMode().id))
            }
            self.layoutIfNeeded()
        }
    }
    
    
    
    /// 判断组件中是否包含该模式
    ///
    /// - Parameter mode: 模式
    /// - Returns: 结果 n
    func containsMode(mode: UserWindSpeedConfig) -> Bool {
        for ajustor in childCompoents {
            if ajustor.mode.id == mode.id {
                return true
            }
        }
        return false
    }
    
    
    /// 移除某一个模式的组件
    ///
    /// - Parameter mode: 模式
    /// - Returns: 成功
    func removeComponent(mode: UserWindSpeedConfig) {
        for ajustor in childCompoents {
            if ajustor.mode.id == mode.id {
                self.childCompoents.remove(at: self.childCompoents.index(of: ajustor)!)
                ajustor.removeFromSuperview()
                return
            }
        }
    }
}
