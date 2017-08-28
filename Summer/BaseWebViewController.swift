//
//  BaseWebViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/28.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class BaseWebViewController: BaseViewController, UIWebViewDelegate {

    
    var urlString: String?
    var webView = UIWebView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = UIScreen.main.bounds
        webView.delegate = self
        self.view.addSubview(webView)
        if urlString != nil {
            
            let request = URLRequest(url: URL(string: urlString!)!)
            webView.loadRequest(request)
            
        }
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if (self.title?.characters.count == 0) {
            
            guard let title = webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('title')[0].innerHTML;") else {
                return
            }
            self.showCustomTitle(title: title)
        }

    }

}
