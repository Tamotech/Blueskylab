//
//  BLSBluetoothManager.swift
//  Summer
//
//  Created by 武淅 段 on 2017/9/24.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import CoreBluetooth

enum BluetoothState {
    case Unauthorized       //未授权
    case PowerOff           //蓝牙关闭
    case PowerOn            //蓝牙已开启
    case Connected          //设备已连接
    case ConnectFailed      //设备连接失败
    case DisConnected       //设备已断开
}


/// 蓝牙状态改变回调
typealias BluetoothStateUpdateCallback = (BluetoothState)->()

class BLSBluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let speedServiceID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    let deviceInfoServiceID = "0x180A"
    let batteryServiceID = "0x180F"
    let maskName = "BSL-M1"
    ///电池服务
    let kBatteryCharacteristicUUID = "0x2A19"
    ///硬件信息服务
    let kManufactererCharacteristicUUID = "0x2A29"
    let hardwareCharacteristicUUID = "0x2A27"
    let firmwareCharacteristicUUID = "0x2A26"
    ///调速模式服务
    let kSpeedWriteCharacteristicUUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
//    let firmwareCharacteristicUUID = "0x2A26"
//    let firmwareCharacteristicUUID = "0x2A26"
    
    ///电量特征值
    var powerChar: CBCharacteristic?
    ///调节风速特征值
    var speedChar: CBCharacteristic?
    
    var batteryLevel: Int = 100
    var peripheral: CBPeripheral?
    
    var stateUpdate: BluetoothStateUpdateCallback?
    
    static let shareInstance = BLSBluetoothManager()
    var manager: CBCentralManager?
    var state: BluetoothState = BluetoothState.Unauthorized
    
    func setupManager() {
        manager = CBCentralManager(delegate: self, queue: nil)
        manager?.delegate = self
        manager?.scanForPeripherals(withServices: nil, options: nil)
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
                break
            case 5:
                print("Bluetooth is currently powered on and available to use.")
                state = .PowerOn
                break
            default:break
            }
        }
        
        self.state = state
        if stateUpdate != nil {
            stateUpdate!(state)
        }
    }
    
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("发现设备 ---- \(peripheral.name ?? "")   信号强度: \(RSSI)")
        if peripheral.name == maskName {
            //开始连接口罩
            manager?.stopScan()
            manager?.connect(peripheral, options: nil)
            self.peripheral = peripheral
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("设备已连接 -- \(peripheral.name ?? "")")
        if stateUpdate != nil {
            self.state = .Connected
            stateUpdate!(.Connected)
        }
        peripheral.delegate = self
        manager?.stopScan()
        //开始扫描服务
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("设备连接失败 --- \(error?.localizedDescription ?? "")")
        if stateUpdate != nil {
            self.state = .ConnectFailed
            stateUpdate!(.ConnectFailed)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("设备已断开 ----")
        if stateUpdate != nil {
            self.state = .DisConnected
            stateUpdate!(.DisConnected)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("发现服务 --- \(peripheral.services ?? [])")
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    ///发现特征值
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("特征值 --- \(service.characteristics ?? [])")
        for char in service.characteristics! {
            if char.uuid.isEqual(CBUUID(string: kBatteryCharacteristicUUID)) {
                //电池电量
                powerChar = char
                if let value = char.value {
                    print("电池电量--- \(value)")
                    
                }
            }
            else if char.uuid.isEqual(CBUUID(string: kSpeedWriteCharacteristicUUID)) {
                //写风速
                speedChar = char
                if let value = char.value {
                    print("写风速--- \(value)")
                    
                }
            }
        }
    }
    
    
    ///写风速操作
    ///value vibrate:n;  (n 1-20)  value: 0-100
    func ajustSpeed(value: CGFloat) {
        let str = "vibrate:\(Int(value*20.0/100.0));"
        let data = str.data(using: .utf8)!
        if self.peripheral == nil || self.speedChar == nil {
            return
        }
        self.writeData(peripheral: self.peripheral!, characteristic: self.speedChar!, data: data)
    }
    
    ///写数据
    func writeData(peripheral: CBPeripheral, characteristic: CBCharacteristic, data: Data) {
        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
    }
    
    ///解绑 断开连接
    func stop() {
        if peripheral != nil {
            manager?.cancelPeripheralConnection(peripheral!)
        }
        manager?.stopScan()
        state = .DisConnected
        if self.stateUpdate != nil {
            self.stateUpdate!(.DisConnected)
        }
    }
}
