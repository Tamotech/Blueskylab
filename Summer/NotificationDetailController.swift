//
//  NotificationDetailController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/30.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import WebKit

class NotificationDetailController: BaseWKWebViewController, BottomShareViewDelegate {

    
    
    var data: NotificationItem?
    var shareItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.showCustomTitle(title:NSLocalizedString("QuestionDetail", comment: ""))
        shareItem = UIBarButtonItem(image: UIImage(named:"icon-share"), style: .plain, target: self, action: #selector(handleShareAction(_:)))
//        self.navigationItem.rightBarButtonItem = shareItem
        
        self.loadData()
    }
    
    
    func loadData() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        APIRequest.getNotificationDetail(id: data!.id) {[weak self] (result) in
            MBProgressHUD.hide(for: (self?.view)!, animated: true)
            self?.data = result as? NotificationItem
            if (self?.data?.link.characters.count)! > 0 {
                self?.navigationItem.rightBarButtonItem = self?.shareItem
            }
            else {
                self?.navigationItem.rightBarButtonItem = nil
            }
            
            //let path = Bundle.main.bundlePath
            //let baseURL = URL.init(fileURLWithPath: path)
            let htmlPath = Bundle.main.path(forResource: "notification", ofType: "html")
            let content = try? String.init(contentsOfFile: htmlPath!, encoding: String.Encoding.utf8) as NSString
            let replaceTag = "${title}"
            var newContent = content?.replacingOccurrences(of: replaceTag, with: self?.data?.description ?? "")
            newContent = newContent?.replacingOccurrences(of: "${contentHtml}", with: self?.data!.content ?? "")
            self?.webView.loadHTMLString(newContent!, baseURL: nil)
        }
    }
    
    
    func handleShareAction(_ sender:Any) {
        
        let sheet = BottomWechatShareView.instanceFromXib() as! BottomWechatShareView
        sheet.delegate = self
        sheet.show()
    }

    func didTapWechat() {
        BSLShareManager.shareToWechat(link: data!.link, title: data!.title, msg: data!.description, thumb: data!.preimg, type: 0)
    }
    
    func didTapWechatCircle() {
        BSLShareManager.shareToWechat(link: data!.link, title: data!.title, msg: data!.description, thumb: data!.preimg, type: 1)

    }
}
