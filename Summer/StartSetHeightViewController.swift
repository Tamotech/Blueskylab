//
//  StartSetHeightViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/2.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class StartSetHeightViewController: UIViewController {

    @IBOutlet weak var heightLabel: UILabel!
    
    @IBOutlet weak var weightContainerView: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    var ruler:RuleSelectorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let totalLength = 200
        let cellLength = 1
        
        if SessionManager.sharedInstance.loginInfo.gender == "male" {
            ruler = RuleSelectorView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 90), cellLength: cellLength, totalLength: totalLength, cellRuleCount: 10, defaultValue:170, tintColor: UIColor.white)
            self.heightLabel.text = "170.0"
            SessionManager.sharedInstance.loginInfo.height=170
        }
        else {
            ruler = RuleSelectorView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 90), cellLength: cellLength, totalLength: totalLength, cellRuleCount: 10, defaultValue:160, tintColor: UIColor.white)
            self.heightLabel.text = "160.0"
            SessionManager.sharedInstance.loginInfo.height=160
            
        }
        
        weightContainerView.addSubview(ruler)
        ruler.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        ruler.selectedValueAction = {[weak self] (value) in
            self?.heightLabel.text = String.init(format: "%.1f", value)
            SessionManager.sharedInstance.loginInfo.height = value
        }
        ruler.selectedValueAction = {[weak self](value) in
            
            self?.heightLabel.text = String.init(format: "%.1f", value)
            SessionManager.sharedInstance.loginInfo.height = value
        }
    }
    
    
    // MARK: - actions
    
    @IBAction func handleTapNextBtn(_ sender: Any) {
        
        //注册
        SVProgressHUD.show()
        SessionManager.sharedInstance.regist { [weak self](JSON, code, msg) in
            if code == 0 {
                //注册成功 登录成功
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                }
                
            }
            else {
                SVProgressHUD.showError(withStatus: msg)
            }
        }
    }
    
}
