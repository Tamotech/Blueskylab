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
        ruler = RuleSelectorView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 80), cellLength: cellLength, totalLength: totalLength, cellRuleCount: 10, defaultValue:178, tintColor: UIColor.white)
        weightContainerView.addSubview(ruler)
        ruler.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        ruler.selectedValueAction = {[weak self] (value) in
            self?.heightLabel.text = String.init(format: "%.1f", value)
            SessionManager.sharedInstance.loginInfo.height = value
        }
        
    }
    
    
    // MARK: - actions
    
    @IBAction func handleTapNextBtn(_ sender: Any) {
        
        if (SessionManager.sharedInstance.loginInfo.wxid.characters.count > 0) {
            //微信绑定注册
            let vc =  LoginViewController(nibName: "LoginViewController", bundle: nil)
            vc.mode = .wxRegist
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        //注册
        SVProgressHUD.show()
        SessionManager.sharedInstance.regist { (JSON, code, msg) in
            if code == 0 {
                //注册成功 登录成功成功
                if code == 1 {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        let sb = UIStoryboard(name: "Main", bundle: nil)
                        let vc = sb.instantiateViewController(withIdentifier: "startNavigationVC")
                        UIApplication.shared.keyWindow!.rootViewController = vc
                    }
                }
                else {
                    SVProgressHUD.showError(withStatus: msg)
                }
            }
            else {
                SVProgressHUD.showError(withStatus: msg)
            }
        }
    }
    
}
