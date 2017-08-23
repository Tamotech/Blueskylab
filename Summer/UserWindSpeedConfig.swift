//
//  UserWindSpeedConfig.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/22.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import HandyJSON

class UserWindSpeedConfig: HandyJSON {

/*
 "hideflag": 0,
 "id": "cb59be35-8fa6-4ab3-8773-854af41bb80c",
 "icon": "upload/files/default/image/201708/6e3c2d6c-28bf-425f-a96a-14e6dbaffe81.png",
 "defvalue": 60,
 "name": "智能",
 "sortid": 1502126227597,
 "value": 60,
 "type": "fixed",
 "defaultflag": 1*/
    
    var hideflag: Int = 0
    var id: String = ""
    ///深蓝
    var icon1: String = ""
    ///淡蓝
    var icon2: String = ""
    ///白色选中
    var icon3: String = ""
    ///白色
    var icon4: String = ""
    var defvalue: Int = 0
    var name: String = ""
    var value: Int = 0
    var type: String = ""
    var defaultflag: Int = 0
    
    
    /// 是否是添加模式
    var isAdd: Bool = false
    
    func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &icon1, name: "icon_db")
        mapper.specify(property: &icon2, name: "icon_lb")
        mapper.specify(property: &icon3, name: "icon_sl")
        mapper.specify(property: &icon4, name: "icon_wt")
    }
    
    required init() {}
}
