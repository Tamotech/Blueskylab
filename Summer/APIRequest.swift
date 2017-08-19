//
//  APIRequest.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/17.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import CoreLocation


/// 构建 http 请求 以及处理返回结果
class APIRequest: NSObject {

    class func AQIQueryAPI(result: @escaping (_ resultObject: AnyObject?) -> ()) {
        
        print("--------->查询今天 AQI")
        let path = "/aqi/getTodayAqiByGeo.htm"
        let location = SessionManager.sharedInstance.currentLocation
        if location.coordinate.latitude == 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 2), execute: {
                APIRequest.AQIQueryAPI(result: result)
            })
            return
        }
        let params = ["lng": location.coordinate.longitude,
                      "lat": location.coordinate.latitude]
        APIManager.shareInstance.postRequest(urlString: path, params: params) { (JSON, code, msg) in
            if code == 0 {
                let data = CurrentAQI.deserialize(from: JSON?["data"].rawString())
                result(data)
            }
            else {
                SVProgressHUD.showError(withStatus: msg)
            }
        }
    }
    
    class func recentWeekAQIAPI(cityID: Int, result: @escaping (_ resultObject: AnyObject?) -> ()) {
        
        let path = "/aqi/getRecentAqiMinMax.htm"
        let params = ["idx": cityID]
        APIManager.shareInstance.postRequest(urlString: path, params: params) { (JSON, code, msg) in
            if code == 0 {
                let data = RecentWeekAQI.deserialize(from: JSON?["data"].rawString())
                result(data)
            }
            else {
                SVProgressHUD.showError(withStatus: msg)
            }
        }
    }
}
