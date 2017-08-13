//
//  NotificationCenterController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/8.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class NotificationCenterController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("NotificationCenter", comment: "")
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        let cellNib = UINib(nibName: "NotificationCenterCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "Cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navVC = self.navigationController as! BaseNavigationController
        navVC.setTintColor(tint: gray72!)
    }
    
    //MARK: - tableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotificationCenterCell
        cell.layoutMargins = .zero
        cell.separatorInset = .zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = NotificationDetailController()
        navigationController?.pushViewController(vc, animated: true)
    }
    

}
