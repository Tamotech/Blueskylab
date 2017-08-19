//
//  StartSetGenderViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/1.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import Presentr

class StartSetGenderViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var maleBtn: UIButton!
    
    @IBOutlet weak var femaleBtn: UIButton!
    
    @IBOutlet weak var cameraBtn: UIButton!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    var gender: String = "male"
    var avatarUrl: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        femaleBtn.alpha = 0.5
        nextBtn.isEnabled = false
        cameraBtn.imageView?.contentMode = .scaleAspectFill
    }
    
    
    //MARK: - actions
    
    @IBAction func handleTapMaleBtn(_ sender: Any) {
        maleBtn.alpha = 1
        femaleBtn.alpha = 0.5
        gender = "male"
    }
    
    @IBAction func handleTapFemaleBtn(_ sender: Any) {
        maleBtn.alpha = 0.5
        femaleBtn.alpha = 1
        gender = "female"
    }
    
    @IBAction func handleTapCameraBtn(_ sender: Any) {
        let vc = WXImagePickerViewController.init(nibName: "WXImagePickerViewController", bundle: nil)
        vc.actionCallback = {(type:String) in
            if type == "Album" {
                let picker = UIImagePickerController()
                picker.allowsEditing = false
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }
            else if type == "Camera" {
                let picker = UIImagePickerController()
                picker.allowsEditing = false
                picker.sourceType = .camera
                picker.allowsEditing = false
                picker.cameraDevice = .rear
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
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

    @IBAction func handleTapNextBtn(_ sender: Any) {
        let vc = StartSetBirthViewController(nibName: "StartSetBirthViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
   
    
    //MARK: - ImagePickerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true) {
            let img = info[UIImagePickerControllerOriginalImage] as! UIImage?
            if img != nil {
                self.cameraBtn.setImage(img, for: .normal)
                let data = UIImageJPEGRepresentation(img!, 0.8)!
                MBProgressHUD.showAdded(to: self.view, animated: true)
                APIManager.shareInstance.uploadFile(data: data, result: { [weak self](JSON, code, msg) in
                    MBProgressHUD.hide(for: (self?.view)!, animated: true)
                    if code == 0 {
                        self?.avatarUrl = JSON?["data"]["url"].string ?? ""
                        SessionManager.sharedInstance.loginInfo.avatarUrl = (self?.avatarUrl)!
                        SessionManager.sharedInstance.loginInfo.gender = (self?.gender)!
                        self?.nextBtn.isEnabled = true
                        self?.nextBtn.setImage(#imageLiteral(resourceName: "login-next-on"), for: .normal)
                    }
                    else {
                        BLHUDBarManager.showError(msg: msg)     
                    }
                })
            }
        }
    }

}
