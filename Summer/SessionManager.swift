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
    var token: String = ""
    var isLogin: Bool = false
    var avatarUrl: String = ""
    var birthday: String = ""
    var idfv: String = ""
}

class SessionManager: NSObject, CLLocationManagerDelegate {

    static let sharedInstance: SessionManager = SessionManager()
    var loginInfo: LoginInfo = LoginInfo()
    
    var token:String = ""       //登录令牌
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation = CLLocation()        ///定位
    var lock = NSLock()
    
    override init() {
        super.init()
        
        self.openAndLocation()
        self.readLoginInfo()
    }
    
    func login(phone: String, sms: String?, wxOpenId: String?, results: @escaping(_ resultObject: JSON?, _ code: Int, _ msg: String) -> ()) {
        let params = ["mobile": phone,
                      "captcha": sms ?? "",
                      "wxid": wxOpenId ?? ""]
        APIManager.shareInstance.postRequest(urlString: "/login/login.htm", params: params, result: { [weak self](result, code, msg) in
            if code == 0 {
                let token = result?["memo"].string!
                self?.loginInfo.phone = phone
                self?.loginInfo.captcha = sms!
                self?.loginInfo.token = token!
                self?.loginInfo.wxid = wxOpenId ?? ""
                self?.loginInfo.isLogin = true
                APIManager.shareInstance.headers["token"] = token
                self?.token = token!
                self?.saveLoginInfo()
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
        APIManager.shareInstance.postRequest(urlString: "/regist/mobileregist.htm", params: params) { (JSON, code, msg) in
            results(JSON, code, msg)
        }
    }
    
    //MARK: - private
    
    //保存登录信息到本地
    func saveLoginInfo() {
        
        UserDefaults.standard.setValue(token, forKey: kLoginInfo)
    }
    
    func readLoginInfo() {
        let info = UserDefaults.standard.value(forKey: kLoginInfo)
        if info != nil {
            token = info as! String
            APIManager.shareInstance.headers["token"] = self.token
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
}
