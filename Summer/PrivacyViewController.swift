//
//  PrivacyViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/2.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class PrivacyViewController: BaseViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("PrivacyPolicy", comment: "");
        let path = Bundle.main.bundlePath
        let baseURL = URL.init(fileURLWithPath: path)
        let htmlPath = Bundle.main.path(forResource: "Privacy", ofType: "html")
        let content = try? String.init(contentsOfFile: htmlPath!, encoding: String.Encoding.utf8)
        let webview = UIWebView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        webview.loadHTMLString(content!, baseURL: baseURL)
        self.view.addSubview(webview)
    }

}
