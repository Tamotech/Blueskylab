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
    
    override init() {
        super.init()
    }
    
    func loadData() {
        
        if SessionManager.sharedInstance.token.characters.count == 0 {
            return
        }
        APIRequest.getUserWindSpeedConfig { [weak self](data) in
            self?.windUserConfigList = data as! [UserWindSpeedConfig]
            if self?.completeLoadModeConfig != nil {
                self?.completeLoadModeConfig!()
            }
        }
    }
    
    
    /// 获取默认的模式
    ///
    /// - Returns: 模式
    func getDefaultMode() -> UserWindSpeedConfig {
        if windUserConfigList.count == 0 {
            let config = UserWindSpeedConfig()
            config.type = "fixed"
            config.name = "智能模式"
            return config
        }
        for config in windUserConfigList {
            if config.defaultflag == 1 {
                return config
            }
        }
        return windUserConfigList.first!
    }
}
