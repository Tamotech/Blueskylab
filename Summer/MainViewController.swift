//
//  MainViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/6/19.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import AMPopTip

class MainViewController: BaseViewController, BluetoothViewDelegate,WindModeSelectDelegate {

    
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
    
    
    
    lazy var modeControlView: WindModeControllView = {
        let view = WindModeControllView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 246))
        return view
    } ()
    
    var timer:Timer?
    
    
    var maskView: UIView!
    var menuView: MainMenuView!
    var edgePanGes:UIScreenEdgePanGestureRecognizer!
    var panGes:UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        shouldClearNavBar = true
        self.setupView()
        self.setupGesture()
        self.setupTimer()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navVC = self.navigationController as! BaseNavigationController
        navVC.setTintColor(tint: .white)
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

        scrollView.isHidden = false
        maskModeView.isHidden = true
        bottomView.isHidden = false
        bottomModeView.isHidden = true
        
        modeManageView.addSubview(modeControlView)
        modeControlView.delegate = self
        modeControlBottom.constant = -303
        selectModeView.isHidden = true
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
        if currentIndex >= 3 {
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
            default:
                break
            }
        }
        self.navigationController!.view.superview?.insertSubview(menuView, at: 0)
        
        
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
        
    }
    
    @IBAction func handleTapUpModelBtn(_ sender: UIButton) {
        
        modeControlBottom.constant = 0
        self.selectModeView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (success) in
            
        }
    }
    
    
    @IBAction func handleTapHistoryBtn(_ sender: Any) {
        let vc = HistoryDataViewController(nibName: "HistoryDataViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 点击收起选择模式
    @IBAction func handleTapFoldSelectModeBtn(_ sender: UIButton) {
        
        modeControlBottom.constant = -self.selectModeView.height
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) {(success) in
            self.selectModeView.isHidden = true
        }
    }
    
    //MARK: - WindModeSelectDelegate
    
    func clickAddMode() {
        let vc = AddModeViewController(nibName: "AddModeViewController", bundle: nil)
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    //MARK: - BluetoothDelegate
    
    func didConnectBlueTooth() {
        scrollView.isHidden = true
        maskModeView.isHidden = false
        bottomView.isHidden = true
        modeControlView.isHidden = false
        bottomModeView.isHidden = false
    }

}
