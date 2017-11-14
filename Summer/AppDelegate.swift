//
//  AppDelegate.swift
//  Summer
//
//  Created by 武淅 段 on 2017/6/16.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications

let wxAppId = "wx5b2c8b3e6df2032d"
let wxSecretKey = "85b511d48ec0ec0ff6da59baf200f4e9"
let jPushKey = "1c5b0bf1379cf38b6a436146"
let jPushSecret = "02348df4cadd5293af3e7c0a"


@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {
    
    var window: UIWindow?
    let kFirstLoadApp = "first_load_app_key"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        ///初始化语言
        var language:String="zh-Hans"
        if  (UserDefaults.standard.value(forKey: "language")) != nil {
            language=UserDefaults.standard.value(forKey: "language") as! String
        }
        LanguageHelper.shareInstance.setLanguage(langeuage: language)
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: NSNotification.Name(rawValue: "LanguageChanged"), object: nil)
        
        
        //keyboard
        IQKeyboardManager.sharedManager().enable = true
        
        UIApplication.shared.statusBarStyle = .default
        
        WXApi.registerApp(wxAppId)
        
        //注册推送
        if #available(iOS 10.0, *){
            let entiity = JPUSHRegisterEntity()
            entiity.types = Int(UNAuthorizationOptions.alert.rawValue |
                UNAuthorizationOptions.badge.rawValue |
                UNAuthorizationOptions.sound.rawValue)
            JPUSHService.register(forRemoteNotificationConfig: entiity, delegate: self)
        } else if #available(iOS 8.0, *) {
            let types = UIUserNotificationType.badge.rawValue |
                UIUserNotificationType.sound.rawValue |
                UIUserNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: types, categories: nil)
        }else {
            let type = UIRemoteNotificationType.badge.rawValue |
                UIRemoteNotificationType.sound.rawValue |
                UIRemoteNotificationType.alert.rawValue
            JPUSHService.register(forRemoteNotificationTypes: type, categories: nil)
        }
        
        JPUSHService.setup(withOption: launchOptions, appKey: jPushKey, channel: "app store", apsForProduction: true)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        NotificationCenter.default.post(name: kAppDidBecomeActiveNotify, object: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NotificationCenter.default.removeObserver(self)
        SessionManager.sharedInstance.saveLoginInfo()
        HealthDataManager.sharedInstance.saveMaskUseData()
    }
    
    
    //MARK: - JPUSH Delegate
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
        if (SessionManager.sharedInstance.userId.count > 0) {
            //绑定别名
            JPUSHService.setTags(Set(SessionManager.sharedInstance.pushTags), aliasInbackground: SessionManager.sharedInstance.userId)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
         print("did Fail To Register For Remote Notifications With Error = \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    //MARK: - Wechat
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func onReq(_ req: BaseReq!) {
        print(req)
    }
    
    func onResp(_ resp: BaseResp!) {
        print(resp)
        if resp is SendAuthResp {
            let send = resp as! SendAuthResp
            let info = ["code": send.code,
                        "state": send.state,
                        "country": send.country,
                        "lang": send.lang]
            NotificationCenter.default.post(name: kLoginWechatSuccessNotifi, object: info)
        }
    }


}


extension AppDelegate: JPUSHRegisterDelegate {
    
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        print(">JPUSHRegisterDelegate jpushNotificationCenter willPresent");
        let userInfo = notification.request.content.userInfo
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler(Int(UNAuthorizationOptions.alert.rawValue))// 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        // 取得 APNs 标准信息内容
        let userInfo = response.notification.request.content.userInfo
        let aps = userInfo["aps"] as! [String:Any?]
        let content = aps["alert"] ?? ""
        let badge = aps["badge"] ?? ""
        
        //extra 信息

        if userInfo["type"] != nil {
            let type = userInfo["type"] as! String
            let value = userInfo["pid"] as! String
            
            let rootVC = self.window?.rootViewController
            if rootVC is BaseNavigationController {
                let navVC = rootVC as! BaseNavigationController
                if navVC.childViewControllers.count > 1 {
                    navVC.popToRootViewController(animated: false)
                }
                
                let mainVC = navVC.childViewControllers.first as! MainViewController
                
                if type == "article" {
                    let vc = ArticleDetailController()
                    vc.articleId = value
                    navVC.pushViewController(vc, animated: true)
                }
                else if type == "pollutionalert" {
                    
                }
                else if type == "changefilter" {
                    mainVC.showChangeFilterAlert()
                }
            }
            
            
            
        }
        
        print("content: \(String(describing: content)), badge: \(String(describing: badge))")
        
        
        print(">JPUSHRegisterDelegate jpushNotificationCenter didReceive");
        
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            JPUSHService.handleRemoteNotification(userInfo)
        }
        completionHandler()
    }

    
    func languageChanged() {
        //语言切换 重新加载页面
//        let sb = UIStoryboard(name: "Main", bundle: nil)
//        let rootVC = sb.instantiateInitialViewController()
//        window!.rootViewController = rootVC

    }
}

