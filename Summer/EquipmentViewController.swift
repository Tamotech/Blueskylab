//
//  EquipmentViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/30.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class EquipmentViewController: BaseViewController, MotionDataDelegate, BluetoothViewDelegate {

    
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var windLevelLabel: UILabel!
    @IBOutlet weak var moveDistanceLabel: UILabel!
    @IBOutlet weak var clearTimeLabel: UILabel!
    
    @IBOutlet weak var stepCountLabel: UILabel!
    
    @IBOutlet weak var caloriesLabel: UILabel!
    
    @IBOutlet weak var connectStatusLabel: UILabel!
    
    @IBOutlet weak var filterLevelLabel: UILabel!
    
    @IBOutlet weak var unconnectView: UIView!
    
    var currentSteps: Int = 0
    var currentDistance: Float = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("MyEquipment", comment: "")
        ///过滤等级
        let level = SessionManager.sharedInstance.userMaskConfig.maskFilterLevel()
        filterLevelLabel.text = level.0
        
        HealthDataManager.sharedInstance.delegate = self
        ///风速
        windLevelLabel.text = String.init(format: "%.0f", BLSBluetoothManager.shareInstance.currentWindSpeed)
        
        let manager = BLSBluetoothManager.shareInstance
        manager.stateUpdate = {(state: BluetoothState) in
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
        
        if manager.state == BluetoothState.Connected {
            unconnectView.isHidden = true
            HealthDataManager.sharedInstance.startPedometerUpdates()
        }
        else {
            unconnectView.isHidden = false
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
        BLSBluetoothManager.shareInstance.stop()
        HealthDataManager.sharedInstance.saveMaskUseData()
        self.changeToConnectMode(connect: false)
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
            self.speedLabel.text = "0"
            self.moveDistanceLabel.text = "0"
            self.stepCountLabel.text = "0步"
            self.caloriesLabel.text = "0kcal"
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
            self.speedLabel.text = String.init(format: "%.0f", speed*72)
            self.moveDistanceLabel.text = String.init(format: "%.1f", distance/1000)
            self.stepCountLabel.text = "\(stepCount)步"
//            let kcal = (SessionManager.sharedInstance.userInfo?.getWeight())!*CGFloat(distance/1000)*1.036
            self.caloriesLabel.text = String.init(format: "%.0fkcal", carlories)
            self.currentSteps = stepCount
            self.currentDistance = distance
    
        }
    }
    
    func timerStrUpdate(timeStr: String) {
        DispatchQueue.main.async {
            self.clearTimeLabel.text = timeStr
        }
        
    }
    
    func changeToConnectMode(connect: Bool) {
        if connect {
            unconnectView.isHidden = true
            HealthDataManager.sharedInstance.startPedometerUpdates()
        }
        else {
            unconnectView.isHidden = false
            
        }
    }
    
    //MARK: - BluetoothDelegate
    
    func didConnectBlueTooth() {
        changeToConnectMode(connect: true)
        NotificationCenter.default.post(name: kMaskDidConnectBluetoothNoti, object: nil)
    }
}
