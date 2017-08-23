//
//  AppDelegate.swift
//  Summer
//
//  Created by 武淅 段 on 2017/6/16.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

let wxAppId = "wx5b2c8b3e6df2032d"
let wxSecretKey = "85b511d48ec0ec0ff6da59baf200f4e9"

@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {
    
    var window: UIWindow?
    let kFirstLoadApp = "first_load_app_key"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        

        //判断登录状态
//        let sb = UIStoryboard(name: "Main", bundle: nil)
//        let vc = sb.instantiateViewController(withIdentifier: "startNavigationVC")
//        window?.rootViewController = vc
        
        
        
//        if (SessionManager.sharedInstance.token.characters.count > 0) {
//            let sb = UIStoryboard(name: "Main", bundle: nil)
//            let vc = sb.instantiateViewController(withIdentifier: "startNavigationVC")
//            window?.rootViewController = vc
//        }
//        else if !UserDefaults.standard.bool(forKey: kFirstLoadApp) {
//            let guideVc = StartGuideViewController(nibName: "StartGuideViewController", bundle: nil)
//            let navVc = BaseNavigationController(rootViewController: guideVc) 
//            navVc.setTintColor(tint: .white)
//            navVc.setTintColor(tint: UIColor.white)
//            window?.rootViewController = navVc
//        }
        
        UIApplication.shared.statusBarStyle = .default
        
        WXApi.registerApp(wxAppId)
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let _:() = {
            
            if (SessionManager.sharedInstance.token.characters.count == 0) {
                let guideVc = StartGuideViewController(nibName: "StartGuideViewController", bundle: nil)
                let navVc = BaseNavigationController(rootViewController: guideVc)
                navVc.setTintColor(tint: .white)
                navVc.setTintColor(tint: UIColor.white)
                guard let rootVc = window?.rootViewController else {
                    return
                }
                rootVc.present(navVc, animated: false, completion: {
                    
                })
            }
            
        }()
        
        NotificationCenter.default.post(name: kAppDidBecomeActiveNotify, object: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        SessionManager.sharedInstance.saveLoginInfo()
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

