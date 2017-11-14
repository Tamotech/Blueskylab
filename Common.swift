//
//  Common.swift
//  Summer
//
//  Created by 武淅 段 on 2017/6/16.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height
let keyWindow = UIApplication.shared.keyWindow
let rootController = UIApplication.shared.keyWindow?.rootViewController!
let themeColor = UIColor(ri: 0, gi: 156, bi: 222, alpha: 1)
let gray155 = UIColor(ri: 155, gi: 155, bi: 155)
let gray232 = UIColor(ri: 232, gi: 232, bi: 232)
let gray72 = UIColor(ri: 72, gi: 72, bi: 72)
let translucentBGColor = UIColor(white: 0, alpha: 0.5)

let baseURL = "http://www.blueskylab.cn"

let kLoginWechatSuccessNotifi = Notification.Name(rawValue:"Login_Wechat_Success_Notify_key")
let kAppDidBecomeActiveNotify = Notification.Name("App_did_become_active_key")
let kUserInfoDidUpdateNotify = Notification.Name("user_info_did_update_noti_key")
let kWindModeConfigDidChangeNotify = Notification.Name("wind_mode_config_change_notify_key")
let kWindModeConfigDidDeleteNotify = Notification.Name("wind_mode_config_delete_notify_key")
let kWindModeConfigDidChangeOrderNotify = Notification.Name("wind_mode_config_change_order_notify_key")
let kUserMaskConfigUpdateNoti = Notification.Name("user_mask_config_update_notify_key")
let kMaskDidConnectBluetoothNoti = Notification.Name("mask_did_connect_bluetooth_notify_key")
let kMaskDidDisConnectBluetoothNoti = Notification.Name("mask_did_disconnect_bluetooth_notify_key")
let kMaskStateChangeNotifi = Notification.Name("mask_state_did_change_notify_key")

///蓝牙连接状态的标志  杀掉app  下次自动连接蓝牙
let kBluetoothConnectFlag = "bluetooth_connected_state_key"

let kFirstLoadAppKey = "first_load_app_key"
let kBluetoothDidDisconnectKey = "bluetooth_did_disconnect_key"

/// 弹出登录页
func showLoginVC() {
    
    let rootVC = keyWindow?.rootViewController as! BaseNavigationController
    let guideVc = StartGuideViewController(nibName: "StartGuideViewController", bundle: nil)
    let navVc = BaseNavigationController(rootViewController: guideVc)
    navVc.setTintColor(tint: .white)
    navVc.setTintColor(tint: UIColor.white)
    rootVC.present(navVc, animated: true, completion: {
        rootVC.popViewController(animated: false)
    })

}
