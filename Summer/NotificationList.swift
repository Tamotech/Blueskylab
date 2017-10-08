//
//  NotificationList.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/28.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import HandyJSON


class NotificationItem: HandyJSON {
    
/**
     "id": "67317cb5-9c6d-471d-8151-9632318e2738",
     "title": "如何测试蓝天大气的过滤性",
     "description": "如何测试蓝天大气的过滤性如何测试蓝天大气的过滤性如何测试蓝天大气的过滤性如何测试蓝天大气的过滤性如何测试蓝天大气的过滤性",
     "typename": "常见问题",
     "img": null,
     "type": "article",
     "publishdate": 1503497249969,
     "readflag": 0
 */
    
    var id: String = ""
    var title: String = ""
    var description: String = ""
    var typename: String = ""
    var content: String = ""
    var publishdate: Int = 0
    var readflag: Int = 0
    var img: String = ""
    //article:产品新闻 pollutionalert:污染预警
    var type: String = ""
    var link: String = ""
    
    required init() {}
    
    
    
    /// 日期字符串
    ///
    /// - Returns: 17-08-22 14:00 星期一
    func dateStr() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd HH:mm"
        let date = Date(timeIntervalSince1970: TimeInterval(publishdate))
        return formatter.string(from: date)
    }
}


class NotificationList: HandyJSON {

    var total: Int = 0
    var page: Int = 0
    var rows: Int = 0
    var list: [NotificationItem] = []
    
    required init() {}
    
    func hasMore() -> Bool {
        if list.count < total {
            return true
        }
        return false
    }
}
