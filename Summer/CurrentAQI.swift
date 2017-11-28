//
//  CurrentAQI.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/17.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import HandyJSON

class CurrentAQI: HandyJSON {
    
//    "aqi": 38,
//    "idx": 446,
//    "city": "Dongcheng Dongsi",
//    "url": "http://aqicn.org/city/beijing/dongchengdongsi/",
//    "time": "2017-08-03 01:00:00",
//    "pm25": 38,
//    "t": 24,
//    "w": 3.1,
//    "aqilevelcode": "l1",
//    "aqilevelname": "优",
//    "smokenum": 0
    
    var aqi = -1
    var cityID = -1
    var city = ""
    var cityname_en = ""
    var aqiUrl = ""
    var updateTime = ""
    var pm25 = ""
    var temperature = 0.0
    var windSpeed = 0.0
    var aqiLevelCode = ""
    var aqiLevelName = ""
    var smokeNum = 0        //0-5
    
    
    
    func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &cityID, name: "cityid")
        mapper.specify(property: &city, name: "cityname")
        mapper.specify(property: &aqiUrl, name: "url")
        mapper.specify(property: &updateTime, name: "time")
        mapper.specify(property: &temperature, name: "t")
        mapper.specify(property: &windSpeed, name: "w")
        mapper.specify(property: &aqiLevelCode, name: "aqilevel​code")
        mapper.specify(property: &aqiLevelName, name: "aqilevel​name")
        mapper.specify(property: &smokeNum, name: "smokenum")
    }
    
    
    required init() {}
    
    
    
    /// 获取对应空气质量的背景图
    ///
    /// - Returns:  背景图
    func aqiBGImg() -> UIImage? {
        
        var name = ""
        switch aqiLevelCode {
        case "l1":
            name = "main-bg1"
        case "l2":
            name = "main-bg2"
        case "l3":
            name = "main-bg3"
        case "l4":
            name = "main-bg4"
        case "l5":
            name = "main-bg5"
        case "l6":
            name = "main-bg6"
        default:
            name = "main-bg1"
        }
        
        let path = Bundle.main.path(forResource: name, ofType: "png")
        let img = UIImage(contentsOfFile: path!)
        return img
    }
    
}

class SingleDayAQI: HandyJSON {
    
    required init() {}
    
    var aqiMax: Int = 0
    var aqiMin: Int = 0
    var dateStr: String = "01-01"
    
    func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &aqiMax, name: "max")
        mapper.specify(property: &aqiMin, name: "min")
        mapper.specify(property: &dateStr, name: "datestr")
    }
    
    
    /// 01/15 格式
    ///
    /// - Returns: 月日
    func dateStrWithShort() -> String {
        if dateStr.count > 5 && dateStr.contains("-") {
            let arr = dateStr.components(separatedBy: "-")
            if arr.count == 3 {
                let str = arr[1]+"/"+arr[2]
                return str
            }
        }
        return dateStr
    }
}

class RecentWeekAQI: HandyJSON {
    
    required init() {}
    
    var cityID: String = ""
    var recentAQIs: [SingleDayAQI] = []
    
    func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &cityID, name: "idx")
        mapper.specify(property: &recentAQIs, name: "recent")
    }
    
    /// 获取最近几天的极值点 最大点 最小点 以及位置
    ///
    /// - Returns:  max min
    func peakValue() -> (Int, Int, Int, Int) {
        
        var min = 100000
        var max = -1
        var index1 = 0
        var index2 = 0
        var i = 0
        for aqi in recentAQIs {
            if aqi.aqiMax > max {
                max = aqi.aqiMax
                index1 = i
            }
            if aqi.aqiMin < min {
                min = aqi.aqiMin
                index2 = i
            }
            i = i+1
         }
        return (max, min, index1, index2)
    }
}
