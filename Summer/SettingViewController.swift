//
//  SettingViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/2.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class SettingViewController: BaseViewController {

    @IBOutlet weak var filterChangeSwitch: UISwitch!
    @IBOutlet weak var powerSwitch: UISwitch!
    @IBOutlet weak var polluteSwitch: UISwitch!
    @IBOutlet weak var airSwitch: UISwitch!
    @IBOutlet weak var productInfoSwitch: UISwitch!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Settings", comment: "")

    }

    //MARK: - actions
    
    @IBAction func handleTapLanguage(_ sender: Any) {
        let vc = LanguageListController(nibName: "LanguageListController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func handleTapAbout(_ sender: Any) {
        let aboutVc = AboutViewController()
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
        
    }
    

}
