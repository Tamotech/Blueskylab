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
    /// - Returns: (等级, 笑脸图标, 背景图)
    func maskFilterLevel() -> (String, UIImage?, UIImage?) {
        switch filtereffect {
        case "l1":
            let path = Bundle.main.path(forResource: "main-bg1", ofType: "png")
            let img = UIImage(contentsOfFile: path!)
            return (NSLocalizedString("FilterLevelI", comment: ""),
                    #imageLiteral(resourceName: "face1"),
                    img)
        case "l2":
            let path = Bundle.main.path(forResource: "main-bg5", ofType: "png")
            let img = UIImage(contentsOfFile: path!)
            return (NSLocalizedString("FilterLevelII", comment: ""),
                    #imageLiteral(resourceName: "face2"),
                    img)
        case "l3":
            let path = Bundle.main.path(forResource: "main-bg6", ofType: "png")
            let img = UIImage(contentsOfFile: path!)
            return (NSLocalizedString("FilterLevelIII", comment: ""),
                    #imageLiteral(resourceName: "face3"),
                    img)
        default:
            return ("", nil, nil)
        }
    }
    
    
}
