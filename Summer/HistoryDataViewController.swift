//
//  HistoryDataViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/6.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import CRRefresh

class HistoryDataViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var segmentSuperView: UIView!
    @IBOutlet weak var dataView: HistoryDataView!
    
    @IBOutlet weak var dateSegmentView: DateSegmentView!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet var tableSuperView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var arrowBtn: UIButton!
    
    
    var dayData: AQIDataList?
    var weekData: AQIDataList?
    var monthData: AQIDataList?
    var yearData: AQIDataList?
    var historyAQIList: CityAQIDataList = CityAQIDataList()
    
    /// 0 pm2.5  1 pm10  2 no2  3 so2  4 co  5 o3
    var aqiItemIndex: Int = 0
    /// 0 日  1 周  2 月  3 年
    var dateType: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = NSLocalizedString("HistoryData", comment: "")
        self.setupView()
        self.loadData()
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) {
            [weak self] in
            self?.reloadAQIList()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self?.tableView.cr.endHeaderRefresh()
            })
        }
        tableView.cr.beginHeaderRefresh()
        
        tableView.cr.addFootRefresh(animator: NormalFooterAnimator()) {
            [weak self] in
            self?.loadMoreAQIList()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self?.tableView.cr.endLoadingMore()
            })
        }
    }
    
    func setupView() {
        let aqItems = ["PM2.5", "PM10", "NO₂", "O₃", "SO₂", "CO"]
        let segment = BaseSegmentControl(items: aqItems, defaultIndex: 0)
        segment.selectItemAction = {
            [weak self](index, content) in
            self?.aqiItemIndex = index
            self?.updateView()
        }
        segmentSuperView.addSubview(segment)
        
        dateSegmentView.selectDateHandler = {
            [weak self](index) in
            self?.dateType = index
            self?.updateView()
        }
        
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
    
    func loadData() {
        guard let currentAQI = SessionManager.sharedInstance.currentAQI else {
            return
        }
        let cityID = currentAQI.cityID
        cityLabel.text = currentAQI.city
        BSLAnimationActivityView.showAddToView(view: keyWindow!)
        
        APIRequest.getAQIHistoryData(type: 1, cityID:  cityID) { [weak self](data) in
            BSLAnimationActivityView.dismiss(view: keyWindow!)
            self?.dayData = data as? AQIDataList
            self?.updateView()
        }
        APIRequest.getAQIHistoryData(type: 2, cityID:  cityID) { [weak self](data) in
            self?.weekData = data as? AQIDataList
            self?.updateView()
        }
        APIRequest.getAQIHistoryData(type: 3, cityID:  cityID) { [weak self](data) in
            self?.monthData = data as? AQIDataList
            self?.updateView()
        }
        APIRequest.getAQIHistoryData(type: 4, cityID:  cityID) { [weak self](data) in
            self?.yearData = data as? AQIDataList
            self?.updateView()
        }
    }
    
    func reloadAQIList() {
        
        guard let currentAQI = SessionManager.sharedInstance.currentAQI else {
            return
        }
        let cityID = currentAQI.cityID
        APIRequest.getCityAQIHistotyData(page: 1, rows: 10, cityId: cityID) {[weak self] (data) in
            self?.historyAQIList = data as! CityAQIDataList
            self?.tableView.reloadData()

        }
    }
    
    func loadMoreAQIList() {
        guard let currentAQI = SessionManager.sharedInstance.currentAQI else {
            return
        }
        let cityID = currentAQI.cityID
        let page = historyAQIList.page+1
        APIRequest.getCityAQIHistotyData(page: page, rows: 10, cityId: cityID) {[weak self] (data) in
            let list = data as! CityAQIDataList
            if list.list.count > 0 {
                self?.historyAQIList.list.append(contentsOf: list.list)
                self?.tableView.reloadData()
            }
        }
    }
    
    func updateView() {
        
        var data: AQIDataList? = nil
        switch dateType {
        case 0:
            data = dayData
            break
        case 1:
            data = weekData
            break
        case 2:
            data = monthData
            break
        case 3:
            data = yearData
            break
        default:
            break
        }
        
        if data != nil {
            let data: ([AQIData], CGFloat) = data!.getAQIData(type: aqiItemIndex)
            dataView.updateView(dataArr: data.0, maximum: data.1)
        }
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
    
    @IBAction func handleTapTableHeaderView(_ sender: UITapGestureRecognizer) {
        
        arrowBtn.isSelected = !arrowBtn.isSelected
        if arrowBtn.isSelected {
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
        return historyAQIList.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HistoryDataCell
        let data = historyAQIList.list[indexPath.row]
        cell.updateCell(data: data)
        return cell
    }
    
    
}
