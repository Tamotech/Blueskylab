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
                
                
                let htmlPath = Bundle.main.path(forResource: "Privacy", ofType: "html")
                let originContent = try? String.init(contentsOfFile: htmlPath!, encoding: String.Encoding.utf8) as NSString
                var newContent = originContent?.replacingOccurrences(of: "${contentHtml}", with: (self?.htmlString)!)
                self?.webView.loadHTMLString(newContent!, baseURL: nil)
            }
        }
        webView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(0)
        }
        
    }

}
