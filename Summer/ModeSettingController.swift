//
//  ModeSettingController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/21.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import SnapKit

class ModeSettingController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var modeManager: WindModeManager?
    var tableView: UITableView = UITableView(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight), style: .grouped)
    
    lazy var headerView: UIView = {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 80))
        view.backgroundColor = themeColor
        let star = UIImageView.init(image: #imageLiteral(resourceName: "iconStarWhiteM3-4-1"))
        view.addSubview(star)
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white
        label.text = NSLocalizedString("SelectCommenMode", comment: "")
        view.addSubview(label)
        
        label.snp.makeConstraints({ (make) in
            make.center.equalTo(view.snp.center)
        })
        star.snp.makeConstraints({ (make) in
            make.centerY.equalTo(view.snp.centerY)
            make.right.equalTo(label.snp.left).offset(-22)
        })
        return view
    }()
    
    
    lazy var addBtn: UIButton = {
        
        let button = UIButton(frame: CGRect.init(x: 0, y: 0, width: 58, height: 58))
        button.setImage(#imageLiteral(resourceName: "iconAdd"), for: .normal)
        return button
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.showCustomTitle(title: NSLocalizedString("ModeManage", comment: ""))
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib.init(nibName: "ModeSettingCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        tableView.tableHeaderView = headerView
        
        self.view.addSubview(addBtn)
        addBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp.bottom).offset(-10)
            make.centerX.equalTo(self.view.snp.centerX)
        }
        addBtn.addTarget(self, action: #selector(handleTapAddBtn(_:)), for: .touchUpInside)
        
    }

    
    //MARK: - actions
    func handleTapAddBtn(_ sender: UIButton) {
        
    }
    
    //MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if modeManager != nil {
            return modeManager!.windUserConfigList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ModeSettingCell
        let config = modeManager?.windUserConfigList[indexPath.row]
        cell.updateCellWithConfig(config: config!)
        return cell
    }
    
}
