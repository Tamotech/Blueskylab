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

    //背景污染等级图
    @IBOutlet weak var bgImgView: UIImageView!
    
    //@IBOutlet weak var scrollView: UIScrollView!
    
    ///开启蓝牙连接口罩
    @IBOutlet weak var bottomView: UIView!
    
    ///设置-我的设备
    @IBOutlet weak var bottomModeView: UIView!
    
    @IBOutlet weak var searchBtn: UIButton!
    
    //口罩连接后的页面
    @IBOutlet weak var maskModeView: UIView!
    //口罩链接之前的页面
    @IBOutlet weak var connectBluetoothView: UIView!
    //笑脸
    @IBOutlet weak var faceIcon: UIImageView!
    //口罩过滤效果等级
    @IBOutlet weak var stageLabel: UILabel!
    
    ///模式管理面板
    @IBOutlet weak var modeManageView: UIView!
    
    @IBOutlet weak var modeControlBottom: NSLayoutConstraint!
    
    ///模式控制 风速调节
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
    ///电量值
    @IBOutlet weak var batteryView: UIView!
    ///未连接蓝牙标志
    @IBOutlet weak var bluetoothUnConnectBtn: UIButton!
    
    @IBOutlet weak var batteryImageView: UIImageView!
    
    @IBOutlet weak var batteryLevelLb: UILabel!
    
    ///aqi 空气数据
    @IBOutlet weak var aqiView: UIView!
    
    
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
    ///是否弹窗电量低
    var hasShowLowPowerTip = false
    ///是否弹窗换口罩
    var hasShowChangeFilter = false
    ///转轮动画是否正在展示
    var showingCircleAnimation = false
    
    
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(didConnectBluetoothNoti(noti:)), name: kMaskDidConnectBluetoothNoti, object: nil)
        
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
        
        self.observeBluetoothState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.changeToConnectMode(connect: BLSBluetoothManager.shareInstance.state == BluetoothState.Connected)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let navVC = self.navigationController as! BaseNavigationController
        navVC.setTintColor(tint: gray72!)
        showModeControl(show: false)
    }
    
    func setupView() {
        let layer1 = CAGradientLayer()
        layer1.frame = CGRect(x: 0, y: 0, width: screenWidth, height: bottomView.height)
        layer1.colors = [UIColor(hexString: "28baf9")!, UIColor(hexString: "0196db")!]
        layer1.startPoint = CGPoint(x: 0.5, y: 0)
        layer1.endPoint = CGPoint(x: 0.5, y: 1)
        bottomView.layer.addSublayer(layer1)
        
        let layer2 = CAGradientLayer()
        layer2.frame = CGRect(x: 0, y: 0, width: screenWidth-68*2, height: searchBtn.height)
        layer2.cornerRadius = layer2.bounds.size.height/2
        layer2.masksToBounds = true
        layer2.colors = [UIColor(hexString: "28baf9")!.cgColor, UIColor(hexString: "0196db")!.cgColor]
        layer2.startPoint = CGPoint(x: 0.5, y: 0)
        layer2.endPoint = CGPoint(x: 0.5, y: 1)
        searchBtn.layer.addSublayer(layer2)

        connectBluetoothView.alpha = 1
        maskModeView.alpha = 0
        aqiView.alpha = 0
        bottomView.alpha = 1
        bottomModeView.alpha = 0
        
        modeManageView.addSubview(modeControlView)
        modeControlView.delegate = self
        modeControlBottom.constant = -303+55
        selectModeView.alpha = 0
        //scrollView.setContentOffset(CGPoint(x: CGFloat(1)*screenWidth, y: 0), animated: false)
        bluetoothUnConnectBtn.isHidden = false
        batteryView.isHidden = true
        
        
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
    
    
    func observeBluetoothState() {
        let manager = BLSBluetoothManager.shareInstance
        manager.stateUpdate = {(state: BluetoothState) in
            switch state {
            case .Unauthorized:
                self.changeToConnectMode(connect: false)
                break
            case .PowerOff:
                self.changeToConnectMode(connect: false)
                manager.stop()
                break
            case .PowerOn:
                break
            case .Connected:
                self.changeToConnectMode(connect: true)
                break
                
            case .ConnectFailed:
                self.changeToConnectMode(connect: false)
                break
            case .DisConnected:
                self.changeToConnectMode(connect: false)
                HealthDataManager.sharedInstance.saveMaskUseData()
                break
                
            }
        }
        
        manager.powerChange = {(power) in
            var batteryImg = #imageLiteral(resourceName: "battery1")
            self.batteryLevelLb.textColor = UIColor.white
            if power < 20 {
                batteryImg = #imageLiteral(resourceName: "battery3")
                self.batteryLevelLb.textColor = UIColor.red
                
            }
            else if power < 80 {
                batteryImg = #imageLiteral(resourceName: "battery2")
                self.batteryLevelLb.textColor = UIColor.white
            }
            self.batteryImageView.image = batteryImg
            self.batteryLevelLb.text = "\(power)%"
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
    
    func didConnectBluetoothNoti(noti: Notification) {
        self.setCurrentModeWindForMask()
    }
    
    //MARK: - AQI
    
    func loadAQIData() {
        APIRequest.AQIQueryAPI { [weak self](data) in
            self?.todayAQIData = data as? CurrentAQI
            SessionManager.sharedInstance.currentAQI  = data as? CurrentAQI
            self?.updateTodayAQIView(data: (self?.todayAQIData)!)
            self?.bgImgView.image = self?.todayAQIData?.aqiBGImg()
            guard let cityID = self?.todayAQIData?.cityID else {
                return
            }
            APIRequest.recentWeekAQIAPI(cityID: cityID, result: { [weak self](recentData) in
                self?.recentAQIData = recentData as? RecentWeekAQI
                self?.updateRecentWeekDataView(data: (self?.recentAQIData)!)
                
            })
            SessionManager.sharedInstance.userMaskConfig.updateCityID(cityID: cityID)
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
        pollutionLevelLabel.text = data.aqiLevelName
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
//        var currentIndex = Int(scrollView.contentOffset.x/screenWidth)
//        currentIndex = currentIndex+1
//        if currentIndex >= 2 {
//            currentIndex = 0
//        }
        
       // scrollView.setContentOffset(CGPoint(x: CGFloat(currentIndex)*screenWidth, y: 0), animated: false)
        
        if BLSBluetoothManager.shareInstance.state == .Connected {
            UIView.animate(withDuration: 0.3, animations: {
                self.maskModeView.alpha = 1-self.maskModeView.alpha
                self.aqiView.alpha = 1-self.aqiView.alpha
            })
        }
        else {
            UIView.animate(withDuration: 0.3, animations: {
                self.connectBluetoothView.alpha = 1-self.connectBluetoothView.alpha
                self.aqiView.alpha = 1-self.aqiView.alpha
            })
        }
        
//        if maskModeView.alpha == 1 && !hasShowLowPowerTip && !showingCircleAnimation {
//            //let config = SessionManager.sharedInstance.userMaskConfig
//            let power = batteryLevelLb.text?.getIntFromString() ?? 100
//            if power <= 20 {
//                self.lowerPowerAlert()
//            }
//
//            self.showChangeFilterAlert()
//        }
        
        
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
                //如果未登录
                if SessionManager.sharedInstance.token == "" {
                    showLoginVC()
                    return
                }
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
        
//        scrollView.isUserInteractionEnabled = true
//        let tapscroll = UITapGestureRecognizer(target: self, action: #selector(gotoNextPage(_:)))
//        scrollView.addGestureRecognizer(tapscroll)
        
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
        if SessionManager.sharedInstance.token == "" {
            showLoginVC()
            return
        }
        let vc = OpenBluetoothController(nibName: "OpenBluetoothController", bundle: nil)
        vc.delegate = self
        let navVC = BaseNavigationController(rootViewController: vc)
        navVC.setNavigationBarHidden(true, animated: false)
        navigationController?.present(navVC, animated: true, completion: nil)
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
        
//        self.showModeControl(show: false)
//        let vc = ModeSettingController()
//        vc.modeManager = modeControlView.modeManager
//        navigationController?.pushViewController(vc, animated: true)
        
        //10-06 update
        //如果未登录
        if SessionManager.sharedInstance.token == "" {
            showLoginVC()
            return
        }
        self.showModeControl(show: false)
        let vc = EquipmentViewController(nibName: "EquipmentViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 点击收起选择模式
    @IBAction func handleTapFoldSelectModeBtn(_ sender: UIButton) {
        
        
    }
    
    ///点击中心区域 切换视图
    @IBAction func handleTapCenterView(_ sender: UITapGestureRecognizer) {
        
        gotoNextPage(nil)
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
        setCurrentModeWindForMask()
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
    
    //调节到当前设置的风速
    func setCurrentModeWindForMask() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
            self.showCircleAnimation()
            
            //调节至默认的风速
            if SessionManager.sharedInstance.windModeManager.currentMode != nil {
                self.modeControlView.selectItem(mode: SessionManager.sharedInstance.windModeManager.currentMode!)
            }
            self.bluetoothUnConnectBtn.isHidden = true
            self.batteryView.isHidden = false
            
        }
    }
    
    ///App 分享
    
    func didTapWechat() {
        guard let downloadUrl = menuView.appDownloadUrl else {
            return
        }
        BSLShareManager.shareToWechat(link: downloadUrl, title: "蓝天大气｜便携式智能新风口罩", msg: "为你定制的健康呼吸管家，用智能科技开启人类健康新生态", thumb: "", type: 0)
    }
    
    func didTapWechatCircle() {
        guard let downloadUrl = menuView.appDownloadUrl else {
            return
        }
        BSLShareManager.shareToWechat(link: downloadUrl, title: "蓝天大气｜便携式智能新风口罩", msg: "", thumb: "", type: 1)
        
    }
    
    func showCircleAnimation() {
        showingCircleAnimation = true
        timer?.invalidate()
        //scrollView.setContentOffset(CGPoint(x: CGFloat(1)*screenWidth, y: 0), animated: false)
        aqiView.alpha = 1
        maskModeView.alpha = 0
        connectBluetoothView.alpha = 0
        ovalCircleView.alpha = 0
        let frame = ovalCircleView.superview?.convert(ovalCircleView.frame, to:                                                                             self.view)
        let demoView = AwesomeCircleView(frame: frame!)
        self.view.addSubview(demoView)
        demoView.startAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            
            UIView.animate(withDuration: 1.0, animations: {
                demoView.alpha = 0
                
                
            }, completion: { (success) in
                demoView.removeFromSuperview()
                self.showingCircleAnimation = false
                self.changeToConnectMode(connect: true)
                self.aqiView.alpha = 0
                self.maskModeView.alpha = 1
                
                if !self.hasShowLowPowerTip {
                    let power = self.batteryLevelLb.text?.getIntFromString() ?? 100
                    if power <= 20 {
                        self.lowerPowerAlert()
                    }
                    self.showChangeFilterAlert()
                }
                self.showModeControl(show: true)
                
            })
        }
    }
    
    func changeToConnectMode(connect: Bool) {
        if connect {
            self.connectBluetoothView.alpha = 0
            self.aqiView.alpha = 1
            self.maskModeView.alpha = 0
            self.bottomView.alpha = 0
            self.modeControlView.alpha = 1
            self.selectModeView.alpha = 1
            self.bottomModeView.alpha = 1
            self.ovalCircleView.alpha = 1
            bluetoothUnConnectBtn.isHidden = true
            batteryView.isHidden = false
        }
        else {
            self.connectBluetoothView.alpha = 1
            self.aqiView.alpha = 0
            self.maskModeView.alpha = 0
            self.bottomView.alpha = 1
            self.modeControlView.alpha = 0
            self.selectModeView.alpha = 0
            self.bottomModeView.alpha = 0
            self.ovalCircleView.alpha = 1
            bluetoothUnConnectBtn.isHidden = false
            batteryView.isHidden = true
            
        }
        
        //模式展开状态
        if modeControlBottom.constant > -10 {
            bottomModeView.alpha = 0
        }
        else {
            bottomModeView.alpha = 1
        }
    }
    
    func lowerPowerAlert() {
        
        if hasShowLowPowerTip {
            return
        }
        let maskConfig = SessionManager.sharedInstance.userMaskConfig
        if !maskConfig.lowpowerflag{
            return
        }
        
        hasShowLowPowerTip = true
        let popTip = PopTip()
        popTip.padding = 0
        popTip.cornerRadius = 8
        let tipView = BLTipView(frame: CGRect.init(x: 0, y: 0, width: 212, height: 44), msg: NSLocalizedString("LowPowerTip", comment: ""), icon: nil, textColor: UIColor.white, bgColor: UIColor(hexString: "eb474e")!)
        let frame = self.view.convert(batteryView.frame, from: batteryView.superview)
        popTip.show(customView: tipView, direction: .down, in: self.view, from: frame)
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            popTip.hide()
        }
        
        
    }
    
    
    func showChangeFilterAlert() {
        if hasShowChangeFilter {
            return
        }
        let maskConfig = SessionManager.sharedInstance.userMaskConfig
        if !maskConfig.filterchangeflag || maskConfig.filtereffect != "l3" {
            return
        }
        hasShowChangeFilter = true
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
}
