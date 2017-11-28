//
//  EquipmentViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/30.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import AMPopTip
import SwiftyJSON

class EquipmentViewController: BaseViewController, MotionDataDelegate, BluetoothViewDelegate {

    
//    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var daysAQI: UILabel!
    @IBOutlet weak var dayUseTimeLb: UILabel!
    @IBOutlet weak var windLevelLabel: UILabel!
//    @IBOutlet weak var moveDistanceLabel: UILabel!
    @IBOutlet weak var clearTimeLabel: UILabel!
    
    @IBOutlet weak var stepCountLabel: UILabel!
    
    @IBOutlet weak var caloriesLabel: UILabel!
    
    @IBOutlet weak var connectStatusLabel: UILabel!
    
    @IBOutlet weak var filterLevelLabel: UILabel!
    
    @IBOutlet weak var unconnectView: UIView!
  
    @IBOutlet weak var resetFilterBtn: UIButton!
    
    ///累计时间
//    var totalSeconds: Int = 0
//    ///日均AQI
//    var dayAveAQI: Int = 0
//    ///日均使用时间
//    var dayAveUseSeconds: Int = 0
    
    var currentSteps: Int = 0
    var currentDistance: Float = 0
    ///初始累计时间
    var totalSeconds: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("MyEquipment", comment: "")
        ///过滤等级
        let level = SessionManager.sharedInstance.userMaskConfig.maskFilterLevel()
        filterLevelLabel.text = level.0
        
        HealthDataManager.sharedInstance.delegate = self
        ///风速
        windLevelLabel.text = String.init(format: "%.0f", BLSBluetoothManager.shareInstance.aveWindSpeed)
        
        let manager = BLSBluetoothManager.shareInstance
        if manager.state == BluetoothState.Connected {
            unconnectView.isHidden = true
            //HealthDataManager.sharedInstance.startPedometerUpdates()
        }
        else {
            unconnectView.isHidden = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(bluetoothStateChangeNotification(noti:)), name: kMaskStateChangeNotifi, object: nil)
    
        self.loadCaculateData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showResetFilterAlert()
    }
    
    //MARK: notification
    func bluetoothStateChangeNotification(noti: Notification) {
        guard let userInfo = noti.userInfo as? [String: Any] else {
            return
        }
        if userInfo["key"] as! String == "state" {
            let state = userInfo["value"] as! BluetoothState
            let manager = BLSBluetoothManager.shareInstance
            switch state {
            case .Unauthorized:
                self.changeToConnectMode(connect: false)
                break
            case .PowerOff:
                self.changeToConnectMode(connect: false)
                manager.stop()
                break
            case .PowerOn:
                break
            case .Connected:
                self.loadCaculateData()
                self.changeToConnectMode(connect: true)
                break
                
            case .ConnectFailed:
                self.changeToConnectMode(connect: false)
                break
            case .DisConnected:
                self.changeToConnectMode(connect: false)
                break
                
            }
        }
        else if userInfo["key"] as! String == "speed" {
            //let speed = (userInfo["value"] as! CGFloat)*5
            
            //self.windLevelLabel.text = String.init(format: "%.0f", speed)
        }
    }
    
    
    //加载口罩计算数据
    func loadCaculateData() {
        APIRequest.cacuDeviceInfoAPI { [weak self](JSON) in
            
            BLSBluetoothManager.shareInstance.calcDeviceInfo = JSON as! CalcDeviceInfo
            let info =  BLSBluetoothManager.shareInstance.calcDeviceInfo
            self?.totalSeconds = info.totalTimeSecond
            self?.daysAQI.text = "\(info.dayAgvAqi)"
            self?.dayUseTimeLb.text = String.init(format: "%.1f", Float(info.dayAvgUseTimeSecond)/3600.0)
        }
    }
    

   //MARK: - actions
    
    ///清零步数
    @IBAction func handleTapCleanStepBtn(_ sender: UIButton) {
        let alert = ConfirmAlertView.instanceFromXib() as! ConfirmAlertView
        alert.titleLabel.text = NSLocalizedString("ClearZero", comment: "")
        alert.msgLabel.text = NSLocalizedString("ConfirmClearZeroSteps", comment: "")
        alert.show()
        alert.confirmCalback = {
            HealthDataManager.sharedInstance.zeroStep += self.currentSteps
            self.stepCountLabel.text = "0步"
        }
    }

    @IBAction func handleTapCleanCarlorBtn(_ sender: UIButton) {
        let alert = ConfirmAlertView.instanceFromXib() as! ConfirmAlertView
        alert.titleLabel.text = NSLocalizedString("ClearZero", comment: "")
        alert.msgLabel.text = NSLocalizedString("ConfirmClearZeroCarlories", comment: "")
        alert.show()
        alert.confirmCalback = {
            HealthDataManager.sharedInstance.zeroDistance += self.currentDistance
            self.caloriesLabel.text = "0kcal"
        }
    }
    
    @IBAction func handleTapUnbindMaskBtn(_ sender: UIButton) {
        
//        let mode = UserWindSpeedConfig()
//        mode.value = 0
//        mode.gear = 0
//        mode.valueMax = 100
//        mode.gearMax = 20
//        BLSBluetoothManager.shareInstance.ajustSpeed(mode: mode)
        self.changeToConnectMode(connect: false)
        UserDefaults.standard.set(true, forKey: kBluetoothConnectFlag)
    }
    
    @IBAction func handleTapChangeBtn(_ sender: UIButton) {
        let vc = ArticleDetailController()
        vc.articleId = "filter_change_article"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func handleTapResetBtn(_ sender: UIButton) {
        let alert = ConfirmAlertView.instanceFromXib() as! ConfirmAlertView
        alert.titleLabel.text = NSLocalizedString("Reset", comment: "")
        
        let msg1 = "我已更换滤芯，\n请重新计算滤芯的过滤效果\n"
        let msg2 = "确认重置滤芯数据?"
        let attrStr1 = NSAttributedString(string: msg1, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: gray72!])
        let attrStr2 = NSAttributedString(string: msg2, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: themeColor!])
        let attrStr3 = NSMutableAttributedString(attributedString: attrStr1)
        attrStr3.append(attrStr2)
    
//        alert.msgLabel.text = NSLocalizedString("ResetYourFilter", comment: "")
        alert.msgLabel.attributedText = attrStr3
        alert.show()
        alert.confirmCalback = {
            HealthDataManager.sharedInstance.stopPedometerUpdate()
            HealthDataManager.sharedInstance.startPedometerUpdates()
            //self.speedLabel.text = "0"
            //self.moveDistanceLabel.text = "0"
            self.stepCountLabel.text = "0步"
            self.caloriesLabel.text = "0kcal"
            self.dayUseTimeLb.text = "0"
            BLSBluetoothManager.shareInstance.calcDeviceInfo.totalTimeSecond = 0
            APIRequest.resetMaskFilter()
        }
    }
    
    @IBAction func handleTapConnectBluetoothBtn(_ sender: UIButton) {
        let vc = OpenBluetoothController(nibName: "OpenBluetoothController", bundle: nil)
        vc.delegate = self
        let navVC = BaseNavigationController(rootViewController: vc)
        navigationController?.present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func handleTapQuestionBtn(_ sender: UIButton) {
        let vc = UserHandbookController(nibName: "UserHandbookController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func tapResetFilterQuestionBtn(_ sender: UIButton) {
        let vc = ArticleDetailController()
        vc.articleId = "filter_change_article"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: - MotionDelegate
    
    func motionDataUpdate(distance: Float, speed: Float, stepCount: Int, carlories: Float) {
        DispatchQueue.main.async {
            //self.speedLabel.text = String.init(format: "%.0f", speed*7.2)
//            self.moveDistanceLabel.text = String.init(format: "%.1f", distance/1000)
            self.stepCountLabel.text = "\(stepCount)步"
//            let kcal = (SessionManager.sharedInstance.userInfo?.getWeight())!*CGFloat(distance/1000)*1.036
            self.caloriesLabel.text = String.init(format: "%.0fkcal", carlories)
            self.currentSteps = stepCount
            self.currentDistance = distance
    
        }
    }
    
    func timerStrUpdate(seconds: Int) {
        DispatchQueue.main.async {
            
            let total = self.totalSeconds+seconds
            let hour = total/3600
            let minute = total%3600/60
            let second = total%60
            self.clearTimeLabel.text = String.init(format: "%02d:%02d:%02d", hour, minute, second)
            self.windLevelLabel.text = String.init(format: "%.0f", BLSBluetoothManager.shareInstance.aveWindSpeed)
        }
        
    }
    
    func changeToConnectMode(connect: Bool) {
        if connect {
            unconnectView.isHidden = true
            HealthDataManager.sharedInstance.startPedometerUpdates()
            showResetFilterAlert()
        }
        else {
            unconnectView.isHidden = false
            BLSBluetoothManager.shareInstance.stop()
            
            
        }
    }
    
    //MARK: - BluetoothDelegate
    
    func didConnectBlueTooth() {
        changeToConnectMode(connect: true)
        NotificationCenter.default.post(name: kMaskDidConnectBluetoothNoti, object: nil)
    }
    
    func showResetFilterAlert() {
        if !unconnectView.isHidden {
            return
        }
        if (self.view.tag == 12) {
            return
        }
        self.view.tag = 12
        let popTip = PopTip()
        popTip.padding = 0
        popTip.cornerRadius = 8
        popTip.bubbleColor = UIColor(hexString: "ffb83e")!
        popTip.shadowColor = UIColor.black
        popTip.shadowOffset = CGSize(width: 0, height: 2)
        popTip.shadowRadius = 4
        popTip.shadowOpacity = 0.3
        popTip.borderColor = UIColor(hexString: "ffb83e")!
        let tipView = BLTipView(frame: CGRect(x: 0, y: 0, width: 222, height: 44), msg: NSLocalizedString("ResetFilterTimerTip", comment: ""), icon: nil, textColor: UIColor.white, bgColor: UIColor(hexString: "ffb83e")!)
        let frame = self.view.convert(resetFilterBtn.frame, from: resetFilterBtn.superview)
        popTip.show(customView: tipView, direction: .up, in: self.view, from: frame)
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            popTip.hide()
        }
    }
}
