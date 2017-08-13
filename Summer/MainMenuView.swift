//
//  MainMenuView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/6/19.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

enum ItemType {
    case ItemUser
    case ItemGuide
    case ItemShare
    case ItemSetting
    case ItemBuyFilter
    case ItemBuyMask
    case ItemMyEquipment
    case ItemNone
}

typealias tapMenuAction = (ItemType) -> ()

class MainMenuView: BaseView {
    
    var tapMunueCallback:tapMenuAction?
    
    override func awakeFromNib() {
        self.frame = UIScreen.main.bounds
    }
    
    
    
    //MARK: tapGesture
    @IBAction func handleTapItem(_ sender: UITapGestureRecognizer) {
        print(sender.view!.tag)
        
        var item:ItemType! = .ItemNone
        switch sender.view!.tag {
        case 1:
            item = .ItemUser
            break
        case 2:
            item = .ItemGuide
            break
        case 3:
            item = .ItemShare
            break
        case 4:
            item = .ItemSetting
            break
        case 5:
            item = .ItemBuyFilter
            break
        case 6:
            item = .ItemBuyMask
            break
        default:
            break
        }
        
        if self.tapMunueCallback != nil {
            self.tapMunueCallback!(item)
        }
    }
    
    @IBAction func handleTapEquipmentBtn(_ sender: Any) {
        
        if self.tapMunueCallback != nil {
            self.tapMunueCallback!(.ItemMyEquipment)
        }
    }
    
    
    
}
