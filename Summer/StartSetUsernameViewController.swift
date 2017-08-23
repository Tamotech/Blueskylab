//
//  StartSetUsernameViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/1.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class StartSetUsernameViewController: UIViewController {

    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let placeholderLb1 = nameField.value(forKey: "_placeholderLabel") as! UILabel?
        let color = UIColor(white: 1, alpha: 0.8)
        placeholderLb1?.textColor = color
        
        nameField.reactive.continuousTextValues.observeValues { (text) in
            if text?.characters.count ?? 0 > 0 {
                self.nextButton.isEnabled = true
                self.nextButton.setImage(UIImage(named: "login-next-on"), for: .normal)
            }
            else {
                self.nextButton.isEnabled = false
                self.nextButton.setImage(UIImage(named: "login-next-off"), for: .normal)

            }
        }
        
        guard let wxUsere =  SessionManager.sharedInstance.wxUserInfo else {
            return
        }
        nameField.text = wxUsere.nickname
    }

    

    //MARK: - actions
    @IBAction func handleTapNextBtn(_ sender: Any) {
        
        let name = nameField.text!
        SessionManager.sharedInstance.loginInfo.name = name
        
        let vc = StartSetGenderViewController(nibName: "StartSetGenderViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    

}
