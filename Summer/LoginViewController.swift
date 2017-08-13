//
//  LoginViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/1.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Presentr
import Kingfisher

class LoginViewController: BaseViewController {

    
    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet weak var photoVertifyCodeField: UITextField!
    
    @IBOutlet weak var smsCodeField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var captureBtn: UIButton!
    
    var capture :String?        //验证码
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.shouldClearNavBar = true
        setupView()
        RXObserve()
        getCapture()
        
    }
    
    func RXObserve() {
        nextBtn.setImage(UIImage(named: "login-next-off"), for: .normal)
        nextBtn.isEnabled = false
        let phoneTFSignal = phoneField.reactive.continuousTextValues.map({
            text in
            return (text?.characters.count)!
        })
        
        let passwordTFSignal = photoVertifyCodeField.reactive.continuousTextValues.map({
            text in
            return (text?.characters.count)!
        })
        
        let smsTFSignal = smsCodeField.reactive.continuousTextValues.map({
            text in
            return (text?.characters.count)!
        })
        
        Signal.combineLatest(phoneTFSignal, passwordTFSignal, smsTFSignal).map ({ [weak self](length1: Int, length2: Int, length3: Int) -> Bool in
            if self?.capture != nil && length2 == self?.capture?.characters.count {
                ///验证图形验证码
                self?.vertifyCapture()
            }
            return length1 > 0 && length2 > 0 && length3 > 0
        }).observeValues { [weak self](valid) in
            self?.nextBtn.isEnabled = valid
            self?.nextBtn.setImage(valid ? UIImage(named: "login-next-on") : UIImage(named: "login-next-off"), for: .normal)
        }
        
    }
    
    func setupView() {
        let placeholderLb1 = phoneField.value(forKey: "_placeholderLabel") as! UILabel?
        let placeholderLb2 = photoVertifyCodeField.value(forKey: "_placeholderLabel") as! UILabel?
        let placeholderLb3 = smsCodeField.value(forKey: "_placeholderLabel") as! UILabel?
        if placeholderLb1 == nil {
            return
        }
        let color = UIColor(white: 1, alpha: 0.8)
        placeholderLb1?.textColor = color
        placeholderLb2?.textColor = color
        placeholderLb3?.textColor = color

    }

    
    //MARK: - API
    
    func getCapture() {
        APIManager.shareInstance.getRequest(urlString: "/captcha/newCaptcha.do?width=60", params: nil) { [weak self](result, code, msg) in
            if code == 0 && result != nil {
                let info = result!["info"].string ?? ""
                self?.capture = DES3EncryptUtil.decrypt(info)
                let url = result!["memo"].string ?? ""
                
                self?.captureBtn.kf.setImage(with: ImageResource(downloadURL: URL(string: url)!), for: .normal)
            }
        }
    }
    
    //验证图形验证码
    func vertifyCapture() {
        let cap = photoVertifyCodeField.text!
        if capture?.uppercased() == cap.uppercased() {
            //通过
            captureBtn.setImage(#imageLiteral(resourceName: "checkmark"), for: .normal)
        }
    }
    
    //发送短信验证码
    func sendSMSCode() {
        let phone = phoneField.text!
        if !phone.validPhoneNum() {
            
            BLHUDBarManager.showError(msg: NSLocalizedString("WrongPhoneNum", comment: ""))
            return
        }
        APIManager.shareInstance.getRequest(urlString: "/regist/sendSms.htm", params: ["mobile": phone]) { [weak self](result, code, msg) in
            if code == 0 && result != nil {
                BLHUDBarManager.showSuccess(msg: NSLocalizedString("VertifyCodeHasSent", comment: ""))
            }
            else {
                SVProgressHUD.showErrorWithStatus(status: msg)
            }
        }
    }

    @IBAction func handleTapPhotoCodeBtn(_ sender: UIButton) {
        getCapture()
    }
    
    @IBAction func handleTapSendSmsCodeBtn(_ sender: UIButton) {
        
        guard let phone = phoneField.text else {
            
            return
        }
        if !phone.validPhoneNum() {
            
            BLHUDBarManager.showError(msg: NSLocalizedString("WrongPhoneNum", comment: ""))
            return
        }
        
        APIManager.shareInstance.getRequest(urlString: "/regist/checkMobile.htm", params: ["mobile": phone.trip()]) { (result, code, msg) in
            
        }
        BLHUDBarManager.showSuccess(msg: NSLocalizedString("VertifyCodeHasSent", comment: ""))
    }
    
    @IBAction func handleTapNextBtn(_ sender: UIButton) {
        
        let setnameVC = StartSetUsernameViewController(nibName: "StartSetUsernameViewController", bundle: nil)
        navigationController?.pushViewController(setnameVC, animated: true)
    }
    
}
