//
//  DemoViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/6/16.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DemoViewController: UIViewController {

    let url:String = "http://115.28.128.169:8001/my_cars/15321050030/limit=20&page=1"
    
    var clickBn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        clickBn = UIButton(frame: CGRect(x: 20, y: 64, width: 100, height: 20))
        clickBn.setTitle("click me", for: UIControlState.normal)
        clickBn.setTitleColor(UIColor.red, for: UIControlState.normal)
        clickBn.addTarget(self, action: #selector(handleTapClickBtn(btn:)), for: .touchUpInside)
        self.view.addSubview(clickBn)
        
    }
    
    func handleTapClickBtn(btn:UIButton) {
        self.start_request()
    }
    
    func start_request() {
        Alamofire.request(self.url).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                print(json)
                let json1 = JSON(json)
                print(json1["data"][0]["carDetail"])
            case .failure(let error):
                print(error)
            }
        }
    }


}
