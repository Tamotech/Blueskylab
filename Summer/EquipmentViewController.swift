//
//  EquipmentViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/30.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class EquipmentViewController: BaseViewController {

    
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var windLevelLabel: UILabel!
    @IBOutlet weak var moveDistanceLabel: UILabel!
    @IBOutlet weak var clearTimeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("MyEquipment", comment: "")
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
    
}
