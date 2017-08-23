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
        APIRequest.getUserWindSpeedConfig { [weak self](data) in
            self?.windUserConfigList = data as! [UserWindSpeedConfig]
            if self?.completeLoadModeConfig != nil {
                self?.completeLoadModeConfig!()
            }
        }
    }
}
