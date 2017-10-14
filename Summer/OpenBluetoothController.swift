//
//  OpenBluetoothController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/5.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

protocol BluetoothViewDelegate {
    func didConnectBlueTooth()
}

class OpenBluetoothController: BaseViewController {

    
    
    let speedServiceID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    
    @IBOutlet weak var connectingView: UIView!
    
    @IBOutlet weak var ovalCircleView: UIImageView!
    
    @IBOutlet weak var unconnectingView: UIView!
    
    @IBOutlet weak var mTitleLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var lightTipBtn: UIButton!
    
    var timer: Timer?
    let defaultSeconds: Int = 20
    var seconds: Int = 0
    
    weak var manager: BLSBluetoothManager? = BLSBluetoothManager.shareInstance
    
    var delegate:BluetoothViewDelegate?
    
    
    deinit {
        manager = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        shouldClearNavBar = true
        setupView()
        setupTimer()
        manager!.setupManager()
        manager!.stateUpdate = {(state: BluetoothState) in
            switch state {
            case .Unauthorized:
                self.unconnectingView.isHidden = false
                break
            case .PowerOff:
                self.unconnectingView.isHidden = false
                self.showOpenBluetoothAlert()
                break
            case .PowerOn:
                self.unconnectingView.isHidden = true
                self.connectingView.isHidden = false
                break
            case .Connected:
                self.manager = nil
                self.navigationController!.dismiss(animated: true, completion: {
                    if self.delegate != nil {
                        self.delegate!.didConnectBlueTooth()
                    }
                })
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1, execute: {
////                    BLHUDBarManager.showSuccess(msg: NSLocalizedString("BindSuccess", comment: ""))
//                    
//
//                })
                break
                
            case .ConnectFailed:
                
                break
            case .DisConnected:
                
                break
            
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)

    }
    
    func setupView() {
        let layer1 = CAGradientLayer()
        layer1.frame = connectingView.bounds
        layer1.colors = [UIColor(hexString: "28baf9")!, UIColor(hexString: "0196db")!]
        layer1.startPoint = CGPoint(x: 0.5, y: 0)
        layer1.endPoint = CGPoint(x: 0.5, y: 1)
        connectingView.layer.addSublayer(layer1)
        
        ovalCircleView.layer.removeAllAnimations()
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = Double.pi*2
        animation.duration = 2
        animation.repeatCount = Float(CGFloat.greatestFiniteMagnitude)
        animation.autoreverses = false
        animation.isRemovedOnCompletion = false
        ovalCircleView.layer.add(animation, forKey: nil)
        
        lightTipBtn.isHidden = true
        
        unconnectingView.isHidden = true
        
    }
    
    func setupTimer() {
        timer = Timer(timeInterval: 1, target: self, selector: #selector(timerHandler(t:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
        seconds = defaultSeconds
    }

    
    //MARK: - timer
    func timerHandler(t: Timer) {
        seconds = seconds - 1
        if seconds<=0 {
            timer!.invalidate()
            timer = nil
            showUnfindBluetoothAlert()
        }
    }
    
    //MARK: - actions
    
    @IBAction func handleTapOpenBluetoothBtn(_ sender: Any) {
       
        UIView.animate(withDuration: 0.3) { 
//            self.unconnectingView.isHidden = true
//            self.connectingView.isHidden = false
            self.showOpenBluetoothAlert()
        }
        //showUnfindBluetoothAlert()
        
    }
    
    @IBAction func handleTapDontBindBtn(_ sender: Any) {
        self.manager?.stop()
        self.manager = nil
        navigationController!.dismiss(animated: true) {
//            if self.delegate != nil {
//                self.delegate?.didConnectBlueTooth()
//            }
        }
    }
    
    @IBAction func handleTapLightBtn(_ sender: Any) {
        
    }
    
    
    
    
    
    
    private func showOpenBluetoothAlert() {
        let alert = UIAlertController(title: NSLocalizedString("OpenBluetoothAlertTitle", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { (setAction) in
            let url = URL(string: "App-Prefs:root=Bluetooth")
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.openURL(url!)
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (okAction) in
            
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    private func showUnfindBluetoothAlert() {
        let alert = UIAlertController(title: NSLocalizedString("UnfindBluetoothAlertTitle", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Retry", comment: ""), style: .default, handler: { (action1) in
//            BLHUDBarManager.showSuccess(msg: NSLocalizedString("BindSuccess", comment: ""))
            self.setupTimer()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Help", comment: ""), style: .default, handler: { (action2) in
            let vc = ArticleDetailController()
            vc.articleId = "9cc44bd3-3129-4ad5-a634-88c437ae4067"
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("DontBind", comment: ""), style: .default, handler: { (action3) in
            self.navigationController!.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
}
