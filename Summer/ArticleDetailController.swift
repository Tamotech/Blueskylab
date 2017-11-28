//
//  ArticleDetailController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/28.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import WebKit

/// 文章详情页
class ArticleDetailController: BaseWKWebViewController {

    ///文章 id
    var articleId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.showCustomTitle(title: NSLocalizedString("QuestionDetail", comment: ""))
        self.loadArticle()
    }

    func loadArticle() {
        if articleId.count > 0 {
            let url = "/article/detail.htm?id=\(articleId)"
            MBProgressHUD.showAdded(to: self.view, animated: true)
            APIManager.shareInstance.postRequest(urlString: url, params: nil, result: { [weak self] (JSON, code, msg) in
                MBProgressHUD.hide(for: (self?.view)!, animated: true)
                if code == 0 {
                    
                    let title = JSON?["data"]["title"].stringValue ?? ""
                    let content = JSON?["data"]["content"].stringValue ?? ""
                    let htmlPath = Bundle.main.path(forResource: "notification", ofType: "html")
                    let originContent = try? String.init(contentsOfFile: htmlPath!, encoding: String.Encoding.utf8) as NSString
                    let replaceTag = "${title}"
                    var newContent = originContent?.replacingOccurrences(of: replaceTag, with: title)
                    newContent = newContent?.replacingOccurrences(of: "${contentHtml}", with: content)
                    self?.webView.loadHTMLString(newContent!, baseURL: nil)
                    
                }
                else {
                    BLHUDBarManager.showError(msg: msg)
                }
            })
        }
    }

}
