//
//  UserHandbookController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/30.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class UserHandbookController: BaseViewController {

    
    @IBOutlet weak var webContainer: UIView!
    @IBOutlet weak var webView1: UIWebView!
    @IBOutlet weak var webView2: UIWebView!
    @IBOutlet weak var webView3: UIWebView!
    @IBOutlet weak var segmentContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = NSLocalizedString("UserHandbook", comment:"")
        webView1.isHidden = false
        webView2.isHidden = true
        webView3.isHidden = true
        let segment = BaseSegmentControl(items: [NSLocalizedString("CommenQuestions", comment: ""), NSLocalizedString("AboutProduct", comment: ""), NSLocalizedString("AboutAfterSale", comment: "")], defaultIndex: 0)
        segment.bottom = segment.bottom
        segmentContainer.addSubview(segment)
        segment.selectItemAction = {(index:Int, item: String) in
            
        }
    }

    

}
