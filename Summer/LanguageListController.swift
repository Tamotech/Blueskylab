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
    let data:[String] = ["简体中文", "繁体中文", "English"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        if indexPath.row == 0 {
            cell.isSelected = true
        }
        else {
            cell.isSelected = false
        }
        return cell
    }

}
