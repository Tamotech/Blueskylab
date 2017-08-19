//
//  ProgressHUD.swift
//  BiaoGeMusic
//
//  Created by ljy-335 on 14-10-21.
//  Copyright (c) 2014年 uni2uni. All rights reserved.
//

import Foundation
import UIKit

///
/// @brief 样式
enum HYBProgressHUDStyle {
    case BlackHUDStyle /// 黑色风格
    case WhiteHUDStyle /// 白色风格
}

///
/// @brief 定制显示通知的视图HUD
/// @author huangyibiao
class WXProgressHUD: UIView {
    var hud: UIToolbar?
    var spinner: UIActivityIndicatorView?
    var imageView: UIImageView?
    var titleLabel: UILabel?
    
    ///
    /// private 属性
    ///
    private let statusFont = UIFont.boldSystemFont(ofSize: 16)
    private var statusColor: UIColor!
    private var spinnerColor: UIColor!
    private var bgColor: UIColor!
    private var successImage: UIImage!
    private var errorImage: UIImage!
    
    ///
    /// @brief 单例方法，只允许内部调用
    
    private static let sharedInstance: WXProgressHUD = WXProgressHUD()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        hud = nil
        spinner = nil
        imageView = nil
        titleLabel = nil
        self.alpha = 0.0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///
    /// 公开方法
    ///
    
    /// 显示信息
    class func show(status: String) {
        sharedInstance.configureHUD(status: status, image: nil, isSpin: true, isHide: false)
    }
    
    /// 显示成功信息
    class func showSuccess(status: String) {
        sharedInstance.configureHUD(status: status, image: sharedInstance.successImage, isSpin: false, isHide: true)
    }
    
    /// 显示出错信息
    class func showError(status: String) {
        sharedInstance.configureHUD(status: status, image: sharedInstance.errorImage, isSpin: false, isHide: true)
    }
    
    /// 隐藏
    class func dismiss() {
        sharedInstance.hideHUD()
    }
    
    ///
    /// 私有方法
    ///
    
    ///
    /// @brief 创建并配置HUD
    private func configureHUD(status: String?, image: UIImage?, isSpin: Bool, isHide: Bool) {
        configureProgressHUD()
        
        /// 标题
        if status == nil {
            titleLabel!.isHidden = true
        } else {
            titleLabel!.text = status!
            titleLabel!.isHidden = false
        }
        // 图片
        if image == nil {
            imageView?.isHidden = true
        } else {
            imageView?.isHidden = false
            imageView?.image = image
        }
        
        // spin
        if isSpin {
            spinner?.startAnimating()
        } else {
            spinner?.stopAnimating()
        }
        rotate(sender: nil)
        addjustSize()
        showHUD()
        
        if isHide {
            Thread.detachNewThreadSelector(#selector(hideWhenTimeout), toTarget: self, with: nil)
        }
    }
    
    ///
    /// @brief 设置风格样式，默认使用的是黑色的风格，如果需要改成白色的风格，请在内部修改样式
    private func setStyle(style: HYBProgressHUDStyle) {
        switch style {
        case .BlackHUDStyle:
            statusColor = UIColor.white
            spinnerColor = UIColor.white
            bgColor = UIColor(white: 0, alpha: 0.8)
            successImage = UIImage(named: "ProgressHUD.bundle/success-white.png")
            errorImage = UIImage(named: "ProgressHUD.bundle/error-white.png")
            break
        case .WhiteHUDStyle:
            statusColor = UIColor.white
            spinnerColor = UIColor.white
            bgColor = UIColor(red: 192.0 / 255.0, green: 37.0 / 255.0, blue: 62.0 / 255.0, alpha: 1.0)
            successImage = UIImage(named: "ProgressHUD.bundle/success-white.png")
            errorImage = UIImage(named: "ProgressHUD.bundle/error-white.png")
            break
        default:
            break
        }
    }
    
    ///
    /// @brief 获取窗口window
    private func getWindow() ->UIWindow {
        if let delegate: UIApplicationDelegate = UIApplication.shared.delegate {
            if let window = delegate.window {
                return window!
            }
        }
        
        return UIApplication.shared.keyWindow!
    }
    
    ///
    /// @brief 创建HUD
    private func configureProgressHUD() {
        if hud == nil {
            hud = UIToolbar(frame: .zero)
            hud?.barTintColor = bgColor
            hud?.isTranslucent = true
            hud?.layer.cornerRadius = 10
            hud?.layer.masksToBounds = true
            
            /// 监听设置方向变化
            NotificationCenter.default.addObserver(self,
                                                           selector: #selector(rotate(sender:)),
                                                             name: NSNotification.Name.UIDeviceOrientationDidChange,
                                                             object: nil)
        }
        
        if hud!.superview == nil {
            getWindow().addSubview(hud!)
        }
        
        if spinner == nil {
            spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            spinner!.color = spinnerColor
            spinner!.hidesWhenStopped = true
        }
        
        if spinner!.superview == nil {
            hud!.addSubview(spinner!)
        }
        
        if imageView == nil {
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        }
        
        if imageView!.superview == nil {
            hud!.addSubview(imageView!)
        }
        
        if titleLabel == nil {
            titleLabel = UILabel(frame: .zero)
            titleLabel?.backgroundColor = UIColor.clear
            titleLabel?.font = statusFont
            titleLabel?.textColor = statusColor
            titleLabel?.baselineAdjustment = UIBaselineAdjustment.alignCenters
            titleLabel?.numberOfLines = 0
            titleLabel?.textAlignment = NSTextAlignment.center
            titleLabel?.adjustsFontSizeToFitWidth = false
        }
        
        if titleLabel!.superview == nil {
            hud!.addSubview(titleLabel!)
        }
    }
    
    ///
    /// @brief 释放资源
    private func destroyProgressHUD() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        titleLabel?.removeFromSuperview()
        titleLabel = nil
        
        spinner?.removeFromSuperview()
        spinner = nil
        
        imageView?.removeFromSuperview()
        imageView = nil
        
        hud?.removeFromSuperview()
        hud = nil
    }
    
    ///
    /// @brief 设置方向变化通知处理
    func rotate(sender: NSNotification?) {
        var rotation: CGFloat = 0.0
        switch UIApplication.shared.statusBarOrientation {
        case UIInterfaceOrientation.portrait:
            rotation = 0.0
            break
        case .portraitUpsideDown:
            rotation = CGFloat(Double.pi)
            break
        case .landscapeLeft:
            rotation = -CGFloat(Double.pi/2)
            break
        case .landscapeRight:
            rotation = CGFloat(Double.pi/2)
            break
        default:
            break
        }
        
        hud?.transform = CGAffineTransform.init(rotationAngle: rotation)
    }
    
    ///
    /// @brief 调整大小
    private func addjustSize() {
        var rect = CGRect.zero
        var width: CGFloat = 100.0
        var height: CGFloat = 100.0
        
        /// 计算文本大小
        if titleLabel!.text != nil {
            var style = NSMutableParagraphStyle()
            style.lineBreakMode = NSLineBreakMode.byCharWrapping
            var attributes = [NSFontAttributeName: statusFont, NSParagraphStyleAttributeName: style.copy()]
            var option = NSStringDrawingOptions.usesLineFragmentOrigin
            var text: NSString = NSString(cString: titleLabel!.text!, encoding: String.Encoding.utf8.rawValue)!
            rect = text.boundingRect(with: CGSize(width: 160, height: 260), options: option, attributes: attributes, context: nil)
            rect.origin.x = 12
            rect.origin.y = 66
            
            width = rect.size.width + 24
            height = rect.size.height + 80
            
            if width < 100 {
                width = 100
                rect.origin.x = 0
                rect.size.width = 100
            }
        }
        hud!.center = CGPoint(x: screenWidth/2, y: screenHeight/2)
        hud!.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let h = titleLabel!.text == nil ? height / 2 : 36
        imageView!.center = CGPoint(x: width / 2, y: h)
        spinner!.center = CGPoint(x: width / 2, y: h)
        
        titleLabel!.frame = rect
    }
    
    ///
    /// @brief 显示
    private func showHUD() {
        if self.alpha == 0.0 {
            self.alpha = 1.0
            
            hud!.alpha  = 0.0
            self.hud!.transform = self.hud!.transform.scaledBy(x: 1.4, y: 1.4)
            UIView.animate(withDuration: 0.15, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                self.hud!.transform = self.hud!.transform.scaledBy(x: 1.0/1.4, y: 1.0/1.4)
                self.hud!.alpha = 1.0
            }, completion: { (success) in
                
            })
        }
    }
    
    ///
    /// @brief 隐藏
    private func hideHUD() {
        if self.alpha == 1.0 {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                self.hud!.transform = self.hud!.transform.scaledBy(x: 0.35, y: 0.35)
                self.hud!.alpha = 0.0
            }, completion: { (success) in
                self.destroyProgressHUD()
                self.alpha = 0.0
            })
        }
    }
    
    ///
    /// @brief 在指定时间内隐藏
    func hideWhenTimeout() {
        autoreleasepool { () -> () in
            let length = self.titleLabel?.text?.characters.count
            let sleepTime: TimeInterval = TimeInterval(exactly: length!)!*0.04+0.5
            Thread.sleep(forTimeInterval: sleepTime)
            self.hideHUD()
        }
    }
}
