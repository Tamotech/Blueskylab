//
//  BSLAnimationActivityView.swift
//  Summer
//
//  Created by Worthy on 2017/10/18.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

let BSLAnimationViewTag = 123
class BSLAnimationActivityView: UIView {
    
    
    class func showAddToView(view: UIView) {
        let v = view.viewWithTag(BSLAnimationViewTag)
        if v != nil {
            ///防止重复弹窗
            return
        }
        
        let instance = BSLAnimationActivityView(frame: CGRect(x: 0, y: 0, width: 170, height: 170))
        instance.backgroundColor = UIColor(white: 1, alpha: 0.8)
        instance.layer.cornerRadius = 10
        instance.layer.shadowOffset = CGSize(width: 0, height: 5)
        instance.layer.shadowRadius = 10
        instance.layer.shadowColor = UIColor(ri: 92, gi: 143, bi: 181, alpha: 0.8)?.cgColor
        instance.layer.shadowOpacity = 0.4
        instance.center = CGPoint(x: view.width/2, y: view.height/2)
        instance.tag = BSLAnimationViewTag
        
        let webView = UIWebView(frame: instance.bounds)
        //webView.center = CGPoint(x: instance.width/2, y: instance.height/2)
        let path = Bundle.main.path(forResource: "loadingBSL", ofType: "gif")
        let data = try! Data.init(contentsOf: URL(fileURLWithPath: path!))
        webView.scalesPageToFit = true
        webView.contentMode = .scaleAspectFill
        webView.load(data, mimeType: "image/gif", textEncodingName: "utf-8", baseURL: URL.init(string: baseURL)!)
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        instance.addSubview(webView)
        view.addSubview(instance)
        
    }
    
    class func dismiss(view: UIView) {
        let instance = view.viewWithTag(BSLAnimationViewTag)
        instance?.removeFromSuperview()
    }

}
