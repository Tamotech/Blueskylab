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
import WatchKit

class StartGuideViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var startGuideImg1: UIImageView!
    
    @IBOutlet weak var wechatLoginBtn: UIButton!
    var timer:Timer?
    
    lazy var tipCenter: CGPoint = {
        if screenWidth < 330 {
            return CGPoint(x: screenWidth-85, y: 25)
        }
        else if screenWidth < 400 {
            return CGPoint(x: screenWidth-64, y: 30)
        }
        else {
            return CGPoint(x: screenWidth-65, y: 50)
        }
    } ()
    
    var startGuide1TipView = UIImageView(image: UIImage(named: "start-mask"))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupView()
        if !UIApplication.shared.canOpenURL(URL(string:"wechat://")!) {
            wechatLoginBtn.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveLoginWechatSuccessNoti(noti:)), name: kLoginWechatSuccessNotifi, object: nil)
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let _:() = {
            //一次执行
            UIView.animate(withDuration: 2.0, delay: 0.2, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.2, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.startGuide1TipView.size = CGSize(width: 80, height: 80)
                self.startGuide1TipView.center = self.tipCenter
    
            }, completion: { (success) in
                
            })
            
        }()
        
        setupTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }

    func setupView() {
        let closeBarItem = UIBarButtonItem(image: UIImage(named: "close-white"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(handleTapCloseBtn(_:)))
        navigationItem.leftBarButtonItem = closeBarItem
        let jumpoverItem = UIBarButtonItem(title: NSLocalizedString("JumpOver", comment: ""), style: .plain, target: self, action: #selector(handleTapJumpoverBtn(_:)))
        navigationItem.rightBarButtonItem = jumpoverItem
        
        scrollView.delegate = self
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        
        startGuide1TipView.size = CGSize(width: 40, height: 40)
        startGuide1TipView.center = tipCenter
        startGuideImg1.superview?.addSubview(startGuide1TipView)
        startGuideImg1.superview?.clipsToBounds = false
        
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
    
    
    ///MARK: - timer
    func setupTimer() {
        
        if timer == nil {
            timer = Timer(timeInterval: 3, target: self, selector: #selector(handleTimerEvent(t:)), userInfo: nil, repeats: true)
            timer?.fire()
            RunLoop.main.add(timer!, forMode: .commonModes)
        }
        
    }
    
    func handleTimerEvent(t:Timer) {
        gotoNextPage(nil)
    }
    
    func gotoNextPage(_:Any?) {
        var currentIndex = Int(scrollView.contentOffset.x/screenWidth)
        currentIndex = currentIndex+1
        if currentIndex >= 3 {
            currentIndex = 0
        }
        pageControl.currentPage = currentIndex
        scrollView.setContentOffset(CGPoint(x: CGFloat(currentIndex)*screenWidth, y: 0), animated: true)
    }
    
    
}
