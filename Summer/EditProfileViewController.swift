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

class EditProfileViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var avartarBtn: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var birthField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        birthField.isUserInteractionEnabled = false
        genderField.isUserInteractionEnabled = false
        heightField.isUserInteractionEnabled = false
        weightField.isUserInteractionEnabled = false
        passwordField.isUserInteractionEnabled = false
        
        self.title = NSLocalizedString("ProfileTitle", comment: "")
        let saveItem = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(handleTapSaveItem(_:)))
        self.navigationItem.rightBarButtonItem = saveItem
        
        self.updateView()
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
        genderField.text = userInfo.sex
        heightField.text = String.init(format: "%.1f cm", userInfo.height)
        weightField.text = String.init(format: "%.1f kg", userInfo.weight)
        if userInfo.sex == "male" {
            genderField.text = NSLocalizedString("male", comment: "")
        }
        else {
            genderField.text = NSLocalizedString("female", comment: "")
        }
    }

    // MARK: - actions
    
    @IBAction func handleTapPassword(_ sender: UITapGestureRecognizer) {
        let EditPsw = EditPasswordViewController()
        self.navigationController?.pushViewController(EditPsw, animated: true)
    }
    
    @IBAction func handleTapBirthday(_ sender: UITapGestureRecognizer) {
        let picker = DatePickerView(title: NSLocalizedString("SelectBirthday", comment: ""))
        picker.pickDateAction = {[weak self] (date: Date) in
            let dateFormmter = DateFormatter()
            dateFormmter.dateFormat = "yyyy年MM月dd日"
            let dateStr = dateFormmter.string(from: date)
            self?.birthField.text = dateStr
        }
        picker.show()
    }
    
    @IBAction func handleTapGender(_ sender: UITapGestureRecognizer) {
        let picker = GenderPickerView(title: NSLocalizedString("SelectGender", comment: ""), items: [NSLocalizedString("Male", comment: ""), NSLocalizedString("Female", comment: "")])
        picker.finishSelectGender = {[unowned self] (item: String) in
            self.genderField.text = item
        }
        picker.show()
    }
    @IBAction func handleTapHeight(_ sender: UITapGestureRecognizer) {
        let sheet = BaseRulerSelectorActionView(title: NSLocalizedString("EditHeight", comment: ""), unit: "cm", defaultValue: 170)
        sheet.finishSelectAction = {[unowned self](value:CGFloat) in
            self.heightField.text = "\(value) cm"
        }
        sheet.show()
    }
    @IBAction func handleTapWeight(_ sender: UITapGestureRecognizer) {
        let sheet = BaseRulerSelectorActionView(title: NSLocalizedString("EditWeight", comment: ""), unit: "kg", defaultValue: 60)
        sheet.finishSelectAction = {[unowned self] (value:CGFloat) in
            self.weightField.text = "\(value) kg"
        }
        sheet.show()
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
    
    
    //MARK: - ImagePickerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
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
    
    
}
