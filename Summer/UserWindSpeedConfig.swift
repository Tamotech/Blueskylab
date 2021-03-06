//
//  UserWindSpeedConfig.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/22.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import HandyJSON

let maxWindSpeedValue: Int = 100

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
    var name_en: String = ""
    var value: Int = 0
    var type: String = ""
    var defaultflag: Int = 0
    ///档速
    var gear: Int = 0
    ///风速最大值
    var valueMax: Int = 0
    
    var valueMin: Int = 0
    ///风速最大值对应档速
    var gearMax: Int = 0
    ///风速最小值对应的档速
    var gearMin: Int = 0
    
    
    /// 是否是添加模式
    var isAdd: Bool = false
    
    func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &icon1, name: "icon_db")
        mapper.specify(property: &icon2, name: "icon_lb")
        mapper.specify(property: &icon3, name: "icon_sl")
        mapper.specify(property: &icon4, name: "icon_wt")
        mapper.specify(property: &valueMax, name: "value_max")
        mapper.specify(property: &gearMax, name: "gear_max")
        mapper.specify(property: &gearMin, name: "gear_min")
        mapper.specify(property: &valueMin, name: "value_min")
    }
    
    required init() {}
    
    ///返回多语言名称
    func getName() -> String {
        if SessionManager.sharedInstance.language == "en_US" {
            return name_en
        }
        return name
        
    }
    
    
    func add(success: @escaping (Bool, String)->()) {
        let path = "/maskwindspeedset/addUserCfg.htm"
        let hideFlagStr = (hideflag == 1 ? "true" : "false")
        let params = ["customname": name,
                      "value": value,
                      "hideflag": hideFlagStr] as [String : Any]
        
        APIManager.shareInstance.postRequest(urlString: path, params: params) { (JSON, code, msg) in
            self.id = JSON!["id"].stringValue
            success(code == 0, msg)
        }
    }
    
    func update(success: @escaping (Bool, String)->()) {
        let path = "/maskwindspeedset/updateUserCfg.htm"
        var params = ["id": id,
                      "value": value,
                      "defaultflag": defaultflag,
                      "hideflag": hideflag] as [String : Any]
        if type != "fixed" {
            //固定配置 不能修改名称
            params["customname"] = name
        }
        
        APIManager.shareInstance.postRequest(urlString: path, params: params) { (JSON, code, msg) in
            success(code == 0, msg)
        }
    }

    func delete(success: @escaping (Bool, String)->()) {
        let path = "/maskwindspeedset/deleteUserCfg.htm"
        let params = ["id": id] as [String : Any]
        
        APIManager.shareInstance.postRequest(urlString: path, params: params) { (JSON, code, msg) in
            success(code == 0, msg)
        }
    }
    
    
    /// 获取文字首字生成的图片
    ///
    /// - Parameter color: 文字颜色
    /// - Returns: 图片
    func customIcon(color: UIColor) -> UIImage {
        return UIImage.image(name, size: (50, 50), backColor: UIColor.clear, textColor: color, isCircle: false)!
    }
}
