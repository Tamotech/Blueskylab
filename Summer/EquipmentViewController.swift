//
//  EquipmentViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/30.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class EquipmentViewController: BaseViewController, MotionDataDelegate {

    
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var windLevelLabel: UILabel!
    @IBOutlet weak var moveDistanceLabel: UILabel!
    @IBOutlet weak var clearTimeLabel: UILabel!
    
    @IBOutlet weak var stepCountLabel: UILabel!
    
    @IBOutlet weak var caloriesLabel: UILabel!
    
    @IBOutlet weak var connectStatusLabel: UILabel!
    
    @IBOutlet weak var filterLevelLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("MyEquipment", comment: "")
        
        HealthDataManager.sharedInstance.delegate = self
        HealthDataManager.sharedInstance.startPedometerUpdates()
    }
    

   //MARK: - actions
    
    @IBAction func handleTapCleanStepBtn(_ sender: UIButton) {
        let alert = ConfirmAlertView.instanceFromXib() as! ConfirmAlertView
        alert.titleLabel.text = NSLocalizedString("ClearZero", comment: "")
        alert.msgLabel.text = NSLocalizedString("ConfirmClearZeroSteps", comment: "")
        alert.show()
    }

    @IBAction func handleTapCleanCarlorBtn(_ sender: UIButton) {
    }
    
    @IBAction func handleTapUnbindMaskBtn(_ sender: UIButton) {
    }
    
    @IBAction func handleTapChangeBtn(_ sender: UIButton) {
    }
    
    @IBAction func handleTapResetBtn(_ sender: UIButton) {
        let alert = ConfirmAlertView.instanceFromXib() as! ConfirmAlertView
        alert.titleLabel.text = NSLocalizedString("Reset", comment: "")
        alert.msgLabel.text = NSLocalizedString("ResetYourFilter", comment: "")
        alert.show()
    }
    
    
    //MARK: - MotionDelegate
    
    func motionDataUpdate(distance: Float, speed: Float, stepCount: Int) {
        DispatchQueue.main.async {
            self.speedLabel.text = String.init(format: "%.0f", speed*72)
            self.moveDistanceLabel.text = String.init(format: "%.1f", distance/1000)
            self.stepCountLabel.text = "\(stepCount)步"
            let kcal = (SessionManager.sharedInstance.userInfo?.getWeight())!*CGFloat(distance/1000)*1.036
            self.caloriesLabel.text = String.init(format: "%.0fkcal", kcal)
    
        }
    }
    
    func timerStrUpdate(timeStr: String) {
        DispatchQueue.main.async {
            self.clearTimeLabel.text = timeStr
        }
        
    }
}
