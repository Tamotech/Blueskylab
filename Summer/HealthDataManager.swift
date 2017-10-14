//
//  HealthDataManager.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/31.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import HealthKit
import CoreMotion

///运动更新 速度/距离/步数

protocol MotionDataDelegate: class {
    
    
    /// 运动数据更新
    ///
    /// - Parameters:
    ///   - distance: 距离 m
    ///   - speed:  速度 m/s
    ///   - stepCount:  步数
    ///   - carlories: 消耗卡路里
    func motionDataUpdate(distance: Float, speed: Float, stepCount: Int, carlories: Float)
    
    
    /// 时间计数
    ///
    /// - Parameter timeStr:  HH:MM:ss
    func timerStrUpdate(timeStr: String)
}

class HealthDataManager: NSObject {

    //计步器对象
    let pedometer = CMPedometer()
    weak var delegate: MotionDataDelegate?
    var motioning: Bool = false     //是否是运动中
    var seconds: Int = 0
    
    var timer: Timer?
    
    static let sharedInstance = HealthDataManager()
    
    
    ///清零标志 10-08  理论上清零只需要重置计步器即可, 而设计需要单独清零步数和卡路里
    var zeroStep: Int = 0
    var zeroDistance: Float = 0
    
    var totalDistance: Int = 0
    var totalSteps: Int = 0
    var totalCarlories: Int = 0
    
    
    
    // 开始获取步数计数据
    func startPedometerUpdates() {
        
        if motioning {
            return
        }
        motioning = true
        //判断设备支持情况
        guard CMPedometer.isStepCountingAvailable() else {
            print("Current device is not support CoreMotion Data")
            return
        }
        
        timer = Timer(fireAt: Date(), interval: 1, target: self, selector: #selector(handleTimerEvent(t:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .defaultRunLoopMode)
        timer!.fire()
        
        //获取今天凌晨时间
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
//        let midnightOfToday = cal.date(from: comps)!
        let now = Date()
        
        //初始化并开始实时获取数据
        self.pedometer.startUpdates (from: now, withHandler: { pedometerData, error in
            //错误处理
            guard error == nil else {
                print(error!)
                return
            }
            
            //获取各个数据
            var steps: Int = 0
            var speed: Float = 0
            var dis: Float = 0
            var text = "---今日运动数据---\n"
            if let numberOfSteps = pedometerData?.numberOfSteps {
                text += "步数: \(numberOfSteps)\n"
                steps = numberOfSteps.intValue
            }
            if let distance = pedometerData?.distance {
                text += "距离: \(distance)\n"
                dis = distance.floatValue
            }
            if let floorsAscended = pedometerData?.floorsAscended {
                text += "上楼: \(floorsAscended)\n"
            }
            if let floorsDescended = pedometerData?.floorsDescended {
                text += "下楼: \(floorsDescended)\n"
            }
            if #available(iOS 9.0, *) {
                if let currentPace = pedometerData?.currentPace {
                    text += "速度: \(currentPace)m/s\n"
                    speed = currentPace.floatValue
                }
            } else {
                // Fallback on earlier versions
            }
            if #available(iOS 9.0, *) {
                if let currentCadence = pedometerData?.currentCadence {
                    text += "速度: \(currentCadence)步/秒\n"
                }
            } else {
                // Fallback on earlier versions
            }
            
            //print(text)
            
            var carlories: Float = 0
            if self.zeroStep != 0 && steps > self.zeroStep {
                steps = steps-self.zeroStep
            }
            if self.zeroDistance != 0 && dis > self.zeroDistance {
                let newDis = dis-self.zeroDistance
                carlories = Float((SessionManager.sharedInstance.userInfo?.getWeight())!*CGFloat(newDis/1000)*1.036)
            }
            else {
                carlories = Float((SessionManager.sharedInstance.userInfo?.getWeight())!*CGFloat(dis/1000)*1.036)
            }
            if self.delegate != nil {
                self.delegate?.motionDataUpdate(distance: dis, speed: speed, stepCount: steps, carlories: carlories)
            }
            self.totalDistance = Int(dis)
            self.totalSteps = steps
            self.totalCarlories = Int(carlories)
            
        })
    }
    
    func stopPedometerUpdate() {
        self.pedometer.stopUpdates()
        timer!.invalidate()
        motioning = false
        zeroDistance = 0
        zeroStep = 0
        seconds = 0
        
        //保存数据
        saveMaskUseData()
    }
    
    
    //MARK: - Timer
    
    func handleTimerEvent(t: Timer) {
        seconds = seconds + 1
        let hour = seconds/3600
        let minute = seconds%3600/60
        let second = seconds%60
        if self.delegate != nil {
            self.delegate?.timerStrUpdate(timeStr:String.init(format: "%02d:%02d:%02d", hour, minute, second))
        }
    }
    
    func saveMaskUseData() {
        SessionManager.sharedInstance.userMaskConfig.saveMaskUseHistory(usetime: seconds, distance: totalDistance, step: totalSteps, calories: totalCarlories)
    }
}
