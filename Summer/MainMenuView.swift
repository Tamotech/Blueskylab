//
//  MainMenuView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/6/19.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftyJSON

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
    
    
    /// 口罩购买地址
    var maskBuyUrl: String?
    /// 滤芯购买地址
    var filterBuyUrl: String?
    /// App下载地址
    var appDownloadUrl: String?
    
    
    @IBOutlet weak var avatarBtn: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    
    
    
    override func awakeFromNib() {
        self.frame = UIScreen.main.bounds
        avatarBtn.imageView?.cornerRadius = 45
        avatarBtn.imageView?.clipsToBounds = true
        
        self.loadConfigData()
    }
    
    
    ///更新页面
    func updateView() {
        guard let userInfo = SessionManager.sharedInstance.userInfo else {
            return
        }
        
        let rc = ImageResource(downloadURL: URL(string: userInfo.headimg.urlStringWithBLS())!)
        avatarBtn.kf.setImage(with: rc, for: .normal, placeholder: #imageLiteral(resourceName: "imgProfile-M"), options: nil, progressBlock: nil, completionHandler: nil)
//        nameLabel.text = userInfo.name
        nameLabel.text = NSLocalizedString("MyAir", comment: "")
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
    
    @IBAction func handleTapAvatarButton(_ sender: UIButton) {
        if self.tapMunueCallback != nil {
            self.tapMunueCallback!(.ItemMyEquipment)
        }
    }
    
    @IBAction func handleTapEquipmentBtn(_ sender: Any) {
        
        if self.tapMunueCallback != nil {
            self.tapMunueCallback!(.ItemMyEquipment)
        }
    }
    
    
    func loadConfigData() {
        APIRequest.getUserConfig(codes: "u_buy_mask,u_buy_filter,u_app_download_page") { [weak self](JSONData) in
            let data = JSONData as! JSON
            self?.maskBuyUrl = data["u_buy_mask"]["v"].stringValue
            self?.filterBuyUrl = data["u_buy_mask"]["v"].stringValue
            self?.appDownloadUrl = data["u_app_download_page"]["v"].stringValue
            
        }
    }
    
}
