//
//  SimpleHUDController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/1.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class SimpleHUDController: UIViewController {

    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var msgLabel: UILabel!
    
    func setupView(img: UIImage, title: String?) {
        iconView.image = img
        msgLabel.text = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        modalPresentationStyle = .overCurrentContext
        // Do any additional setup after loading the view.
    }

}
