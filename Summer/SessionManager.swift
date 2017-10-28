//
//  SessionManager.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/14.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
import ReactiveCocoa

let kLoginInfo = "login_info_key"

struct LoginInfo {
    var phone: String = ""
    var wxid: String = ""
    var wxAccessToken: String = ""
    var captcha: String = ""
    var name: String = ""
    var age: String = ""
    var gender: String = ""
    var height: CGFloat = 0
    var weight: CGFloat = 0
    var isLogin: Bool = false
    var avatarUrl: String = ""
    var birthday: String = ""
    var idfv: String = ""
}

struct PushMessage {
    //1、changefilter：更换滤芯
    //2、lowbattery：电量不足
    //3、pollutionalert：污染警告
    //4、article：产品信息
    //5、article：新闻动态
    var type: String = ""
    //zh_CN 简体 zh_TW 繁体 en_US 英文
    var language: String = "zh_CN"
    var pid: Int = -1   //详情 通知详情id
    var cityid: Int = -1        //城市 id
    
}

class SessionManager: NSObject, CLLocationManagerDelegate {

    static let sharedInstance: SessionManager = SessionManager()
    var loginInfo: LoginInfo = LoginInfo()
    
    var token:String = ""       //登录令牌
    var userId: String = ""     //用户 Id
    var currentAQI: CurrentAQI?
    var userInfo: UserInfo?
    var wxUserInfo: WXUserInfo?
    var pushMessage = PushMessage()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation = CLLocation()        ///定位
    var windModeManager: WindModeManager = WindModeManager()
    var userMaskConfig = UserMaskConfig()       //用户口罩配置
    var lock = NSLock()
    /// 最新固件下载链接
    var firewareDownloadUrl: String?
    /// 最新固件版本号
    var firewareVersion: String?
    
    ///推送tags
    var pushTags = ["changefilter", "zh_CN", "lowbattery", "pollutionalert", "article"]

    
    override init() {
        super.init()
        
        self.openAndLocation()
        self.readLoginInfo()
    }
    
    func login(results: @escaping(_ resultObject: JSON?, _ code: Int, _ msg: String) -> ()) {
        let params = ["mobile": self.loginInfo.phone,
                      "captcha": self.loginInfo.captcha,
                      "wxid": self.loginInfo.wxid]
        APIManager.shareInstance.postRequest(urlString: "/login/login.htm", params: params, result: { [weak self](result, code, msg) in
            if code == 0 {
                let token = result?["memo"].string!
                self?.loginInfo.isLogin = true
                APIManager.shareInstance.headers["token"] = token
                self?.token = token!
                self?.userId = result?["id"].string ?? ""
                self?.saveLoginInfo()
                self?.getUserInfo()
                self?.getUserMaskConfig()
            }
            else {
                
            }
            
            results(result, code, msg)
        })
    }
    
    func regist(results: @escaping(_ resultObject: JSON?, _ code: Int, _ msg: String) -> ()) {
        var params: [String: Any] = ["mobile": loginInfo.phone,
                      "captcha": loginInfo.captcha,
                      "name": loginInfo.name,
                      "sex": loginInfo.gender,
                      "headimg": loginInfo.avatarUrl,
                      "birthday": loginInfo.birthday,
                      "weight": loginInfo.weight,
                      "height": loginInfo.height]
        if loginInfo.wxid.characters.count > 0 {
            params["wxid"] = loginInfo.wxid
        }
        APIManager.shareInstance.postRequest(urlString: "/regist/mobileregist.htm", params: params) { [weak self](JSON, code, msg) in
            let token = JSON?["memo"].string!
            self?.token = token!
            self?.loginInfo.isLogin = true
            results(JSON, code, msg)
            self?.getUserInfo()
            self?.getUserMaskConfig()
        }
    }
    
    func getUserInfo() {
        APIRequest.getUserInfoAPI { [weak self](result) in
            if result != nil {
                self?.userInfo = result as? UserInfo
                NotificationCenter.default.post(name: kUserInfoDidUpdateNotify, object: nil)
            }
        }
    }
    
    ///登出
    func logoutCurrentUser() {
        self.token = ""
        self.loginInfo.isLogin = false
        self.loginInfo = LoginInfo()
        self.userInfo = nil
        APIManager.shareInstance.headers["token"] = ""
        UserDefaults.standard.removeObject(forKey: kLoginInfo)
        NotificationCenter.default.post(name: kUserInfoDidUpdateNotify, object: nil)
        
    }
    
    
    ///读取用户配置
    func getUserMaskConfig() {
        if userInfo == nil {
            return
        }
        APIRequest.getUserMaskConfig {[weak self] (result) in
            if result != nil {
                self?.userMaskConfig = result as! UserMaskConfig
                NotificationCenter.default.post(name: kUserMaskConfigUpdateNoti, object: nil)
            }
        }
    }
    
    
    //MARK: - private
    
    //保存登录信息到本地
    func saveLoginInfo() {
        let loginInfo = ["userId": userId,
                         "token": token]
        UserDefaults.standard.setValue(loginInfo, forKey: kLoginInfo)
    }
    
    func readLoginInfo() {
        let info = UserDefaults.standard.value(forKey: kLoginInfo) as? [String: String]
        if info != nil {
            token = info!["token"] ?? ""
            userId = info!["userId"] ?? ""
            
            if (userId.characters.count > 0) {
                //绑定别名
                JPUSHService.setTags(Set(["DefaultTag"]), aliasInbackground: userId)
            }
            
            APIManager.shareInstance.headers["token"] = self.token
            self.getUserInfo()
            self.getUserMaskConfig()
        }
    }
    
    
    /// 开启并定位
    func openAndLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        print("---------->开始定位")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lock.lock()
        currentLocation = locations.last!
        lock.unlock()
        print("---------->获取最新位置")
    }
    
    ///绑定推送tags
    func bindPushTags() {
        if userId.characters.count > 0 {
            //绑定别名
            JPUSHService.setTags(Set(pushTags), aliasInbackground: userId)
        }
    }
    
    func changeLanguage(language: String) {
        
        let index = pushTags.index(of: language)
        if index == nil {
            pushTags.append(language)
        }
        pushTags[index!] = language
        bindPushTags()
        
    }
}
