//
//  LanguageListController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/30.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class LanguageListController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    let data:[String] = ["简体中文", "English"]
    
    var selectIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        let language = SessionManager.sharedInstance.userMaskConfig.language
        let language = SessionManager.sharedInstance.language
        if language == "zh_CN" {
            selectIndex = 0
        }
        else if language == "en_US" {
            selectIndex = 1
        }
        self.title = NSLocalizedString("LanguageSetting", comment: "")
        let nib = UINib(nibName: "LanguageCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LanguageCell
        let content = data[indexPath.row]
        cell.nameLabel.text = content
        if selectIndex == indexPath.row {
            cell.markIcon.isHidden = false
        }
        else {
            cell.markIcon.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectIndex = indexPath.row
        tableView.reloadData()
        if selectIndex == 0 {
            LanguageHelper.shareInstance.setLanguage(langeuage: "zh-Hans")
            SessionManager.sharedInstance.userMaskConfig.language = "zh_CN"
        }
        else if selectIndex == 1 {
            LanguageHelper.shareInstance.setLanguage(langeuage: "en")
            SessionManager.sharedInstance.userMaskConfig.language = "en_US"

        }
   
        // 通知更新模式面板
        
    SessionManager.sharedInstance.userMaskConfig.updateSettingSwitches()
       navigationController?.popToRootViewController(animated: true)
        
        
    }

}
