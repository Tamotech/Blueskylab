//
//  NotificationDetailController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/30.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class NotificationDetailController: BaseViewController {

    
    
    var data: NotificationItem?
    var webView = UIWebView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.title = NSLocalizedString("NotificationDetail", comment: "");
        let shareItem = UIBarButtonItem(image: UIImage(named:"icon-share"), style: .plain, target: self, action: #selector(handleShareAction(_:)))
        self.navigationItem.rightBarButtonItem = shareItem
        self.view.addSubview(webView)
        self.loadData()
    }
    
    
    func loadData() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        APIRequest.getNotificationDetail(id: data!.id) {[weak self] (result) in
            MBProgressHUD.hide(for: (self?.view)!, animated: true)
            self?.data = result as? NotificationItem
            self?.showCustomTitle(title: self?.data?.title ?? "")
            self?.webView.loadHTMLString(self?.data?.description ?? "", baseURL: nil)
        }
    }
    
    
    func handleShareAction(_ sender:Any) {
        
        let sheet = BottomWechatShareView.instanceFromXib() as! BottomWechatShareView
        sheet.show()
    }

}
