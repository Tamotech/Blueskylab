//
//  AboutViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/2.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import WebKit

class AboutViewController: BaseWKWebViewController {

    
    var contentHTML: String?
    var contractWay: String?
    var email: String?
    var weibo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("AboutUs", comment: "");
        let path = Bundle.main.bundlePath
        let baseURL = URL.init(fileURLWithPath: path)
        let htmlPath = Bundle.main.path(forResource: "aboutBSL", ofType: "html")
        let content = try? String.init(contentsOfFile: htmlPath!, encoding: String.Encoding.utf8) as NSString
        if contentHTML != nil {
            let replaceTag = "${contentHtml}"
            let newContent = content?.replacingOccurrences(of: replaceTag, with: contentHTML!)
            self.webView.loadHTMLString(newContent!, baseURL: baseURL)
        }
        
//        let webview = UIWebView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
//        webview.loadHTMLString(content!, baseURL: baseURL)
//        self.view.addSubview(webview)
        
//        let request = URLRequest(url: URL(fileURLWithPath: htmlPath!))
//        self.webView.load(request)
//        self.webView.loadHTMLString(content!, baseURL: baseURL)
        
        
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        if contentHTML == nil {
//            return
//        }
//        let js1 = String.init(format: "document.getElementById(\"contentHtml\").innerHTML=%@", contentHTML!)
//        webView.evaluateJavaScript(js1) { (result, error) in
//            print("\(result.debugDescription), \(String(describing: error?.localizedDescription))")
//        }
    }

}
