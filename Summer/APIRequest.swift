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

    
    /// 查询当天的 AQI
    ///
    /// - Parameter result: request
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
    
    
    
    /// 查询最近一星期的 AQI:
    ///
    /// - Parameters:
    ///   - cityID: cityID
    ///   - result: result
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
    
    
    
    /// 获取用户信息
    ///
    /// - Parameter result:  request
    class func getUserInfoAPI(result: @escaping (_ resultObject: AnyObject?) -> ()) {
        
        let path = "/member/getUserInfo.htm"
        APIManager.shareInstance.postRequest(urlString: path, params: nil) {(JSON, code, msg) in
            if code == 0 {
                let data = UserInfo.deserialize(from: JSON?["data"].rawString())
                result(data)
            }
            else {
                SVProgressHUD.showError(withStatus: msg)
            }
        }
    }
}
