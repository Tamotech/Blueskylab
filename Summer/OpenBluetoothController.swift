//
//  OpenBluetoothController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/5.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol BluetoothViewDelegate {
    func didConnectBlueTooth()
}

class OpenBluetoothController: BaseViewController, CBCentralManagerDelegate {

    
    
    @IBOutlet weak var connectingView: UIView!
    
    @IBOutlet weak var ovalCircleView: UIImageView!
    
    @IBOutlet weak var unconnectingView: UIView!
    
    @IBOutlet weak var mTitleLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var lightTipBtn: UIButton!
    
    var delegate:BluetoothViewDelegate?
    
    lazy var centralManager:CBCentralManager = {
       return CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        shouldClearNavBar = true
        setupView()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        
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
    }

    
    //MARK: - actions
    
    
    @IBAction func handleTapOpenBluetoothBtn(_ sender: Any) {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        UIView.animate(withDuration: 0.3) { 
            self.unconnectingView.isHidden = true
            self.connectingView.isHidden = false
        }
        showUnfindBluetoothAlert()
    }
    
    @IBAction func handleTapDontBindBtn(_ sender: Any) {
        dismiss(animated: true) { 
            if self.delegate != nil {
                self.delegate?.didConnectBlueTooth()
            }
        }
    }
    
    @IBAction func handleTapLightBtn(_ sender: Any) {
    }
    
    //MARK - CBCentralManager
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("CentralManager is initialized")
        if #available(iOS 10.0, *) {
            switch central.state {
            case CBManagerState.unauthorized:
                print("unauthorized")
                break
            case CBManagerState.poweredOff:
                print("poweredOff")
                break
            case CBManagerState.poweredOn:
                print("Bluetooth is currently powered on and available to use.")
                break
            default:break
            }
        } else {
            // Fallback on earlier versions
            switch central.state.rawValue {
            case 3:
                print("unauthorized")
                break
            case 4:
                print("poweredOff")
                break
            case 5:
                print("Bluetooth is currently powered on and available to use.")
                break
            default:break
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }
    
    
    //MARK: - private
    
    private func showOpenBluetoothAlert() {
        let alert = UIAlertController(title: NSLocalizedString("OpenBluetoothAlertTitle", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { (setAction) in
            
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (okAction) in
            
        }))
        present(alert, animated: true, completion: nil)

    }
    
    private func showUnfindBluetoothAlert() {
        let alert = UIAlertController(title: NSLocalizedString("UnfindBluetoothAlertTitle", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Retry", comment: ""), style: .default, handler: { (action1) in
            BLHUDBarManager.showSuccess(msg: NSLocalizedString("BindSuccess", comment: ""))
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Help", comment: ""), style: .default, handler: { (action2) in
            
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("DontBind", comment: ""), style: .default, handler: { (action3) in
            self.dismiss(animated: true, completion: nil)
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
