//
//  WindModeModel.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/10.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit


/// 送风量模式对象

enum WindMode {
    case WindModeDefault
    case WindModeIntelligent
    case WindModeWalk
    case WindModeSport
    case WindModeDrive
    case WindModeRest
    case WindModeAdd
}

class WindModeModel: NSObject {

    var mode: WindMode = .WindModeDefault
    
    class public func modeName(mode: WindMode) -> String {
        switch mode {
        case .WindModeDefault:
            return NSLocalizedString("Default", comment: "");
        case .WindModeAdd:
            return NSLocalizedString("Add", comment: "");
        case .WindModeIntelligent:
            return NSLocalizedString("Intelligence", comment: "");
        case .WindModeWalk:
            return NSLocalizedString("Walk", comment: "");
        case .WindModeDrive:
            return NSLocalizedString("Drive", comment: "");
        case .WindModeRest:
            return NSLocalizedString("Rest", comment: "");
        case .WindModeSport:
            return NSLocalizedString("Sport", comment: "");
        }
    }
    
    class public func modeIcon(mode: WindMode) -> UIImage {
        switch mode {
        case .WindModeDefault:
            return UIImage()
        case .WindModeAdd:
            return #imageLiteral(resourceName: "windModeAdd")
        case .WindModeIntelligent:
            return #imageLiteral(resourceName: "icon-net")
        case .WindModeWalk:
            return #imageLiteral(resourceName: "icon-walk")
        case .WindModeDrive:
            return #imageLiteral(resourceName: "icon-car")
        case .WindModeRest:
            return #imageLiteral(resourceName: "icon-ly")
        case .WindModeSport:
            return #imageLiteral(resourceName: "icon-run")
        }
    }
    
}
