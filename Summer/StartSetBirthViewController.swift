//
//  StartSetBirthViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/1.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class StartSetBirthViewController: UIViewController {

    
    
    @IBOutlet weak var birthButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: - actions
    
    @IBAction func handleTapCancelBtn(_ sender: Any) {
        
    }
    
    @IBAction func handleTapConfirmBtn(_ sender: Any) {
        
        let date = datePicker.date
        let str = date.stringOfDay()
        SessionManager.sharedInstance.loginInfo.birthday = str
        let vc = StartSetWeightViewController(nibName: "StartSetWeightViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
