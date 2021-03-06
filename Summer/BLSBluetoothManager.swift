//
//  BLSBluetoothManager.swift
//  Summer
//
//  Created by 武淅 段 on 2017/9/24.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import CoreBluetooth
import iOSDFULibrary

enum BluetoothState {
    case Unauthorized       //未授权
    case PowerOff           //蓝牙关闭
    case PowerOn            //蓝牙已开启
    case Connected          //设备已连接
    case ConnectFailed      //设备连接失败
    case DisConnected       //设备已断开
}

let firmwareVersionUserKey = "firmware_version_key_001"

/// 蓝牙状态改变回调
typealias BluetoothStateUpdateCallback = (BluetoothState)->()
typealias MaskPowerChangeCallback = (Int)->()
typealias MaskWindSpeedChangeCallback = (CGFloat)->()

class BLSBluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate,
DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate {
    
    let speedServiceID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    let deviceInfoServiceID = "0x180A"
    let batteryServiceID = "0x180F"
    let maskName = ["BSL-M1", "ATMOBLUE-1"]
    ///电池服务
    let kBatteryCharacteristicUUID = "0x2A19"
    ///硬件信息服务
    let kManufactererCharacteristicUUID = "0x2A29"
    let hardwareCharacteristicUUID = "0x2A27"
    let firmwareCharacteristicUUID = "0x2A26"
    ///调速模式服务
    let kSpeedWriteCharacteristicUUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
    let kSpeedReadCharacteristicUUID = "6e400004-b5a3-f393-e0a9-e50e24dcca9e"
//    let firmwareCharacteristicUUID = "0x2A26"
//    let firmwareCharacteristicUUID = "0x2A26"
    
    ///风速服务
    var speedService: CBService?
    ///电量特征值
    var powerChar: CBCharacteristic?
    ///电量服务ID
    var powerServiceID = "0x180F"
    ///电量服务
    var powerService: CBService?
    /// 固件升级特征值
    var firewareChar: CBCharacteristic?
    var firmwarePeriph: CBPeripheral?
    fileprivate var dfuController : DFUServiceController?
    
    ///调节风速特征值
    var speedChar: CBCharacteristic?
    
    var batteryLevel: Int = 100
    var peripheral: CBPeripheral?
    var DFUPeripheral: CBPeripheral?
    
//    var stateUpdate: BluetoothStateUpdateCallback?
//    var powerChange: MaskPowerChangeCallback?
//    var speedChange: MaskWindSpeedChangeCallback?
    
    static let shareInstance = BLSBluetoothManager()
    var manager: CBCentralManager?
    var state: BluetoothState = BluetoothState.Unauthorized
    
    ///当前风速
    var currentWindSpeed: CGFloat = 0
    ///当前电量
    var currentPower: Int = 100
    ///蓝牙设备的UUID
    var deviceUUID: String?
    
    ///是否需要固件升级
    /// NOTE: 是否需要升级  是一开始就确定的 为了保证这个效果, 需要记录上一次的固件版本号, 下次直接从本地读取并存入最新的固件版本
    var shouldUpdateFirmware = false
    
    var DFUMode = false
    
    //// stop状态   断开模式下重连 0 默认 1 写入DFU后重连  2 DFU升级完成后重连蓝牙调节风速 3 完成蓝牙连接
    var stopMode: Int = 0
    
    
    /// 固件版本号
    var firmwareVersion: String?
    
    
    ///平均风速
    var aveWindSpeed: CGFloat = 0
    var calcDeviceInfo = CalcDeviceInfo()
    
    var timer: Timer?
    var onceToken = false
    
    override init() {
        super.init()
        firmwareVersion = UserDefaults.standard.object(forKey: firmwareVersionUserKey) as? String
    }
    
    func setupManager() {
        
        
        //确定是否需要升级
        if !onceToken {
            onceToken = true
            if firmwareVersion != nil && SessionManager.sharedInstance.firewareVersion != nil {
                shouldUpdateFirmware = String.compareVersionString(first: SessionManager.sharedInstance.firewareVersion!, second: firmwareVersion!) > 0
            }
        }
        
        manager = CBCentralManager(delegate: self, queue: nil)
        manager?.delegate = self
        manager?.scanForPeripherals(withServices: nil, options: nil)
        print("开始扫描设备...")
        if !shouldUpdateFirmware {
            setupTimer()
        }
    }
    
    func setupTimer() {
        timer = Timer(timeInterval: 10, target: self, selector: #selector(timerHandle(t:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
        currentWindSpeed = CGFloat(SessionManager.sharedInstance.windModeManager.currentMode?.value ?? 0)
    }
    
    func timerHandle(t: Timer) {
        
        //同步风速
        currentWindSpeed = CGFloat(SessionManager.sharedInstance.windModeManager.currentMode?.value ?? 0)
        
        if calcDeviceInfo.totalTimeSecond > 0 {
            aveWindSpeed = CGFloat(calcDeviceInfo.agvWindspeed * calcDeviceInfo.totalTimeSecond + Int(currentWindSpeed) * 10)/CGFloat(calcDeviceInfo.totalTimeSecond + 10)
            
            calcDeviceInfo.agvWindspeed = Int(aveWindSpeed)
        }
        calcDeviceInfo.totalTimeSecond = calcDeviceInfo.totalTimeSecond + 10
        
        if powerService != nil && peripheral != nil {
            peripheral!.discoverCharacteristics(nil, for: powerService!)
        }
        if speedService != nil && peripheral != nil {
            peripheral!.discoverCharacteristics(nil, for: speedService!)
        }
    }
    
    
    //MARK - CBCentralManager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("CentralManager is initialized")
        var state: BluetoothState = .Unauthorized
        if #available(iOS 10.0, *) {
            switch central.state {
            case CBManagerState.unauthorized:
                print("unauthorized")
                state = .Unauthorized
                break
            case CBManagerState.poweredOff:
                print("poweredOff")
                state = .PowerOff
                self.stop()
                break
            case CBManagerState.poweredOn:
                print("Bluetooth is currently powered on and available to use.")
                manager?.scanForPeripherals(withServices: nil, options: nil)
                state = .PowerOn
                break
            default:break
            }
        } else {
            // Fallback on earlier versions
            switch central.state.rawValue {
            case 3:
                print("unauthorized")
                state = .Unauthorized
                break
            case 4:
                print("poweredOff")
                state = .PowerOff
                self.stop()
                break
            case 5:
                print("Bluetooth is currently powered on and available to use.")
                state = .PowerOn
                break
            default:break
            }
        }
        
        self.state = state
        NotificationCenter.default.post(name: kMaskStateChangeNotifi, object: nil, userInfo: ["key": "state", "value": state])
    }
    
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("发现设备 ---- \(peripheral.name ?? "")   信号强度: \(RSSI)")
        
        
//        guard let name = peripheral.name else {
//            return
//        }
        if peripheral.name == "DfuTarg" {
            
            self.DFUPeripheral = peripheral
            manager?.stopScan()
            manager?.connect(peripheral, options: nil)
        }
        
        else if maskName.contains(peripheral.name ?? "") {
            //开始连接口罩
            deviceUUID = peripheral.identifier.uuidString
            self.bindBlueToothDevice()
            manager?.stopScan()
            manager?.connect(peripheral, options: nil)
            self.peripheral = peripheral
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("设备已连接 -- \(peripheral.name ?? "")")
        
        if peripheral.name == "DfuTarg" {
            print("开始下载固件...")
            self.updateFireware()
        }
        if !self.shouldUpdateFirmware {
            self.state = .Connected
            NotificationCenter.default.post(name: kMaskStateChangeNotifi, object: nil, userInfo: ["key": "state", "value": state])
            //蓝牙连接成功
            HealthDataManager.sharedInstance.startPedometerUpdates()
            //NotificationCenter.default.post(name: kMaskDidDisConnectBluetoothNoti, object: nil)
            
        }
        peripheral.delegate = self
        manager?.stopScan()
        //开始扫描服务
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("设备连接失败 --- \(error?.localizedDescription ?? "")")
        self.state = .ConnectFailed
        NotificationCenter.default.post(name: kMaskStateChangeNotifi, object: nil, userInfo: ["key": "state", "value": state])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("设备已断开 ----")
//        if !shouldUpdateFirmware {
        
//        }
        
        //这两种情况都是临时断开 需要重连
        if stopMode == 1 {
            self.setupManager()
            stopMode = 0
        }
        
        self.state = .DisConnected
        NotificationCenter.default.post(name: kMaskStateChangeNotifi, object: nil, userInfo: ["key": "state", "value": state])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("发现服务 --- \(peripheral.services ?? [])")
        for service in peripheral.services ?? [] {
            if service.uuid.isEqual(CBUUID(string: powerServiceID)) {
                powerService = service
            }
            else if service.uuid.isEqual(CBUUID(string: speedServiceID)) {
                speedService = service
            }
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    ///发现特征值
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("特征值 --- \(service.characteristics ?? [])")
        for char in service.characteristics! {
            if char.uuid.isEqual(CBUUID(string: kBatteryCharacteristicUUID)) {
                //电池电量
                peripheral.readValue(for: char)
                powerChar = char
                var power: Int = 100
                if let value = char.value {
                    
                    let str = NSString(data: value, encoding: String.Encoding.utf8.rawValue)!
                    print("power str ---> \(str)")
                    power = Int(str.cString(using: String.Encoding.ascii.rawValue)!.pointee)
                    
                    //power = NSString(data: value, encoding: String.Encoding.utf8.rawValue)!.integerValue
                    print("电池电量--- \(power)")
                }
                
                print("电池电量--- \(power)")
                currentPower = power
                NotificationCenter.default.post(name: kMaskStateChangeNotifi, object: nil, userInfo: ["key": "power", "value": power])
                
            }
            else if char.uuid.isEqual(CBUUID(string: kSpeedWriteCharacteristicUUID)) {
                //写风速
                peripheral.readValue(for: char)
                speedChar = char
                if let value = char.value {
                    print("写风速--- \(value)")
                    
                }
            }
            else if char.uuid.isEqual(CBUUID(string: kSpeedReadCharacteristicUUID)) {
                if char.value != nil {
                    let str = NSString(data: char.value!, encoding: String.Encoding.utf8.rawValue)!
                    print("读风速---\(str)")
                    //let speed = str.floatValue
                    NotificationCenter.default.post(name: kMaskStateChangeNotifi, object: nil, userInfo: ["key": "speed", "value": CGFloat(str.floatValue)])
                }
                
            }
            else if (char.uuid.isEqual(CBUUID(string: self.firmwareCharacteristicUUID))) {
                
                if char.value != nil && SessionManager.sharedInstance.firewareVersion != nil {
                    let str = NSString(data: char.value!, encoding: String.Encoding.utf8.rawValue)!
                    print("固件character ---> \(str)")
                    firmwarePeriph = peripheral
                    firewareChar = char
                    UserDefaults.standard.set(String(str), forKey: firmwareVersionUserKey)
                    
                    if shouldUpdateFirmware {
                        self.switchToDFUMode()
                        
                    }

                }
                
            }
            else if (char.uuid.isEqual(CBUUID(string: self.hardwareCharacteristicUUID))) {
                if char.value != nil {
                    let str = NSString(data: char.value!, encoding: String.Encoding.utf8.rawValue)!
                    print("硬件服务特征值 ----> \(str)")
                    
                }
                
            }
        }
    }
    
    
    ///写风速操作
    ///value vibrate:n;  (n 1-20)  value: 0-100
    func ajustSpeed(mode: UserWindSpeedConfig) {
        if mode.valueMax == 0 {
            return
        }
        currentWindSpeed = CGFloat(mode.value)
        let gear = mode.value*mode.gearMax/mode.valueMax
        let str = "vibrate:\(gear);"
        let data = str.data(using: .utf8)!
        if self.peripheral == nil || self.speedChar == nil {
            return
        }
        self.writeData(peripheral: self.peripheral!, characteristic: self.speedChar!, data: data)
    }
    
    ///口罩切换到智能模式
    func switchToIntelligenceModeForMask() {
        let str = "priority:1;"
        let data = str.data(using: .utf8)!
        if self.peripheral == nil || self.speedChar == nil {
            return
        }
        self.writeData(peripheral: self.peripheral!, characteristic: self.speedChar!, data: data)
    }
    
    ///DFU升级模式
    func switchToDFUMode() {
        print("切换到DFU模式")
        if DFUMode {
            return
        }
        let str = "DFU;"
        let data = str.data(using: .utf8)!
        if self.peripheral == nil || self.speedChar == nil {
            print("peripheral为空或者speedChar为空")
            return
        }
        self.writeData(peripheral: self.peripheral!, characteristic: self.speedChar!, data: data)
        stopMode = 1
        print("成功写入 DFU;, 断开重连...")
        DFUMode = true
        //此时BM-1断开  需要重新扫描连接DFU的设备
        // NOTE: 此时物理层断开有几秒的延迟  所以不能立即重连
        //self.stop()
        
        //self.setupManager()
    }
    
    
    ///写数据
    func writeData(peripheral: CBPeripheral, characteristic: CBCharacteristic, data: Data) {
        print("写入数据---> \(data.description)")
//        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    ///解绑 断开连接
    func stop() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        if peripheral != nil {
            print("cancel peripheral")
            manager?.cancelPeripheralConnection(peripheral!)
        }
        currentWindSpeed = 0
        HealthDataManager.sharedInstance.stopPedometerUpdate()
        manager?.stopScan()
        state = .DisConnected
        DFUMode = false
    }
    
    
    //MARK: - DFUServiceDelegate
    
    func dfuStateDidChange(to state: DFUState) {
        print("DFU status changed --> \(state)")
        if state == .completed {
            SVProgressHUD.dismiss()
            shouldUpdateFirmware = false
            DFUMode = false
            if DFUPeripheral != nil {
                print("cancel peripheral")
                manager?.cancelPeripheralConnection(DFUPeripheral!)
            }
            manager?.stopScan()
            
            //升级固件完毕  重新连接扫描设备
            DFUPeripheral = nil
            stopMode = 0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1, execute: {
                self.setupManager()
                
            })
            
            
        }
        else if state == .aborted || state == .disconnecting {
            SVProgressHUD.dismiss()
            
        }
    }
    
    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        print("DFU error---> \(message)")
    }
    
    //MARK: - DFUProgressDelegate
    
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        
        let uploadStatus = String(format: "Part: %d/%d\nSpeed: %.1f KB/s\nAverage Speed: %.1f KB/s",
                                      part, totalParts, currentSpeedBytesPerSecond/1024, avgSpeedBytesPerSecond/1024)
        print("upload status---> \(uploadStatus)")
    }
    
    //MARK: - LoggerDelegate
    
    func logWith(_ level: LogLevel, message: String) {
        print("\(level.name()): \(message)")
    }
    
    ///与用户绑定
    func bindBlueToothDevice() {
        SessionManager.sharedInstance.userMaskConfig.bindMask()
    }
    
    ///下载最先固件升级
    func updateFireware() {
        guard let url = SessionManager.sharedInstance.firewareDownloadUrl else {
            return
        }
        if !shouldUpdateFirmware {
            return
        }
        let request = URLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        let task = session.downloadTask(with: request) { (locationURL, response, error) in
            if error != nil {
                print("下载固件失败--->\(error.debugDescription)")
            }
            else if locationURL != nil {
                print("下载固件成功, 开始写入蓝牙")
                //下载成功  开始写入蓝牙
                
                SVProgressHUD.show(withStatus: "固件升级中...")
                //location位置转换
                let locationPath = locationURL!.path
                //拷贝到用户目录
                let datestr = String(Date().timeIntervalSince1970)
                let documnets:String = NSTemporaryDirectory()+datestr+"firmware.zip"
                //创建文件管理器
                let fileManager = FileManager.default
                try! fileManager.moveItem(atPath: locationPath, toPath: documnets)
                self.startDFUProcess(fileURL: URL(fileURLWithPath: documnets))
            }
        }
        
        task.resume()
        
        
        
    }
    
    ///开始写入固件
    func startDFUProcess(fileURL: URL) {
        let selectedFirmware =  DFUFirmware(urlToZipFile: fileURL)
        guard DFUPeripheral != nil else {
            print("No DFU peripheral was set")
            return
        }
        
        let dfuInitiator = DFUServiceInitiator(centralManager: manager!, target: DFUPeripheral!)
        dfuInitiator.delegate = self
        dfuInitiator.progressDelegate = self
        dfuInitiator.logger = self
        
        // This enables the experimental Buttonless DFU feature from SDK 12.
        // Please, read the field documentation before use.
        //dfuInitiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
        
        dfuController = dfuInitiator.with(firmware: selectedFirmware!).start()
    }
    
    
}
