//
//  SettingViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/2.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import SwiftyJSON

class SettingViewController: BaseViewController {

    @IBOutlet weak var filterChangeSwitch: UISwitch!
    @IBOutlet weak var powerSwitch: UISwitch!
    @IBOutlet weak var polluteSwitch: UISwitch!
    @IBOutlet weak var airSwitch: UISwitch!
    @IBOutlet weak var productInfoSwitch: UISwitch!
    var settingData: UserMaskConfig?
    
    ///关于我们
    var aboutUsHTML: String?
    ///微博
    var weiboName: String?
    ///联系方式
    var contractWay: String?
    ///email
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Settings", comment: "")
        self.loadConfigData()
    }
    
    func loadConfigData() {
        APIRequest.getUserConfig(codes: "f_about_us, s_weibo, s_contact_way, s_email") { [weak self](JSONData) in
            let data = JSONData as! JSON
            self?.aboutUsHTML = data["f_about_us"]["v"].stringValue
            self?.contractWay = data["s_contact_way"]["v"].stringValue
            self?.weiboName = data["s_weibo"]["v"].stringValue
            self?.email = data["s_email"]["v"].stringValue
            
        }
        
        APIRequest.getUserMaskConfig { [weak self](JSONData) in
            self?.settingData = JSONData as? UserMaskConfig
            guard let data = self?.settingData else {
                return
            }
            SessionManager.sharedInstance.userMaskConfig = data
            self?.filterChangeSwitch.isOn = data.filterchangeflag
            self?.powerSwitch.isOn = data.lowpowerflag
            self?.polluteSwitch.isOn = data.pollutionwarnflag
            self?.productInfoSwitch.isOn = data.productinfoflag
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ///如果开关状态变化则同步数据
        guard let data = settingData else {
            return
        }
        if data.filterchangeflag != filterChangeSwitch.isOn ||
        data.lowpowerflag != powerSwitch.isOn ||
        data.pollutionwarnflag != polluteSwitch.isOn ||
            data.productinfoflag != productInfoSwitch.isOn {
            //有变化
            SessionManager.sharedInstance.userMaskConfig.filterchangeflag = filterChangeSwitch.isOn
            SessionManager.sharedInstance.userMaskConfig.lowpowerflag = powerSwitch.isOn
            SessionManager.sharedInstance.userMaskConfig.pollutionwarnflag = polluteSwitch.isOn
            SessionManager.sharedInstance.userMaskConfig.productinfoflag = productInfoSwitch.isOn
            SessionManager.sharedInstance.userMaskConfig.updateSettingSwitches()
        }
        
    }

    //MARK: - actions
    
    @IBAction func handleTapLanguage(_ sender: Any) {
        let vc = LanguageListController(nibName: "LanguageListController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func handleTapAbout(_ sender: Any) {
        let aboutVc = AboutViewController()
        aboutVc.contentHTML = aboutUsHTML ?? ""
        aboutVc.contractWay = contractWay ?? ""
        aboutVc.email = email ?? ""
        aboutVc.weibo = weiboName ?? ""
        navigationController?.pushViewController(aboutVc, animated: true)
    }
    
    @IBAction func handleTapPrivacy(_ sender: Any) {
        
        let vc = BaseWKWebViewController()
        vc.articleStr = "f_privacy_policy"
        vc.showCustomTitle(title: NSLocalizedString("PrivacyPolicy", comment: ""))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func handleTapProtocol(_ sender: Any) {
        let vc = BaseWKWebViewController()
        vc.articleStr = NSLocalizedString("f_terms_of_use", comment: "")
        vc.showCustomTitle(title: NSLocalizedString("TermsOfUse", comment: ""))
        navigationController?.pushViewController(vc, animated: true)
//        let vc = TermsOfUseController()
//        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func handleTapUpdate(_ sender: Any) {
        let vc = CheckUpdateViewController()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func handleTapLogout(_ sender: Any) {
        SessionManager.sharedInstance.logoutCurrentUser()
        let guideVc = StartGuideViewController(nibName: "StartGuideViewController", bundle: nil)
        let navVc = BaseNavigationController(rootViewController: guideVc)
        navVc.setTintColor(tint: .white)
        navVc.setTintColor(tint: UIColor.white)
//        UIApplication.shared.keyWindow?.rootViewController = navVc
        
        navigationController?.present(navVc, animated: true, completion: { 
            self.navigationController?.popViewController(animated: false)
        })
    }
    

}
