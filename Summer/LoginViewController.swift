//
//  LoginViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/1.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import Presentr
import Kingfisher

class LoginViewController: BaseViewController, UITextFieldDelegate {

    
    enum LoginMode {
        case login
        case regist
    }
    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet weak var photoVertifyCodeField: UITextField!
    
    @IBOutlet weak var smsCodeField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var captureBtn: UIButton!
    
    @IBOutlet weak var phoneCheckMark: UIImageView!
    
    @IBOutlet weak var captureCheckMark: UIImageView!
    
    @IBOutlet weak var smsCheckMark: UIImageView!
    @IBOutlet weak var sendSMSBtn: UIButton!
    var smsCode: String?
    var captcha: String?
    var seconds = 60
    var timer: Timer?
    
    var mode: LoginMode = .login
    
    //测试账号
    let testPhone = "15721261417"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.shouldClearNavBar = true
        setupView()
        getCapture()
        
    }
    
    deinit {
        //timer!.invalidate()
        timer = nil
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
        
        phoneCheckMark.isHidden = true
        captureCheckMark.isHidden = true
        smsCheckMark.isHidden = true
        sendSMSBtn.isEnabled = false
        
        nextBtn.isEnabled = false
        phoneField.delegate = self
        photoVertifyCodeField.delegate = self
        smsCodeField.delegate = self

    }
    
    func setupTimer() {
        timer = Timer(timeInterval: 1, target: self, selector: #selector(timerValueChanged(t:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    //MARK: - TextfieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        var phone = phoneField.text ?? ""
        var captureStr = photoVertifyCodeField.text ?? ""
        var sms = smsCodeField.text ?? ""
        if textField == phoneField {
            phone = newText
            if phone.count == 11 {
                checkPhoneNum(phone: phone)
            }
            else {
                phoneCheckMark.isHidden = true
            }
        }
        else if textField == photoVertifyCodeField {
            captureStr = newText
            if captureStr.count > 0 && captureStr.count == captcha?.count {
                vertifyCapture(captureString: captureStr)
                sendSMSBtn.isEnabled = true
            }
            else {
                sendSMSBtn.isEnabled = false
                captureCheckMark.isHidden = true
                captureBtn.isHidden = false
            }
        }
        else if textField == smsCodeField {
            sms = newText
            if sms.count > 0 && sms == self.smsCode {
                self.smsCheckMark.isHidden = false
                self.sendSMSBtn.isHidden = true
            }
            else if sms.count > 0 && sms.count == self.smsCode?.count && sms != self.smsCode {
                self.smsCheckMark.isHidden = true
                self.sendSMSBtn.isHidden = false
                //输入错误
                BLHUDBarManager.showErrorWithClose(msg: NSLocalizedString("SMSDigitWrong", comment: ""), descTitle: NSLocalizedString("returnAndReinput", comment: ""))
            }
            else {
                self.smsCheckMark.isHidden = true
                self.sendSMSBtn.isHidden = false
            }
        }
        
        if !phoneCheckMark.isHidden && !captureCheckMark.isHidden && !smsCheckMark.isHidden {
            nextBtn.setImage(#imageLiteral(resourceName: "login-next-on"), for: .normal)
            nextBtn.isEnabled = true
        }
        else {
            nextBtn.setImage(#imageLiteral(resourceName: "login-next-off"), for: .normal)
            nextBtn.isEnabled = false
        }
        return true
    }
    

    ///Timer
    func timerValueChanged(t: Timer) {
        seconds = seconds - 1
        if seconds <= 0 {
            sendSMSBtn.setTitle(NSLocalizedString("ReSendSMS", comment: ""), for: .normal)
            t.invalidate()
            timer = nil
        }
        else {
            sendSMSBtn.setTitle(String.init(format: "%ds", seconds), for: .normal)
        }
        
    }
    
    //MARK: - API
    
    //校验手机号
    func checkPhoneNum(phone: String) {
        if !phone.validPhoneNum() {
            BLHUDBarManager.showErrorWithClose(msg: NSLocalizedString("WrongPhoneNum", comment: ""), descTitle: NSLocalizedString("returnAndReinput", comment: ""))
            return
        }
        
        APIManager.shareInstance.postRequest(urlString: "/regist/checkMobile.htm", params: ["mobile": phone.trip()]) { [weak self](result, code, msg) in
            if code == 0 {
                //手机号校验通过
                self?.phoneCheckMark.isHidden = false
                self?.mode = .regist
            }
            else if code == -111 {
                //手机号已注册
                self?.phoneCheckMark.isHidden = false
                self?.mode = .login
                
            }
            else {
                 BLHUDBarManager.showErrorWithClose(msg: msg, descTitle: NSLocalizedString("returnAndReinput", comment: ""))
            }
        }

    }
    
    //获取图形验证码
    func getCapture() {
        APIManager.shareInstance.postRequest(urlString: "/captcha/newCaptcha.htm?width=60", params: nil) { [weak self](result, code, msg) in
            if code == 0 && result != nil {
                let info = result!["info"].string ?? ""
                self?.captcha = DES3EncryptUtil.decrypt(info)
                let url = result!["memo"].string ?? ""
                
                self?.captureBtn.kf.setImage(with: ImageResource(downloadURL: URL(string: url)!), for: .normal)
            }
        }
    }
    
    //验证图形验证码
    func vertifyCapture(captureString: String) {
        if captcha?.uppercased() == captureString.uppercased() {
            //通过
            captureBtn.isHidden = true
            captureCheckMark.isHidden = false
            self.sendSMSCode()
        }
        else {
            BLHUDBarManager.showErrorWithClose(msg: NSLocalizedString("CaptureWrong", comment: ""), descTitle: NSLocalizedString("returnAndReinput", comment: ""))
        }
    }
    
    //发送短信验证码
    func sendSMSCode() {
        
        if seconds > 0 && seconds < 60 {
            return
        }
        let phone = phoneField.text!
        if !phone.validPhoneNum() {
            
            BLHUDBarManager.showError(msg: NSLocalizedString("WrongPhoneNum", comment: ""))
            return
        }
        APIManager.shareInstance.postRequest(urlString: "/smscaptcha/sendSms.htm", params: ["mobile": phone]) { [weak self](result, code, msg) in
            if code == 0 && result != nil {
                
                let smsCodeStr = result?["memo"].string!
                self?.smsCode = DES3EncryptUtil.decrypt(smsCodeStr)
                BLHUDBarManager.showSuccess(msg: NSLocalizedString("VertifyCodeHasSent", comment: ""), seconds: 2)
                
                //TEST
                //如果是测试账号自动填充
                if phone == self?.testPhone {
                    self?.smsCodeField.text = self?.smsCode!
                    self?.setNextButtonEnable(enable: true)
                }
                
                self?.setupTimer()
//                self?.timer!.fire()
                self?.seconds = 60
            }
            else {
                BLHUDBarManager.showErrorWithClose(msg: msg, descTitle: NSLocalizedString("returnAndReinput", comment: ""))
            }
        }
    }

    @IBAction func handleTapPhotoCodeBtn(_ sender: UIButton) {
        getCapture()
    }
    
    @IBAction func handleTapSendSmsCodeBtn(_ sender: UIButton) {
        
        sendSMSCode()
    }
    
    @IBAction func handleTapNextBtn(_ sender: UIButton) {
        let phone = phoneField.text!.trip()
        let captchaStr = smsCodeField.text!.trip()
        SessionManager.sharedInstance.loginInfo.phone = phone
        SessionManager.sharedInstance.loginInfo.captcha = captchaStr
        
        if mode == .login {
            
            //登录
            MBProgressHUD.showAdded(to: self.view, animated: true)
            SessionManager.sharedInstance.login(results: { [weak self](json, code, msg) in
                if code == 0 {
                    //注册成功 登录成功
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self?.navigationController?.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    MBProgressHUD.hide(for: (self?.view)!, animated: true)
                    BLHUDBarManager.showErrorWithClose(msg: msg, descTitle: NSLocalizedString("returnAndReinput", comment: ""))
                    
                }
            })
        }
        else {
            //注册
            SessionManager.sharedInstance.loginInfo.phone = phone
            SessionManager.sharedInstance.loginInfo.captcha = captchaStr
            let setnameVC = StartSetUsernameViewController(nibName: "StartSetUsernameViewController", bundle: nil)
            navigationController?.pushViewController(setnameVC, animated: true)
        }
        
    }
    
    //MARK: - private
    
    func setNextButtonEnable(enable: Bool) {
        if enable {
            nextBtn.setImage(#imageLiteral(resourceName: "login-next-on"), for: .normal)
            nextBtn.isEnabled = true
        }
        else {
            nextBtn.setImage(#imageLiteral(resourceName: "login-next-off"), for: .normal)
            nextBtn.isEnabled = false
        }

    }
    
}
