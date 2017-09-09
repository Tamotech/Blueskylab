//
//  WindModeManager.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/22.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

typealias CompleteLoadModeConfig = ()->()

class WindModeManager: NSObject {

    var windUserConfigList: [UserWindSpeedConfig] = []
    var completeLoadModeConfig: CompleteLoadModeConfig?
    var currentMode: UserWindSpeedConfig?
    
    override init() {
        super.init()
    }
    
    func loadData() {
        
        if SessionManager.sharedInstance.token.characters.count == 0 {
            return
        }
        APIRequest.getUserWindSpeedConfig { [weak self](data) in
            self?.windUserConfigList = data as! [UserWindSpeedConfig]
            
            //常用模式置顶
            if self?.windUserConfigList.count ?? 0 > 0 {
                for (i, co) in (self?.windUserConfigList)!.enumerated() {
                    if i != 0 &&  co.defaultflag == 1 {
                        let top = self?.windUserConfigList[0]
                        self?.windUserConfigList[0] = (self?.windUserConfigList[i])!
                        self?.windUserConfigList[i] = top!
                    }
                }
            }
            if self?.completeLoadModeConfig != nil {
                self?.completeLoadModeConfig!()
            }
        }
    }
    
    
    /// 当前模式
    ///
    /// - Returns: 模式
    func getCurrentMode() -> UserWindSpeedConfig {
        if windUserConfigList.count == 0 {
            let config = UserWindSpeedConfig()
            config.type = "fixed"
            config.name = "智能模式"
            currentMode = config
            return config
        }
        if currentMode == nil {
            currentMode = windUserConfigList.first
        }
        return currentMode!
    }
    
    ///将该模式置顶
    func bringToTop(config: UserWindSpeedConfig) {
        for (i, co) in windUserConfigList.enumerated() {
            if co.id == config.id {
                let top = windUserConfigList[0]
                windUserConfigList[0] = windUserConfigList[i]
                windUserConfigList[i] = top
                windUserConfigList[0].defaultflag = 1
                windUserConfigList[i].defaultflag = 0
                windUserConfigList[0].update(success: { (success, msg) in
                    
                })
                if i != 0 {
                    windUserConfigList[i].update(success: { (success, msg) in
                        
                    })
                }
            }
        }
    }
    
    ///选择一个非隐藏的模式为当前模式
    func resetCurrentMode() {
        for mode in windUserConfigList {
            if mode.hideflag == 0 {
                currentMode = mode
                break
            }
        }
    }
}
