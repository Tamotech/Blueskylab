//
//  NotificationDetailController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/30.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class NotificationDetailController: BaseViewController, BottomShareViewDelegate {

    
    
    var data: NotificationItem?
    var webView = UIWebView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
    var shareItem: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.title = NSLocalizedString("NotificationDetail", comment: "");
        shareItem = UIBarButtonItem(image: UIImage(named:"icon-share"), style: .plain, target: self, action: #selector(handleShareAction(_:)))
//        self.navigationItem.rightBarButtonItem = shareItem
        self.view.addSubview(webView)
        self.loadData()
    }
    
    
    func loadData() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        APIRequest.getNotificationDetail(id: data!.id) {[weak self] (result) in
            MBProgressHUD.hide(for: (self?.view)!, animated: true)
            self?.data = result as? NotificationItem
            self?.showCustomTitle(title: self?.data?.title ?? "")
            if (self?.data?.link.characters.count)! > 0 {
                self?.navigationItem.rightBarButtonItem = self?.shareItem
            }
            else {
                self?.navigationItem.rightBarButtonItem = nil
            }
            self?.webView.loadHTMLString(self?.data?.description ?? "", baseURL: nil)
        }
    }
    
    
    func handleShareAction(_ sender:Any) {
        
        let sheet = BottomWechatShareView.instanceFromXib() as! BottomWechatShareView
        sheet.delegate = self
        sheet.show()
    }

    func didTapWechat() {
        BSLShareManager.shareToWechat(link: data!.link, title: data!.title, msg: data!.description, thumb: data!.img, type: 0)
    }
    
    func didTapWechatCircle() {
        BSLShareManager.shareToWechat(link: data!.link, title: data!.title, msg: data!.description, thumb: data!.img, type: 1)

    }
}
