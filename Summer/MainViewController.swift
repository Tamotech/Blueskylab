//
//  MainViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/6/19.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import AMPopTip
import ReactiveSwift
import RxSwift
import Kingfisher


class MainViewController: BaseViewController, BluetoothViewDelegate,WindModeSelectDelegate, BottomShareViewDelegate {

    
    @IBOutlet weak var bgImgView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bottomModeView: UIView!
    
    @IBOutlet weak var searchBtn: UIButton!
    
    @IBOutlet weak var maskModeView: UIView!
    
    @IBOutlet weak var faceIcon: UIImageView!
    
    @IBOutlet weak var stageLabel: UILabel!
    
    @IBOutlet weak var modeManageView: UIView!
    
    @IBOutlet weak var modeControlBottom: NSLayoutConstraint!
    
    @IBOutlet weak var selectModeView: UIView!
    
    @IBOutlet weak var aqiNameLabel: UILabel!
    
    @IBOutlet weak var aqiLevelLabel: UILabel!
    
    @IBOutlet weak var pollutionLevelLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var windLevelLabel: UILabel!
    
    @IBOutlet weak var cityButton: UIButton!
    
    @IBOutlet weak var ovalCircleView: UIImageView!
//    @IBOutlet weak var cigaretteIcon: UIImageView!
//    
//    @IBOutlet weak var pollutionDescLabel: UILabel!
//    
//    @IBOutlet weak var cigaretteNumLabel: UILabel!
    
    /// 周数据曲线图
    @IBOutlet weak var weekDataView: WeekAQIDataView!
    
    @IBOutlet weak var defaultModeIconView: UIImageView!
    
    @IBOutlet weak var defaultModeLabel: UILabel!
    
    
    
    lazy var modeControlView: WindModeControllView = {
        let view = WindModeControllView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 246))
        return view
    } ()
    
    var timer:Timer?
    
    
    var maskView: UIView!
    var menuView: MainMenuView!
    var edgePanGes:UIScreenEdgePanGestureRecognizer!
    var panGes:UIPanGestureRecognizer!
    var todayAQIData: CurrentAQI?
    var recentAQIData: RecentWeekAQI?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        shouldClearNavBar = true
        self.setupView()
        self.setupGesture()
        self.setupTimer()
        self.loadAQIData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActiveNotification(notify:)), name: kAppDidBecomeActiveNotify, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userInfoUpdateNotification(noti:)), name: kUserInfoDidUpdateNotify, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userMaskConfigUpdateNoti(noti:)), name: kUserMaskConfigUpdateNoti, object: nil)
        
        if (SessionManager.sharedInstance.token.characters.count == 0) {
            let guideVc = StartGuideViewController(nibName: "StartGuideViewController", bundle: nil)
            let navVc = BaseNavigationController(rootViewController: guideVc)
            navVc.setTintColor(tint: .white)
            navVc.setTintColor(tint: UIColor.white)
            navigationController?.present(navVc, animated: false, completion: {
                
            })
        }
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navVC = self.navigationController as! BaseNavigationController
        navVC.setTintColor(tint: .white)
        
        
        if self.menuView.superview == nil && self.navigationController?.presentingViewController == nil {
             DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController!.view.superview?.insertSubview(self.menuView, at: 0)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let popTip = PopTip()
        popTip.padding = 0
        popTip.cornerRadius = 8
        let tipView = BLTipView(frame: CGRect(x: 0, y: 0, width: 212, height: 44), msg: NSLocalizedString("ChangeFilterTip", comment: ""), icon: UIImage(named: "iconQuestionM2"), textColor: UIColor.white, bgColor: UIColor(hexString: "eb474e")!)
        let frame = self.view.convert(stageLabel.frame, from: stageLabel.superview)
        popTip.show(customView: tipView, direction: .down, in: self.view, from: frame)
        DispatchQueue.main.asyncAfter(deadline: .now()+3) { 
            popTip.hide()
        }
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navVC = self.navigationController as! BaseNavigationController
        navVC.setTintColor(tint: gray72!)
    }
    
    func setupView() {
        let layer1 = CAGradientLayer()
        layer1.frame = bottomView.bounds
        layer1.colors = [UIColor(hexString: "28baf9")!, UIColor(hexString: "0196db")!]
        layer1.startPoint = CGPoint(x: 0.5, y: 0)
        layer1.endPoint = CGPoint(x: 0.5, y: 1)
        bottomView.layer.addSublayer(layer1)
        
        let layer2 = CAGradientLayer()
        layer2.frame = searchBtn.bounds
        layer2.cornerRadius = layer2.bounds.size.height/2
        layer2.masksToBounds = true
        layer2.colors = [UIColor(hexString: "28baf9")!.cgColor, UIColor(hexString: "0196db")!.cgColor]
        layer2.startPoint = CGPoint(x: 0.5, y: 0)
        layer2.endPoint = CGPoint(x: 0.5, y: 1)
        searchBtn.layer.addSublayer(layer2)

        scrollView.alpha = 1
        maskModeView.alpha = 0
        bottomView.alpha = 1
        bottomModeView.alpha = 0
        
        modeManageView.addSubview(modeControlView)
        modeControlView.delegate = self
        modeControlBottom.constant = -303+55
        selectModeView.alpha = 0
        scrollView.setContentOffset(CGPoint(x: CGFloat(1)*screenWidth, y: 0), animated: false)
        
        
    }
    
    func updateMaskConfigView() {
        let config = SessionManager.sharedInstance.userMaskConfig
        let levelData = config.maskFilterLevel()
        stageLabel.text = levelData.0
        if levelData.1 != nil {
            faceIcon.image = levelData.1!
        }
        if levelData.2 != nil {
            bgImgView.image = levelData.2!
        }
    }
    
    
    //MARK: - 通知
    func appDidBecomeActiveNotification(notify: Notification) {
        
        self.loadAQIData()
        SessionManager.sharedInstance.getUserInfo()
    }
    
    func userInfoUpdateNotification(noti: Notification) {
        menuView.updateView()
        modeControlView.modeManager.loadData()
    }
    
    func userMaskConfigUpdateNoti(noti: Notification) {
        self.updateMaskConfigView()
    }
    
    //MARK: - AQI
    
    func loadAQIData() {
        APIRequest.AQIQueryAPI { [weak self](data) in
            self?.todayAQIData = data as? CurrentAQI
            self?.updateTodayAQIView(data: (self?.todayAQIData)!)
            self?.bgImgView.image = self?.todayAQIData?.aqiBGImg()
            guard let cityID = self?.todayAQIData?.cityID else {
                return
            }
            APIRequest.recentWeekAQIAPI(cityID: cityID, result: { [weak self](recentData) in
                self?.recentAQIData = recentData as? RecentWeekAQI
                self?.updateRecentWeekDataView(data: (self?.recentAQIData)!)
                
            })
        }
        
    }
    
    /// 更新当天的 AQI
    ///
    /// - Parameter data: data
    func updateTodayAQIView(data: CurrentAQI) {
        cityButton.setTitle("  " + data.city, for: .normal)
        aqiLevelLabel.text = String(data.aqi)
        temperatureLabel.text = String(format: "%.0lf°C", data.temperature)
        windLevelLabel.text = String(format: "%.0f级风",  data.windSpeed)
        //cigaretteNumLabel.text = String(format: NSLocalizedString("CirgaretteNum", comment: ""), data.smokeNum)
        //let smokeIconName = String(format: "icon%dc", data.smokeNum)
        //cigaretteIcon.image = UIImage(named: smokeIconName)
    }
    
    
    /// 更新最近 AQI 数据曲线图
    ///
    /// - Parameter data: 数据源
    func updateRecentWeekDataView(data: RecentWeekAQI) {
        weekDataView.updateView(data: data)
    }
    
    func setupTimer() {
        timer = Timer(timeInterval: 3, target: self, selector: #selector(handleTimerEvent(t:)), userInfo: nil, repeats: true)
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .commonModes)
        
    }
    
    func handleTimerEvent(t:Timer) {
        gotoNextPage(nil)
    }
    
    func gotoNextPage(_:Any?) {
        var currentIndex = Int(scrollView.contentOffset.x/screenWidth)
        currentIndex = currentIndex+1
        if currentIndex >= 2 {
            currentIndex = 0
        }
        
        scrollView.setContentOffset(CGPoint(x: CGFloat(currentIndex)*screenWidth, y: 0), animated: true)
    }
    
    
    /// 添加手势 侧滑菜单
    func setupGesture() {
        edgePanGes = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleLeftEdgePanGesture(ges:)))
        edgePanGes.edges = .left
        self.view.addGestureRecognizer(edgePanGes)
        
        panGes = UIPanGestureRecognizer(target: self, action: #selector(handleLeftEdgePanGesture(ges:)))
        self.view.addGestureRecognizer(panGes)
        
        menuView = MainMenuView.instanceFromXib() as! MainMenuView
        
        menuView.tapMunueCallback = {[weak self] (type:ItemType) in
            
            
            self?.dismissMenu()
            switch type {
            case .ItemUser:
                
                let editUserVc = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
                self?.navigationController?.pushViewController(editUserVc, animated: true)
                break
            case .ItemSetting:
                let settingVC = SettingViewController(nibName: "SettingViewController", bundle: nil)
                self?.navigationController?.pushViewController(settingVC, animated: true)
                break
            case .ItemGuide:
                let vc = UserHandbookController(nibName: "UserHandbookController", bundle: nil)
                self?.navigationController?.pushViewController(vc, animated: true)
                break
            case .ItemMyEquipment:
                let vc = EquipmentViewController(nibName: "EquipmentViewController", bundle: nil)
                self?.navigationController?.pushViewController(vc, animated: true)
                break
            case .ItemBuyMask:
                guard let url = self?.menuView.maskBuyUrl else {
                    break
                }
                let vc = BaseWebViewController()
                vc.urlString = url
                self?.navigationController?.pushViewController(vc, animated: true)
                break
            case .ItemBuyFilter:
                guard let url = self?.menuView.filterBuyUrl else {
                    break
                }
                let vc = BaseWebViewController()
                vc.urlString = url
                self?.navigationController?.pushViewController(vc, animated: true)
                break
            case .ItemShare:
                let sheet = BottomWechatShareView.instanceFromXib() as! BottomWechatShareView
                sheet.delegate = self
                sheet.show()
                break
            default:
                break
            }
        }
        
        
        maskView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        maskView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.view.addSubview(maskView)
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(handleTapMaskView(_:)))
        maskView.isUserInteractionEnabled = true
        maskView.alpha = 0
        maskView.addGestureRecognizer(tapGes)
        
        scrollView.isUserInteractionEnabled = true
        let tapscroll = UITapGestureRecognizer(target: self, action: #selector(gotoNextPage(_:)))
        scrollView.addGestureRecognizer(tapscroll)
        
    }
    
    ///
    
    
    //Mark: 侧滑手势
    func handleLeftEdgePanGesture(ges:UIGestureRecognizer) {
        let location = ges.location(in: keyWindow)
        
        if (ges.state == .began || ges.state == .changed) {
            self.navigationController!.view.left = location.x
        }
        else if (ges.state == .ended || ges.state == .cancelled) {
            
            if (location.x > self.view.width/2) {
               self.showMenu()
            }
            else {
                self.dismissMenu()
            }
        }
    }
    
    
    //MARK: - 菜单出现消失
    
    func showMenu() {
        
        let borderX = self.view.width*3/4.0
        UIView.animate(withDuration: 0.2, animations: {
            self.navigationController!.view.left = borderX
            self.maskView.alpha = 1
        }, completion: { (true) in
            self.edgePanGes.isEnabled = false
            self.panGes.isEnabled = true
        })
    }
    
    func dismissMenu() {
        UIView.animate(withDuration: 0.2, animations: {
            self.navigationController!.view.left = 0
            self.maskView.alpha = 0
        }, completion: { (true) in
            self.edgePanGes.isEnabled = true
            self.panGes.isEnabled = false
        })
    }
    
    //MARK: - actions
    func handleTapMaskView(_:UITapGestureRecognizer) {
        self.dismissMenu()
    }
    
    @IBAction func handleTapMenu(_:Any) {
        self.showMenu()
    }
    
    @IBAction func handleTapNotificationItem(_:Any) {
        let vc = NotificationCenterController()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func handleTapSearchBluetoothBtn(_ sender: Any) {
        let vc = OpenBluetoothController(nibName: "OpenBluetoothController", bundle: nil)
        vc.delegate = self
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func handleTapQuestionBtn(_ sender: Any) {
        let vc = UserHandbookController(nibName: "UserHandbookController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    /// 点击底部模式 唤起模式控制器
    ///
    /// - Parameter sender:  tapGesture
    @IBAction func handleTapBottomModeControlView(_ sender: UITapGestureRecognizer) {
        
        //如果未登录
        if SessionManager.sharedInstance.token == "" {
            showLoginVC()
            return
        }
        self.showModeControl(show: true)
        modeControlView.refreshItemViews()
    }
    
    @IBAction func handleTapUnfoldModeView(_ sender: UITapGestureRecognizer) {
        self.showModeControl(show: false)
    }
    
    @IBAction func handleTapUpModelBtn(_ sender: UIButton) {
        
    }
    
    
    @IBAction func handleTapHistoryBtn(_ sender: Any) {
        let vc = HistoryDataViewController(nibName: "HistoryDataViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func handleTapModeSettingBtn(_ sender: UIButton) {
        
        self.showModeControl(show: false)
        let vc = ModeSettingController()
        vc.modeManager = modeControlView.modeManager
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 点击收起选择模式
    @IBAction func handleTapFoldSelectModeBtn(_ sender: UIButton) {
        
        
    }
    
    //MARK: - WindModeSelectDelegate
    
    func clickAddMode() {
        self.showModeControl(show: false)
        let vc = AddModeViewController(nibName: "AddModeViewController", bundle: nil)
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func defaultModeDidChange(mode: UserWindSpeedConfig) {

        if mode.icon4.characters.count > 0 {
            let rc = ImageResource(downloadURL: URL(string: mode.icon4)!)
            defaultModeIconView.kf.setImage(with: rc)
        }
        else {
            defaultModeIconView.image = mode.customIcon(color: UIColor.white)
        }
        defaultModeLabel.text = mode.name
    }
    
    //MARK: - BluetoothDelegate
    
    func didConnectBlueTooth() {
        
        self.showCircleAnimation()
    }

    
    //MARK: - private
    
    func showModeControl(show: Bool) {
        if show {
            
            if SessionManager.sharedInstance.windModeManager.windUserConfigList.count == 0 {
                SessionManager.sharedInstance.windModeManager.loadData()
            }
            modeControlBottom.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomModeView.alpha = 0
                self.view.layoutIfNeeded()
            }) { (success) in
                
            }
        }
        else {
            modeControlBottom.constant = -self.selectModeView.height+55
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomModeView.alpha = 1
                self.view.layoutIfNeeded()
            }) {(success) in
                
            }
        }
    }
    
    
    ///App 分享
    
    func didTapWechat() {
        guard let downloadUrl = menuView.appDownloadUrl else {
            return
        }
        BSLShareManager.shareToWechat(link: downloadUrl, title: "蓝天实验室", msg: "", thumb: "", type: 0)
    }
    
    func didTapWechatCircle() {
        guard let downloadUrl = menuView.appDownloadUrl else {
            return
        }
        BSLShareManager.shareToWechat(link: downloadUrl, title: "蓝天实验室", msg: "", thumb: "", type: 1)
        
    }
    
    func showCircleAnimation() {
        timer?.invalidate()
        scrollView.setContentOffset(CGPoint(x: CGFloat(1)*screenWidth, y: 0), animated: false)
        ovalCircleView.alpha = 0
        let frame = ovalCircleView.superview?.convert(ovalCircleView.frame, to:                                                                             self.view)
        let demoView = AwesomeCircleView(frame: frame!)
        self.view.addSubview(demoView)
        demoView.startAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            
            UIView.animate(withDuration: 1.0, animations: {
                demoView.alpha = 0
                self.scrollView.alpha = 0
                self.maskModeView.alpha = 1
                self.bottomView.alpha = 0
                self.modeControlView.alpha = 1
                self.selectModeView.alpha = 1
                self.bottomModeView.alpha = 1
                
                
            }, completion: { (success) in
                demoView.removeFromSuperview()

            })
        }
    }
}
