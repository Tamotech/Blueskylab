//
//  BaseWKWebViewController.swift
//  BestNews
//
//  Created by 武淅 段 on 2017/9/26.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import WebKit
import SnapKit
import SwiftyJSON

class BaseWKWebViewController: BaseViewController, WKNavigationDelegate {

    let webView = WKWebView()
    var urlString: String?
    var htmlString: String?
    
    var articleStr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(webView)
        webView.navigationDelegate = self
        if htmlString != nil {
            webView.loadHTMLString(htmlString!, baseURL: nil)
        }
        else if urlString != nil {
            if !urlString!.hasPrefix("http://") {
                urlString = baseURL+urlString!
            }
            let url = URL(string: urlString!)!
            webView.load(URLRequest(url: url))
        }
        else if articleStr != nil {
            APIRequest.getUserConfig(codes: articleStr!) { [weak self](JSONData) in
                let data = JSONData as! JSON
                self?.htmlString = data[(self?.articleStr)!]["v"].stringValue
                self?.webView.loadHTMLString((self?.htmlString)!, baseURL: nil)
            }
        }
        webView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(0)
        }
        
    }

}
