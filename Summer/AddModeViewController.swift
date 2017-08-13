//
//  AddModeViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/11.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class AddModeViewController: BaseViewController {

    
    @IBOutlet weak var activityNameField: UITextField!
    
    @IBOutlet weak var windAcountSlider: UISlider!
    
    @IBOutlet weak var showSwitch: UISwitch!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var windAmountLabel: UILabel!
    @IBOutlet weak var deleteLeading: NSLayoutConstraint!
    
    @IBOutlet weak var saveBtnLeading: NSLayoutConstraint!
    @IBOutlet weak var saveBtnTail: NSLayoutConstraint!
    
    @IBOutlet weak var deleteWidth: UIButton!
    
    let minAmount: CGFloat = 0
    let maxAmount: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showCloseBtn()
        showCustomTitle(title: NSLocalizedString("AddMode", comment: ""))
        
        
    }
    
    
    
    @IBAction func windValueChanged(_ sender: UISlider) {
        
    }
    
    @IBAction func didClickDelete(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didClickSave(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
