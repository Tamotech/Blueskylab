//
//  EditProfileViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/6/25.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import Kingfisher
import Presentr

class EditProfileViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var avartarBtn: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var birthField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    
    ///是否有修改操作
    var change = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        birthField.isUserInteractionEnabled = false
        genderField.isUserInteractionEnabled = false
        heightField.isUserInteractionEnabled = false
        weightField.isUserInteractionEnabled = false
        nameField.delegate = self
        
        self.title = NSLocalizedString("ProfileTitle", comment: "")
        let saveItem = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(handleTapSaveItem(_:)))
        self.navigationItem.rightBarButtonItem = saveItem
        
        self.updateView()
        
        let backItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav-back-dark"), style: .plain, target: self, action: #selector(exitController(sender:)))
        navigationItem.leftBarButtonItem = backItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: - updateView
    
    func updateView() {
        guard let userInfo = SessionManager.sharedInstance.userInfo else {
            return
        }
        if userInfo.headimg.characters.count>0 {
            let img = ImageResource(downloadURL: URL(string: userInfo.headimg.urlStringWithBLS())!)
            avartarBtn.kf.setImage(with: img, for: .normal)
        }
        
        nameField.text = userInfo.name
        phoneField.text = userInfo.mobile
        birthField.text = userInfo.birthday
        if userInfo.height < 10 {
            userInfo.height = 170
        }
        if userInfo.weight < 10 {
            userInfo.weight = 60
        }
        heightField.text = String.init(format: "%.1f cm", userInfo.getHeight())
        weightField.text = String.init(format: "%.1f kg", userInfo.getWeight())
        if userInfo.sex == "male" {
            genderField.text = NSLocalizedString("Male", comment: "")
        }
        else {
            genderField.text = NSLocalizedString("Female", comment: "")
        }
    }

    // MARK: - actions
    
    @IBAction func handleTapPassword(_ sender: UITapGestureRecognizer) {
        let EditPsw = EditPasswordViewController()
        self.navigationController?.pushViewController(EditPsw, animated: true)
    }
    
    @IBAction func handleTapBirthday(_ sender: UITapGestureRecognizer) {
        let dateFormmter = DateFormatter()
        dateFormmter.dateFormat = "yyyy年MM月dd日"
        let dateStr = birthField.text ?? ""
        var date = dateFormmter.date(from: "1990年01月01日")
        if dateStr.contains("年") && dateStr.contains("月") && dateStr.contains("日") {
            date = dateFormmter.date(from: dateStr)
        }
        let picker = DatePickerView(title: NSLocalizedString("SelectBirthday", comment: ""))
        picker.picker.date = date!
        picker.pickDateAction = {[weak self] (date: Date) in
            let dateFormmter = DateFormatter()
            dateFormmter.dateFormat = "yyyy年MM月dd日"
            let dateStr = dateFormmter.string(from: date)
            self?.birthField.text = dateStr
        }
        picker.show()
        change = true
    }
    
    @IBAction func handleTapGender(_ sender: UITapGestureRecognizer) {
        let picker = GenderPickerView(title: NSLocalizedString("SelectGender", comment: ""), items: [NSLocalizedString("Male", comment: ""), NSLocalizedString("Female", comment: "")])
        picker.finishSelectGender = {[unowned self] (item: String) in
            self.genderField.text = item
        }
        picker.show()
        change = true
    }
    @IBAction func handleTapHeight(_ sender: UITapGestureRecognizer) {
        var defaultValue: CGFloat = 170
        let str = heightField.text ?? ""
        if str.contains("cm") {
            defaultValue = str.getFloatFromString()
        }
        if defaultValue == 0 {
            defaultValue = 170
        }
        let sheet = BaseRulerSelectorActionView(title: NSLocalizedString("EditHeight", comment: ""), unit: "cm", defaultValue: defaultValue)
        sheet.finishSelectAction = {[unowned self](value:CGFloat) in
            self.heightField.text = "\(value) cm"
        }
        sheet.show()
        change = true
    }
    @IBAction func handleTapWeight(_ sender: UITapGestureRecognizer) {
        var defaultValue: CGFloat = 60
        let str = weightField.text ?? ""
        if str.contains("kg") {
            defaultValue = str.getFloatFromString()
        }
        if defaultValue == 0 {
            defaultValue = 60
        }
        let sheet = BaseRulerSelectorActionView(title: NSLocalizedString("EditWeight", comment: ""), unit: "kg", defaultValue: defaultValue)
        sheet.finishSelectAction = {[unowned self] (value:CGFloat) in
            self.weightField.text = "\(value) kg"
        }
        sheet.show()
        change = true
    }
    
    
    @IBAction func handleTapAvatar(_ sender: UITapGestureRecognizer) {
        
        let vc = WXImagePickerViewController.init(nibName: "WXImagePickerViewController", bundle: nil)
        vc.actionCallback = {[weak self](type:String) in
            if type == "Album" {
                let picker = UIImagePickerController()
                picker.allowsEditing = false
                picker.sourceType = .photoLibrary
                picker.allowsEditing = false
                picker.delegate = self
                self?.present(picker, animated: true, completion: nil)
            }
            else if type == "Camera" {
                let picker = UIImagePickerController()
                picker.allowsEditing = false
                picker.sourceType = .camera
                picker.allowsEditing = false
                picker.cameraDevice = .rear
                picker.delegate = self
                self?.present(picker, animated: true, completion: nil)
            }
        }
        let presenter: Presentr = {
            let presenter = Presentr(presentationType: .bottomHalf)
            presenter.transitionType = TransitionType.coverVertical
            presenter.dismissOnSwipe = true
            presenter.dismissAnimated = true
            return presenter
        }()
        
        customPresentViewController(presenter, viewController: vc, animated: true) { 
            
        }

    }
    
    func handleTapSaveItem(_:Any) {
        saveUser()
    }
    
    
    //MARK: - ImagePickerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        change = true
        picker.dismiss(animated: true) {
            let img = info[UIImagePickerControllerOriginalImage] as! UIImage?
            if img != nil {
            self.avartarBtn.setImage(img!, for: .normal)
                let data = UIImageJPEGRepresentation(img!, 0.8)!
                MBProgressHUD.showAdded(to: self.view, animated: true)
                APIManager.shareInstance.uploadFile(data: data, result: { [weak self](JSON, code, msg) in
                    MBProgressHUD.hide(for: (self?.view)!, animated: true)
                    if code == 0 {
                        let avatarUrl = JSON?["data"]["url"].string ?? ""
                        SessionManager.sharedInstance.userInfo?.headimg = avatarUrl
                    }
                    else {
                        BLHUDBarManager.showError(msg: msg)
                    }
                })
            }
        }
    }
    
    //MARK: - textfield delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameField {
            if textField.text!.utf8.count >= 30 && string != "" {
                
                return false
            }
        }
        
        self.change = true
        return true
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if textField == nameField {
//            if textField.text!.characters.count > 30 {
//                let endIndex = textField.text!.index(textField.text!.startIndex, offsetBy: 30)
//                textField.text = textField.text?.substring(to: endIndex)
//                self.change = true
//            }
//        }
//    }
    
    ///退出操作
    func exitController(sender: UIButton) {
        
        if change {
            let alert = ConfirmAlertView.instanceFromXib() as! ConfirmAlertView
            alert.titleLabel.text = NSLocalizedString("Exit", comment: "")
            alert.msgLabel.text = NSLocalizedString("ConfirmDropThis", comment: "")
            alert.cancelBtn.setTitle(NSLocalizedString("Exit", comment: ""), for: .normal)
            alert.confirmBtn.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
            alert.confirmCalback = {
                self.saveUser()
            }
            alert.cancelCalback = {
                self.navigationController?.popViewController(animated: true)
            }
            alert.show()
        }
        else {
            self.navigationController?.popViewController(animated: true)

        }
        
    }
    
    func saveUser() {
        //更新 user
        let userInfo = SessionManager.sharedInstance.userInfo
        userInfo?.name = nameField.text ?? ""
        userInfo?.sex = genderField.text ?? "male"
        userInfo?.birthday = birthField.text ?? ""
        let w = weightField.text
        let h = heightField.text
        if w != nil {
            userInfo?.weight = w!.getFloatFromString()
        }
        if h != nil {
            userInfo?.height = h!.getFloatFromString()
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        userInfo?.updateUserInfo(result: { [weak self](success, msg) in
            MBProgressHUD.hide(for: (self?.view)!, animated: true)
            if success {
                SVProgressHUD.showSuccess(withStatus: msg)
                self?.navigationController?.popViewController(animated: true)
            }
            else {
                SVProgressHUD.showError(withStatus: msg)
            }
        })
    }
}
