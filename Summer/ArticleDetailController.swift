//
//  ArticleDetailController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/28.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit


/// 文章详情页
class ArticleDetailController: BaseWebViewController {

    ///文章 id
    var articleId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadArticle()
    }

    func loadArticle() {
        if articleId.characters.count > 0 {
            let url = "/article/detail.htm?id=\(articleId)"
            MBProgressHUD.showAdded(to: self.view, animated: true)
            APIManager.shareInstance.postRequest(urlString: url, params: nil, result: { [weak self] (JSON, code, msg) in
                MBProgressHUD.hide(for: (self?.view)!, animated: true)
                if code == 0 {
                    let title = JSON?["data"]["title"].stringValue ?? ""
                    self?.showCustomTitle(title: title)
                    let content = JSON?["data"]["content"].stringValue ?? ""
                    self?.webView.loadHTMLString(content, baseURL: nil)
                }
                else {
                    SVProgressHUD.showError(withStatus: msg)
                }
            })
        }
    }

}
