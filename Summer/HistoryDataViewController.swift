//
//  HistoryDataViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/6.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class HistoryDataViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var segmentSuperView: UIView!
    @IBOutlet weak var dataView: UIView!
    
    @IBOutlet weak var dateSegmentView: DateSegmentView!
    
    @IBOutlet var tableSuperView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = NSLocalizedString("HistoryData", comment: "")
        self.setupView()
    }
    
    func setupView() {
        let aqItems = ["PM2.5", "PM10", "NO2", "O3", "SO2", "CO"]
        let segment = BaseSegmentControl(items: aqItems, defaultIndex: 0)
        segment.selectItemAction = {
            (index, content) in
            
        }
        segmentSuperView.addSubview(segment)
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "HistoryDataCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        tableSuperView.frame = CGRect(x: 20, y: dataView.height+10, width: screenWidth-40, height: screenHeight-10-dataView.height)
        self.view.addSubview(tableSuperView)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableSuperView.frame = CGRect(x: 20, y: 400, width: screenWidth-40, height: screenHeight-400)

    }
    
    //MARK: - actions
    
    @IBAction func handleTapTableArrowBtn(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            UIView.animate(withDuration: 0.4, animations: { 
                self.tableSuperView.frame = CGRect(x: 0, y: 20, width: screenWidth, height: screenHeight-20)
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.barView.isHidden = true
            })
        }
        else {
            UIView.animate(withDuration: 0.4, animations: {
                self.tableSuperView.frame = CGRect(x: 20, y: 400, width: screenWidth-40, height: screenHeight-400)
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.barView.isHidden = false
            })

        }
    }
    
    
    //MARK: - tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HistoryDataCell
        return cell
    }
    
    
    
}
