//
//  NotificationDetailController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/30.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class NotificationDetailController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("NotificationDetail", comment: "");
        let shareItem = UIBarButtonItem(image: UIImage(named:"icon-share"), style: .plain, target: self, action: #selector(handleShareAction(_:)))
        self.navigationItem.rightBarButtonItem = shareItem
        
        let path = Bundle.main.bundlePath
        let baseURL = URL.init(fileURLWithPath: path)
        let htmlPath = Bundle.main.path(forResource: "notification", ofType: "html")
        let content = try? String.init(contentsOfFile: htmlPath!, encoding: String.Encoding.utf8)
        let webview = UIWebView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        webview.loadHTMLString(content!, baseURL: baseURL)
        self.view.addSubview(webview)
    }
    
    func handleShareAction(_ sender:Any) {
        
        let sheet = BottomWechatShareView.instanceFromXib() as! BottomWechatShareView
        sheet.show()
    }

}
