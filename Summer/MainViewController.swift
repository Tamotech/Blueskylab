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

    let kShowGuideFlag = "show_guide_flag"
    let kShowModeControlGuideFlag = "show_mode_control_guide_flag"
    
    //背景污染等级图
    @IBOutlet weak var bgImgView: UIImageView!
    
    //@IBOutlet weak var scrollView: UIScrollView!
    
    ///开启蓝牙连接口罩
    @IBOutlet weak var bottomView: UIView!
    
    ///设备连接状态
    @IBOutlet weak var maskConnectStateLabel: UILabel!
    //当前过滤效果
    @IBOutlet weak var filterEffectTitleLabel: UILabel!
    
    @IBOutlet weak var cityAirTitleLabel: UILabel!
    
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
    
    @IBOutlet weak var modeCircleView: UIImageView!
    
    var powerPopTip: PopTip = PopTip()
    var changeFilterPopTip: PopTip = PopTip()
    
    lazy var dotView: UIView = {
       let v = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
        v.backgroundColor = UIColor.red
        v.layer.cornerRadius = 4
        return v
    }()
    @IBOutlet weak var notificationItem: UIBarButtonItem!
    
    
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
        self.loadUserConfig()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActiveNotification(notify:)), name: kAppDidBecomeActiveNotify, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userInfoUpdateNotification(noti:)), name: kUserInfoDidUpdateNotify, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userMaskConfigUpdateNoti(noti:)), name: kUserMaskConfigUpdateNoti, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didConnectBluetoothNoti(noti:)), name: kMaskDidConnectBluetoothNoti, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bluetoothStateChangeNotification(noti:)), name: kMaskStateChangeNotifi, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: NSNotification.Name(rawValue: "LanguageChanged"), object: nil)
        
        if (SessionManager.sharedInstance.token.count == 0) {
            let guideVc = StartGuideViewController(nibName: "StartGuideViewController", bundle: nil)
            let navVc = BaseNavigationController(rootViewController: guideVc)
            navVc.setTintColor(tint: .white)
            navVc.setTintColor(tint: UIColor.white)
            navigationController?.present(navVc, animated: false, completion: {
                
            })
        }
        else {
            if UserDefaults.standard.bool(forKey: kFirstLoadAppKey)
            && !UserDefaults.standard.bool(forKey: kBluetoothConnectFlag) {
                handleTapSearchBluetoothBtn(searchBtn)
                UserDefaults.standard.set(false, forKey: kBluetoothConnectFlag)
                UserDefaults.standard.synchronize()
            }
        }
        
        UserDefaults.standard.set(true, forKey: kFirstLoadAppKey)
        UserDefaults.standard.synchronize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navVC = self.navigationController as! BaseNavigationController
        navVC.setTintColor(tint: .white)
        
        //TEST: 测试
        SessionManager.sharedInstance.getUserMaskConfig()
        loadNotificationData()
        if self.menuView.superview == nil && self.navigationController?.presentingViewController == nil {
             DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController!.view.superview?.insertSubview(self.menuView, at: 0)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.changeToConnectMode(connect: BLSBluetoothManager.shareInstance.state == BluetoothState.Connected)
        
        showConnectMaskGuide()
        lowerPowerAlert()
        ///第一次showalert 跟 连接蓝牙动画有冲突
        if maskModeView.tag >= 2 {
            showChangeFilterAlert()
        }
        self.maskModeView.tag = self.maskModeView.tag + 1
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let navVC = self.navigationController as! BaseNavigationController
        navVC.setTintColor(tint: gray72!)
        showModeControl(show: false)
    }
    
    func setupView() {
        
        self.title = NSLocalizedString("BSLTitle", comment: "")
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

        let notificationBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        notificationBtn.addTarget(self, action: #selector(handleTapNotificationBtn(_:)), for: .touchUpInside)
        notificationBtn.contentMode = .scaleAspectFit
        notificationBtn.setImage(#imageLiteral(resourceName: "Jingle"), for: .normal)
        dotView.center = CGPoint(x: notificationBtn.right-4, y: 4)
        dotView.isHidden = true
        notificationBtn.addSubview(dotView)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: notificationBtn)
    }
    
    func updateMaskConfigView() {
        let config = SessionManager.sharedInstance.userMaskConfig
        let levelData = config.maskFilterLevel()
        stageLabel.text = levelData.0
        if levelData.1 != nil {
            faceIcon.image = levelData.1!
        }
    }
    
    
    //MARK: - 通知
    func bluetoothStateChangeNotification(noti: Notification) {
        guard let userInfo = noti.userInfo as? [String: Any] else {
            return
        }
        if userInfo["key"] as! String == "state" {
            let state = userInfo["value"] as! BluetoothState
            let manager = BLSBluetoothManager.shareInstance
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
                hasShowLowPowerTip = false
                hasShowChangeFilter = false
                HealthDataManager.sharedInstance.saveMaskUseData()
                break
                
            }
        }
        else if userInfo["key"] as! String == "power" {
            let power = userInfo["value"] as! Int
            var batteryImg = #imageLiteral(resourceName: "battery1")
            self.batteryLevelLb.textColor = UIColor.white
            if power <= 20 {
                batteryImg = #imageLiteral(resourceName: "battery3")
                self.batteryLevelLb.textColor = UIColor.red
//                lowerPowerAlert()
            }
            else if power < 80 {
                batteryImg = #imageLiteral(resourceName: "battery2")
                self.batteryLevelLb.textColor = UIColor.white
            }
            self.batteryImageView.image = batteryImg
            self.batteryLevelLb.text = "\(power)%"
        }
        
    }
    
    
    func appDidBecomeActiveNotification(notify: Notification) {
        
        self.loadAQIData()
        SessionManager.sharedInstance.getUserInfo()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
            //避开加载
            if self.maskModeView.tag >= 2 {
                self.showChangeFilterAlert()
            }
        }
        lowerPowerAlert()
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
    
    func didDisconnectBluetoothNoti(noti: Notification) {
        
    }
    
    func languageChanged() {
        self.title = NSLocalizedString("BSLTitle", comment: "")
            filterEffectTitleLabel.text = NSLocalizedString("CurrentFilterEffect", comment: "")
        searchBtn.setTitle(NSLocalizedString("StartConnectMask", comment: ""), for: .normal)
        cityAirTitleLabel.text = NSLocalizedString("CityAirQuality", comment: "")
        maskConnectStateLabel.text = NSLocalizedString("DeviceNotConnected", comment: "")
        loadAQIData()
        menuView.changeLanguage()
    }
    
    
    //MARK: - AQI
    
    func loadAQIData() {
        BSLAnimationActivityView.showAddToView(view: self.view)
        
        APIRequest.AQIQueryAPI { [weak self](data) in
            self?.todayAQIData = data as? CurrentAQI
            SessionManager.sharedInstance.currentAQI  = data as? CurrentAQI
            self?.updateTodayAQIView(data: (self?.todayAQIData)!)
            self?.bgImgView.image = self?.todayAQIData?.aqiBGImg()
            guard let cityID = self?.todayAQIData?.cityID else {
                return
            }
            
            if !SessionManager.sharedInstance.pushTags.contains("\(cityID)") {
                SessionManager.sharedInstance.pushTags.append("\(cityID)")
                SessionManager.sharedInstance.bindPushTags()
            }
            APIRequest.recentWeekAQIAPI(cityID: cityID, result: { [weak self](recentData) in
                self?.recentAQIData = recentData as? RecentWeekAQI
                self?.updateRecentWeekDataView(data: (self?.recentAQIData)!)
                BSLAnimationActivityView.dismiss(view: (self?.view)!)
                
            })
//            SessionManager.sharedInstance.userMaskConfig.updateCityID(cityID: cityID)
        }
        
    }
    
    /// 更新当天的 AQI
    ///
    /// - Parameter data: data
    func updateTodayAQIView(data: CurrentAQI) {
        cityButton.setTitle("  " + data.city, for: .normal)
        aqiLevelLabel.text = String(data.aqi)
        temperatureLabel.text = String(format: "%.0lf°C", data.temperature)
        windLevelLabel.text = String(format: NSLocalizedString("WindLevel", comment: ""),  data.windSpeed)
        pollutionLevelLabel.text = data.aqiLevelName
        //cigaretteNumLabel.text = String(format: NSLocalizedString("CirgaretteNum", comment: ""), data.smokeNum)
        //let smokeIconName = String(format: "icon%dc", data.smokeNum)
        //cigaretteIcon.image = UIImage(named: smokeIconName)
    }
    
    
    ///更新通知列表 是否显示红点
    func loadNotificationData() {
        APIRequest.getNotificationList(page: 1, rows: 20) {[weak self] (data) in
            
            var showDot = false
            if data != nil && data is NotificationList {
                let nlist = data as! NotificationList
                for item in nlist.list {
                    if item.readflag == 0 {
                        showDot = true
                        break
                    }
                }
            }
            self?.dotView.isHidden = !showDot
        }
    }
    
    
    func loadUserConfig() {
        APIRequest.getUserMaskConfig {(JSONData) in
            if let settingData = JSONData as? UserMaskConfig {
                SessionManager.sharedInstance.userMaskConfig = settingData
            }
        }
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
                if SessionManager.sharedInstance.token == "" {
                    showLoginVC()
                    return
                }
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
                if UIApplication.shared.canOpenURL(URL(string: url)!) {
                    UIApplication.shared.openURL(URL(string: url)!)
                }
//                let vc = BaseWebViewController()
//                vc.urlString = url
//                self?.navigationController?.pushViewController(vc, animated: true)
                break
            case .ItemBuyFilter:
                guard let url = self?.menuView.filterBuyUrl else {
                    break
                }
                if UIApplication.shared.canOpenURL(URL(string: url)!) {
                    UIApplication.shared.openURL(URL(string: url)!)
                }
//                let vc = BaseWebViewController()
//                vc.urlString = url
//                self?.navigationController?.pushViewController(vc, animated: true)
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
        
    }
    
    
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
    
    func handleTapNotificationBtn(_ sender: Any) {
        dotView.isHidden = true
        let vc = NotificationCenterController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func handleTapMenu(_:Any) {
        self.showModeControl(show: false)
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

        if mode.icon4.count > 0 {
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
        
        powerPopTip.hide()
        changeFilterPopTip.hide()
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
                
                let power = self.batteryLevelLb.text?.getIntFromString() ?? 100
                if power <= 20 {
                    self.lowerPowerAlert()
                }
                self.showChangeFilterAlert()
                
                if !UserDefaults.standard.bool(forKey: self.kShowModeControlGuideFlag) {
                    self.showMaskModeGuide()
                }
                
            })
        }
    }
    
    func changeToConnectMode(connect: Bool) {
        if connect {
            self.connectBluetoothView.alpha = 0
            self.aqiView.alpha = 0
            self.maskModeView.alpha = 1
            self.bottomView.alpha = 0
            self.modeControlView.alpha = 1
            self.selectModeView.alpha = 1
            self.bottomModeView.alpha = 1
            self.ovalCircleView.alpha = 1
            bluetoothUnConnectBtn.isHidden = true
            batteryView.isHidden = false
            UserDefaults.standard.set(false, forKey: kBluetoothConnectFlag)
            UserDefaults.standard.synchronize()
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
            //return
        }
        if BLSBluetoothManager.shareInstance.state != BluetoothState.Connected {
            return
        }
        if BLSBluetoothManager.shareInstance.currentPower > 20 {
            return
        }
        
        let maskConfig = SessionManager.sharedInstance.userMaskConfig
        if !maskConfig.lowpowerflag{
            return
        }
        
        hasShowLowPowerTip = true
        let popTip = powerPopTip
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
            //return
        }
        if maskModeView.alpha == 0 {
            return
        }
        if showingCircleAnimation {
            return
        }
        
        if BLSBluetoothManager.shareInstance.state != BluetoothState.Connected {
            return
        }
        let maskConfig = SessionManager.sharedInstance.userMaskConfig
        if !maskConfig.filterchangeflag ||
            (maskConfig.filtereffect != "l3" && maskConfig.filtereffect != "l2") {
            return
        }
        hasShowChangeFilter = true
        let popTip = changeFilterPopTip
        popTip.padding = 0
        popTip.cornerRadius = 8
        var tipView: BLTipView?
        if maskConfig.filtereffect == "l2" {
            tipView = BLTipView(frame: CGRect(x: 0, y: 0, width: 212, height: 44), msg: NSLocalizedString("ShouldChangeFilterTip", comment: ""), icon: UIImage(named: "iconQuestionM2"), textColor: UIColor.white, bgColor: UIColor.init(ri: 254, gi: 172, bi: 34)!)
        }
        else {
            tipView = BLTipView(frame: CGRect(x: 0, y: 0, width: 212, height: 44), msg: NSLocalizedString("ChangeFilterTip", comment: ""), icon: UIImage(named: "iconQuestionM2"), textColor: UIColor.white, bgColor: UIColor(hexString: "eb474e")!)
        }
        
        let frame = self.view.convert(stageLabel.frame, from: stageLabel.superview)
        popTip.show(customView: tipView!, direction: .down, in: self.view, from: frame)
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            popTip.hide()
        }
    }
    
    
    //MARK: - 引导
    
    func showConnectMaskGuide() {
        
        if UserDefaults.standard.bool(forKey: kShowGuideFlag) {
            return
        }
        if bottomView.alpha < 1 {
            return
        }
        
        if navigationController?.presentedViewController != nil ||
            self.presentedViewController != nil {
            return
        }
            
        guard let bottomCopy = bottomView.snapshotView(afterScreenUpdates: false) else {
            return
        }
        timer?.invalidate()
        timer = nil
        aqiView.alpha = 1
        connectBluetoothView.alpha = 0
        let frame = keyWindow?.convert(bottomView.frame, from: self.view)
        bottomCopy.frame = frame!

        guard let connectBtnCopy = searchBtn.snapshotView(afterScreenUpdates: false) else {
            return
        }
        connectBtnCopy.layer.cornerRadius = searchBtn.height/2
        connectBtnCopy.clipsToBounds = true
        connectBtnCopy.frame = searchBtn.frame
        bottomCopy.addSubview(connectBtnCopy)
        
        
        let guide = UIView(frame: UIScreen.main.bounds)
        guide.backgroundColor = UIColor(white: 0, alpha: 0.7)
        guide.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapConnectMaskGuide(sender:)))
        guide.addGestureRecognizer(tap)
        keyWindow?.addSubview(guide)
        
        guide.addSubview(bottomCopy)
        
        let line = UIImageView(image: #imageLiteral(resourceName: "cur-line-1"))
        line.contentMode = .scaleAspectFit
        guide.addSubview(line)
        line.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize(width: 47, height: 70))
            make.bottom.equalTo(-86)
            make.centerX.equalTo(guide.snp.centerX)
        })
        
        let tip = UIImageView(image: #imageLiteral(resourceName: "aqi-tip-word"))
        tip.contentMode = .scaleAspectFit
        guide.addSubview(tip)
        tip.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize(width: 266, height: 60))
            make.bottom.equalTo(line.snp.top).offset(-20)
            make.centerX.equalTo(guide.snp.centerX)
        })
        UserDefaults.standard.set(true, forKey: kShowGuideFlag)
        UserDefaults.standard.synchronize()
    }
    
    func handleTapConnectMaskGuide(sender: UIGestureRecognizer) {
        let guide = sender.view
        guide!.removeFromSuperview()
        showAQIGuideView()
    }
    
    func showAQIGuideView() {
        
        let aqiCopy = aqiView.snapshotView(afterScreenUpdates: false)
        aqiCopy?.frame = keyWindow!.convert(aqiView.frame, from: aqiView!.superview)
        
        let guide = UIView(frame: UIScreen.main.bounds)
        guide.backgroundColor = UIColor(white: 0, alpha: 0.7)
        guide.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapAQIGuide(sender:)))
        guide.addGestureRecognizer(tap)
        keyWindow?.addSubview(guide)
        
        guide.addSubview(aqiCopy!)
        
        let tip = UIImageView(image: #imageLiteral(resourceName: "connect-mask-tip-word"))
        tip.contentMode = .scaleAspectFit
        guide.addSubview(tip)
        tip.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize(width: 314, height: 60))
            make.top.equalTo(aqiCopy!.snp.bottom).offset(50)
            make.centerX.equalTo(guide.snp.centerX)
        })
        
        let handTip = UIImageView(image: #imageLiteral(resourceName: "HandM2-1-2"))
        handTip.contentMode = .scaleAspectFit
        guide.addSubview(handTip)
        handTip.snp.makeConstraints { (make) in
            make.centerX.equalTo(aqiCopy!.snp.centerX).offset(50)
            make.centerY.equalTo(aqiCopy!.snp.bottom).offset(-30)
        }
        
    }
    
    func handleTapAQIGuide(sender: UIGestureRecognizer) {
        let guide = sender.view!
        guide.removeFromSuperview()
        setupTimer()
    }
    
    func showMaskModeGuide() {
        
        
        if bottomModeView.alpha < 1 {
            return
        }
        
        if navigationController?.presentedViewController != nil ||
            self.presentedViewController != nil {
            return
        }
        
        guard let bottomCopy = bottomModeView.snapshotView(afterScreenUpdates: false) else {
            return
        }
        let frame = keyWindow?.convert(bottomModeView.frame, from: bottomModeView.superview)
        bottomCopy.frame = frame!
        
        guard let modeCircleCopy = modeCircleView.snapshotView(afterScreenUpdates: false) else {
            return
        }
        modeCircleCopy.layer.cornerRadius = modeCircleView.height/2
        modeCircleCopy.clipsToBounds = true
        modeCircleCopy.frame = keyWindow!.convert(modeCircleView.frame, from: modeCircleView.superview)

        let guide = UIView(frame: UIScreen.main.bounds)
        guide.backgroundColor = UIColor(white: 0, alpha: 0.7)
        guide.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapMaskModeGuide(sender:)))
        guide.addGestureRecognizer(tap)
        keyWindow?.addSubview(guide)
        
        guide.addSubview(modeCircleCopy)
        guide.addSubview(bottomCopy)
        
        let line = UIImageView(image: #imageLiteral(resourceName: "cur-line-2"))
        line.contentMode = .scaleAspectFit
        guide.addSubview(line)
        line.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize(width: 47, height: 70))
            make.bottom.equalTo(-76)
            make.left.equalTo(97)
        })
        
        let handTip = UIImageView(image: #imageLiteral(resourceName: "Hand-2"))
        handTip.contentMode = .scaleAspectFit
        guide.addSubview(handTip)
        handTip.snp.makeConstraints { (make) in
            make.bottom.equalTo(-72)
            make.right.equalTo(-120)
        }
        
        let line2 = UIImageView(image: #imageLiteral(resourceName: "ArrowDownM3-1-2"))
        line2.contentMode = .scaleAspectFit
        guide.addSubview(line2)
        line2.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize(width: 30, height: 36))
            make.bottom.equalTo(-76)
            make.right.equalTo(-50)
        })
        
        let tip1 = UIImageView(image: #imageLiteral(resourceName: "mode-tip-word"))
        tip1.contentMode = .scaleAspectFit
        guide.addSubview(tip1)
        tip1.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize(width: 110, height: 60))
            make.left.equalTo(42)
            make.bottom.equalTo(line.snp.top).offset(-20)
        })
        
        let tip2 = UIImageView(image: #imageLiteral(resourceName: "mode-tip-word"))
        tip2.contentMode = .scaleAspectFit
        guide.addSubview(tip2)
        tip2.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize(width: 129, height: 60))
            make.right.equalTo(-32)
            make.bottom.equalTo(line2.snp.top).offset(-20)
        })
        UserDefaults.standard.set(true, forKey: kShowModeControlGuideFlag)
        UserDefaults.standard.synchronize()
    }
    
    func handleTapMaskModeGuide(sender: UIGestureRecognizer) {
        let guide = sender.view!
        guide.removeFromSuperview()
    }
}
