//
//  EditPasswordViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/2.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class EditPasswordViewController: BaseViewController {

    
    @IBOutlet weak var currentPasswordField: UITextField!
    
    @IBOutlet weak var newPasswordField: UITextField!
    
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("EditPassword", comment: "")
        let saveItem = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(handleTapSave(_:)))
        self.navigationItem.rightBarButtonItem = saveItem
    }

    @IBAction func handleTapShowBtn(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            break
        case 2:
            break
        case 3:
            break
        default:
            break
        }
    }
    

    //MARK: - actions
    func handleTapSave(_:Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
