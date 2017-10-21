//
//  AddModeViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/11.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit



class AddModeViewController: BaseViewController {

    
    let padding: CGFloat = 25
    
    @IBOutlet weak var activityNameField: UITextField!
    
    @IBOutlet weak var windAcountSlider: UISlider!
    
    @IBOutlet weak var showSwitch: UISwitch!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var windAmountLabel: UILabel!
    @IBOutlet weak var deleteLeading: NSLayoutConstraint!
    
    @IBOutlet weak var saveBtnLeading: NSLayoutConstraint!
    @IBOutlet weak var saveBtnTail: NSLayoutConstraint!
    
    @IBOutlet weak var deleteButtonWidth: NSLayoutConstraint!
    
    @IBOutlet weak var resetButton: UIButton!
    
    
    lazy var config: UserWindSpeedConfig = {
        let co = UserWindSpeedConfig()
        co.type = "custom"
        return co
    }()
    
    let minAmount: CGFloat = 0
    let maxAmount: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showCloseBtn()
        if config.name.characters.count > 0 {
            showCustomTitle(title: NSLocalizedString("EditMode", comment: ""))
        }
        else {
            showCustomTitle(title: NSLocalizedString("AddMode", comment: ""))
        }
        
        let width = (screenWidth-padding*3)/2.0
        if config.type == "custom" {
            //自定义模式
            deleteLeading.constant = padding
            saveBtnLeading.constant = padding
            deleteButtonWidth.constant = width
            deleteBtn.isHidden = false
            activityNameField.isEnabled = true
            resetButton.isHidden = true
        }
        else {
            deleteLeading.constant = 0
            saveBtnLeading.constant = padding
            deleteButtonWidth.constant = 0
            deleteBtn.isHidden = true
            activityNameField.isEnabled = false
            resetButton.isHidden = false
        }
        
        activityNameField.text = config.name
        windAcountSlider.value = Float(config.value)
        windAmountLabel.text = "\(Int(config.value))"
        showSwitch.isOn = (config.hideflag == 0)
        
    }
    
    @IBAction func windValueChanged(_ sender: UISlider) {
        windAmountLabel.text = "\(Int(sender.value))"
        config.value = Int(sender.value)
    }
    
    
    @IBAction func handleTapResetButton(_ sender: UIButton) {
        
        config.value = config.defvalue
        windAcountSlider.value = Float(config.defvalue)
        windAmountLabel.text = "\(Int(config.defvalue))"
        
    }
    
    @IBAction func didClickDelete(_ sender: UIButton) {
        
        if config.id.characters.count == 0 {
            dismiss(animated: true, completion: nil)
            return
        }
        let alert = ConfirmAlertView.instanceFromXib() as! ConfirmAlertView
        alert.titleLabel.text = NSLocalizedString("Delete", comment: "")
        alert.msgLabel.text = NSLocalizedString("DeleteThisMode", comment: "")
        alert.show()
        alert.confirmCalback = {[weak self] Void in
            self?.config.delete { [weak self](success, msg) in
                if success {
                    for i in 0..<SessionManager.sharedInstance.windModeManager.windUserConfigList.count {
                        let item = SessionManager.sharedInstance.windModeManager.windUserConfigList[i]
                        if item.id == self?.config.id {
                            SessionManager.sharedInstance.windModeManager.windUserConfigList.remove(at: i)
                            NotificationCenter.default.post(name: kWindModeConfigDidDeleteNotify, object: ["id": self?.config.id])
                            break
                        }
                    }
                    self?.dismiss(animated: true, completion: nil)
                }
                else {
                    BLHUDBarManager.showError(msg: msg)
                }
            }

        }
        
    }
    
    @IBAction func didClickSave(_ sender: UIButton) {
        
        config.hideflag = showSwitch.isOn ? 0 : 1
        config.name = activityNameField.text!
        
        if config.name.characters.count == 0 {
            return
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        if config.id.characters.count > 0 {
            //修改
            config.update { [weak self](success, msg) in
                MBProgressHUD.hide(for: (self?.view)!, animated: true)
                if success {
                    self?.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: kWindModeConfigDidChangeNotify, object: nil)
                }
                else {
                    BLHUDBarManager.showError(msg: msg)
                }
            }
        }
        else {
            //添加
            config.add { [weak self](success, msg) in
                MBProgressHUD.hide(for: (self?.view)!, animated: true)
                if success {
                    let manager =  SessionManager.sharedInstance.windModeManager
                    manager.windUserConfigList.append((self?.config)!)
                    self?.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: kWindModeConfigDidChangeNotify, object: nil)
                }
                else {
                    BLHUDBarManager.showError(msg: msg)
                }
            }
        }
        
    }

}
