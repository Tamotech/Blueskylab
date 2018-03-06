//
//  AQIData.swift
//  Summer
//
//  Created by 武淅 段 on 2017/9/15.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import HandyJSON


///某一时刻的 aqi 数据
class AQIData: HandyJSON {

    var datestr: String = ""
    var value: CGFloat = -1
    var max: CGFloat = 0
    var min: CGFloat = 0
    
    required init(){}

    func getDateStr() -> String {
        if datestr.characters.count > 18 {
            let startIndex = datestr.index(datestr.endIndex, offsetBy: -8)
            let str = datestr.substring(from: startIndex)
            let endIndex = str.index(str.endIndex, offsetBy: -3)
            return str.substring(to: endIndex)
        }
        else if datestr.characters.count == 10 {
            let startIndex = datestr.index(datestr.startIndex, offsetBy: 5)
            return datestr.substring(from: startIndex)
        }
        else if datestr.characters.count == 7 {
            let startIndex = datestr.index(datestr.startIndex, offsetBy: 2)
            return datestr.substring(from: startIndex)
        }
        else {
            return datestr
        }
    }
}

///日周月年数据
class AQIDataList: HandyJSON {
    var aqi: [AQIData] = []
    var pm25: [AQIData] = []
    var pm10: [AQIData] = []
    var co: [AQIData] = []
    var no2: [AQIData] = []
    var o3: [AQIData] = []
    var so2: [AQIData] = []
    
    required init(){}
    
    func getAQIData(type: Int) -> ([AQIData], CGFloat) {
        switch type {
        case 0:
            return (pm25, 500)
        case 1:
            return (pm10, 500)
        case 2:
            return (co, 207)
        case 3:
            return (no2, 144)
        case 4:
            return (o3, 150)
        case 5:
            return (so2, 203)
        default:
            return (pm25, 500)
        }
    }
}

///城市 AQI 数据
class CityAQIData: HandyJSON {
/**
     "time": "2017-08-29",
     "aqilevelname": "良",
     "aqilevelcoler": "77B5E5",
     "aqi": 51,
     "temp": 21,
     "aqilevelcode": "l2",
     "pm25": 24,
     "wse": 2.042
 */
    
    var time: String = ""
    var dateStr: String {
        get {
            if time.contains("-") {
                let today = Date().stringOfDay()
                let yesterday = Date().addingTimeInterval(-24*3600).stringOfDay()
                if today == time {
                    return NSLocalizedString("Today", comment: "")
                }
                else if yesterday == time {
                    return NSLocalizedString("Yesterday", comment: "")
                }
                return time.replacingOccurrences(of: "-", with: "/")
            }
            return time
        }
    }
    var aqilevelname = ""
    var aqilevelcoler = ""
    var aqi: CGFloat = -1
    var temp: CGFloat = -1
    var aqilevelcode = ""
    var pm25: CGFloat = -1
    var wse: CGFloat = -1
    
    required init(){}
    
    ///返回n级风
    func windLevelString() -> String {
        let level = Int(wse)
        if level >= 1 && level <= 6 {
            let str = NSLocalizedString("Level\(level)Wind", comment: "")
            return "\(Int(temp))°C  \(str)"
        }
        else if SessionManager.sharedInstance.language == "en_US" {
            return "\(Int(temp))°C  \(level) wind"
        }
        return "\(Int(temp))°C  \(level)级风"
    }
    
}

///城市 AQI 分页查询数据
class CityAQIDataList: HandyJSON {

    var total: Int = 0
    var page: Int = 1
    var list: [CityAQIData] = []
    var rows: Int = 0
    
    
    required init() {}
    
    
}
