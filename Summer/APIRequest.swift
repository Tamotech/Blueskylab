//
//  APIRequest.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/17.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

typealias JSONResult = (_ resultObject: Any?) -> ()

/// 构建 http 请求 以及处理返回结果
class APIRequest: NSObject {

    
    /// 查询当天的 AQI
    ///
    /// - Parameter result: request
    class func AQIQueryAPI(result: @escaping JSONResult) {
        
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
    class func recentWeekAQIAPI(cityID: Int, result: @escaping JSONResult) {
        
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
    class func getUserInfoAPI(result: @escaping JSONResult) {
        
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
    
    
    
    /// 获取微信用户信息
    class func getWXUserInfo(accessToken: String, openId: String, result: @escaping JSONResult) {
        let path = String.init(format: "https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", accessToken, openId)
        Alamofire.request(path).responseJSON { (response) in
            if let value = response.result.value {
                let dic = JSON(value)
                if dic["errcode"] == JSON.null {
                    let data = WXUserInfo.deserialize(from: dic.rawString())
                    result(data)
                }
                else {
                    
                }
            }
        }
    }
    
    
    /// 获取用户风速配置信息
    ///
    /// - Parameter result:  result
    class func getUserWindSpeedConfig(result: @escaping JSONResult) {
        let path = "/maskwindspeedset/getCfgList.htm"
        APIManager.shareInstance.postRequest(urlString: path, params: nil) { (JSON, code, msg) in
            if code == 0 {
                let list = JSON?["data"]["cfglist"]
                let cfgList = [UserWindSpeedConfig].deserialize(from: list?.rawString())
                result(cfgList)
            }
            else {
                SVProgressHUD.showError(withStatus: msg)
            }
        }
    }
}
