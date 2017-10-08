//
//  StartSetWeightViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/1.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import SnapKit

class StartSetWeightViewController: UIViewController {

    
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var weightContainerView: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    var ruler:RuleSelectorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let totalLength = 1000
        let cellLength = 1
        if SessionManager.sharedInstance.loginInfo.gender == "male" {
            ruler = RuleSelectorView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 80), cellLength: cellLength, totalLength: totalLength, cellRuleCount: 10, defaultValue:75, tintColor: UIColor.white)
            self.weightLabel.text = "75.0"
            SessionManager.sharedInstance.loginInfo.weight = 75
        }
        else {
            ruler = RuleSelectorView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 80), cellLength: cellLength, totalLength: totalLength, cellRuleCount: 10, defaultValue:55, tintColor: UIColor.white)
            self.weightLabel.text = "55.0"
            SessionManager.sharedInstance.loginInfo.weight = 55

        }
        
        weightContainerView.addSubview(ruler)
        ruler.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        ruler.selectedValueAction = {[weak self](value) in
            
            self?.weightLabel.text = String.init(format: "%.1f", value)
            SessionManager.sharedInstance.loginInfo.weight = value
        }
    }


    // MARK: - actions
    
    @IBAction func handleTapNextBtn(_ sender: Any) {
        let vc = StartSetHeightViewController(nibName: "StartSetHeightViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }

}
