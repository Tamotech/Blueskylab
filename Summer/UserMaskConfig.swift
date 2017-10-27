//
//  UserMaskConfig.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/28.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import HandyJSON

/// 用户口罩配置信息
class UserMaskConfig: HandyJSON {

    /**
 "filterchangeflag": false,
 "lowpowerflag": true,
 "pollutionwarnflag": true,
 "productinfoflag": true,
     "language": "zh_CN",   zh_CN:中文  zh_TW:繁体 en_US:英文
 "bindmaskid": "",
"filtereffect": "l1"   l1:一级 l2:二级 l3:三级
     */
    var cityid: Int = -1
    var filterchangeflag = false
    var lowpowerflag = false
    var pollutionwarnflag = false
    var productinfoflag = false
    var language: String = "zh_CN"
    var bindmaskid: String = ""
    var filtereffect: String = ""
    
    
    
    required init() {}
    
    
    
    /// 口罩过滤效果
    ///
    /// - Returns: (等级, 笑脸图标)
    func maskFilterLevel() -> (String, UIImage?) {
        switch filtereffect {
        case "l1":
            return (NSLocalizedString("FilterLevelI", comment: ""),
                    #imageLiteral(resourceName: "face1"))
        case "l2":
            return (NSLocalizedString("FilterLevelII", comment: ""),
                    #imageLiteral(resourceName: "face2"))
        case "l3":
            return (NSLocalizedString("FilterLevelIII", comment: ""),
                    #imageLiteral(resourceName: "face3"))
        default:
            return ("", nil)
        }
    }
    
    
    func updateCityID(cityID: Int) {
        if cityID < 0 {
            return
        }
    }
    
    ///低电量提醒 污染提醒  更换滤芯提醒
    func updateSettingSwitches() {
        
        APIRequest.updateUserConfig(params: ["filterchangeflag": "\(filterchangeflag)", "lowpowerflag":"\(lowpowerflag)", "pollutionwarnflag":"\(pollutionwarnflag)", "productinfoflag":"\(productinfoflag)", "language":"\(language)"])
        
        
        guard (SessionManager.sharedInstance.currentAQI?.cityID) != nil  else {
            return
        }
        var tags = ["\(SessionManager.sharedInstance.currentAQI?.cityID  ?? -1)"]
        if filterchangeflag {
            tags.append("changefilter")
        }
        if lowpowerflag {
            tags.append("lowbattery")
        }
        if pollutionwarnflag {
            tags.append("pollutionalert")
        }
        if productinfoflag {
            tags.append("article")
        }
        tags.append(language)
        
        SessionManager.sharedInstance.pushTags = tags
        SessionManager.sharedInstance.bindPushTags()
    }
    
    ///绑定面罩id
    func bindMask() {
        guard let deviceId = BLSBluetoothManager.shareInstance.deviceUUID else {
            return
        }
        bindmaskid = deviceId
        APIRequest.updateUserConfig(params: ["bindmaskid": deviceId])
    }
    
    
    //保存口罩使用记录
    func saveMaskUseHistory(usetime: Int, distance: Int, step: Int, calories: Int) {
        
        if bindmaskid == "" {
            return
        }
        let path = "/member/saveUseHist.htm?maskid=\(bindmaskid)&usetime=\(usetime)&movedistance=\(distance)&stepnum=\(step)&calorie=\(calories)"
//        let params = ["maskid": bindmaskid,
//                      "usertime": usetime,
//                      "movedistance": distance,
//                      "stepnum": step,
//                      "calorie": calories]
//            as [String : Any]
        APIManager.shareInstance.postRequest(urlString: path, params: nil) { (JSON, code, msg) in
            if code == 0 {
                //保存成功
            }
            else {
                BLHUDBarManager.showError(msg: msg)
            }
        }
    }
    
}
