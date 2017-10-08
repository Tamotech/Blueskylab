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
        let vc = PrivacyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func handleTapProtocol(_ sender: Any) {
        let vc = TermsOfUseController()
        navigationController?.pushViewController(vc, animated: true)
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
