//
//  NotificationCenterController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/8.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import CRRefresh

class NotificationCenterController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    var nData: NotificationList = NotificationList()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("NotificationCenter", comment: "")
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        let cellNib = UINib(nibName: "NotificationCenterCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "Cell")
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { 
            [weak self] in
            self?.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self?.tableView.cr.endHeaderRefresh()
            })
        }
        tableView.cr.beginHeaderRefresh()
        
        tableView.cr.addFootRefresh(animator: NormalFooterAnimator()) {
            [weak self] in
            self?.loadMoreData()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self?.tableView.cr.endLoadingMore()
            })
        }
    }
    
    deinit {
        self.tableView.cr.removeHeader()
        self.tableView.cr.removeFooter()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navVC = self.navigationController as! BaseNavigationController
        navVC.setTintColor(tint: gray72!)
    }
    
    
    
    //MARK: - load data
    
    func reloadData() {
        APIRequest.getNotificationList(page: 1, rows: 20) {[weak self] (data) in
            if data != nil && data is NotificationList {
                self?.nData = data as! NotificationList
                self?.tableView.reloadData()
            }
        }
    }
    
    func loadMoreData() {
        if !nData.hasMore() {
            return
        }
        APIRequest.getNotificationList(page: nData.page+1, rows: nData.rows) {[weak self] (data) in
            if data != nil && data is NotificationList {
                let d = data as! NotificationList
                self?.nData.list += d.list
                self?.tableView.reloadData()
            }
        }
    }
    
    //MARK: - tableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nData.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = nData.list[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotificationCenterCell
        cell.layoutMargins = .zero
        cell.separatorInset = .zero
        cell.updateCell(data: data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = nData.list[indexPath.row]
        let vc = NotificationDetailController()
        vc.data = data
        navigationController?.pushViewController(vc, animated: true)
    }
    

}
