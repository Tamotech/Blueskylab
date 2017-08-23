//
//  StartGuideViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/31.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class StartGuideViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveLoginWechatSuccessNoti(noti:)), name: kLoginWechatSuccessNotifi, object: nil)
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupView() {
        let closeBarItem = UIBarButtonItem(image: UIImage(named: "close-white"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(handleTapCloseBtn(_:)))
        navigationItem.leftBarButtonItem = closeBarItem
        let jumpoverItem = UIBarButtonItem(title: NSLocalizedString("JumpOver", comment: ""), style: .plain, target: self, action: #selector(handleTapJumpoverBtn(_:)))
        navigationItem.rightBarButtonItem = jumpoverItem
        
        scrollView.delegate = self
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
    }
    
    
    //MARK: - scrollViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        pageControl.currentPage = Int(x/screenWidth)
    }
    
    
    //MARK: - notification
    
    func receiveLoginWechatSuccessNoti(noti: Notification) {
        let info = JSON(noti.object ?? [])
        let code = info["code"]
        let state = info["state"]
        
        if state == "wechat_sdk_login_demo" {
            let url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(wxAppId)&secret=\(wxSecretKey)&code=\(code)&grant_type=authorization_code"
            Alamofire.request(url).responseJSON(completionHandler: { (response) in
                if let value = response.result.value {
                    let jsonDic = JSON(value)
//                    print(jsonDic)
                    let accessToken = jsonDic["access_token"].string
//                    let expires = jsonDic["expires_in"].int
                    guard let openid = jsonDic["openid"].string else {
                        return
                    }
                    SessionManager.sharedInstance.loginInfo.wxid = openid
                    SessionManager.sharedInstance.loginInfo.wxAccessToken = accessToken!
                    
                    ///获取个人信息
                    APIRequest.getWXUserInfo(accessToken: accessToken!, openId: openid, result: { (userInfo) in
                        SessionManager.sharedInstance.wxUserInfo = userInfo as? WXUserInfo
                    })
                    
                    //尝试用 wxid 登录
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                    SessionManager.sharedInstance.login(results: { [weak self](json, code, msg) in
                        if code == 0 {
                            //成功
                            self?.navigationController?.dismiss(animated: true, completion: {
                                
                            })
                        }
                        else {
                            ///用户不存在
                            MBProgressHUD.hide(for: (self?.view)!, animated: true)
                            //去绑定手机号登录
                            let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
                            self?.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                    })
                    
                }
            })
        }
        
    }
    
    //MARK: - actions
    @IBAction func handleTapCloseBtn(_ sender: Any) {
        
        navigationController?.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func handleTapJumpoverBtn(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleTapWechatBtn(_ sender: Any) {
        
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "wechat_sdk_login_demo"
        WXApi.send(req)
    }
    
    
    @IBAction func handleTapOtherLoginBtn(_ sender: Any) {
        let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func handleLoginNowBtn(_ sender: Any) {
        let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
