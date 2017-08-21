//
//  StringExtension.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/7.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

extension String {

    func validPhoneNum() -> Bool {
        
        let str = self.replacingOccurrences(of: " ", with: "")
        if str.characters.count != 11 {
            return false
        }
        if !str.characters.starts(with: ["1"]) {
            return false
        }
        return true
    }
    
    func trip() -> String {
        var newStr = self.replacingOccurrences(of: " ", with: "")
        newStr = newStr.replacingOccurrences(of: "-", with: "")
        return newStr
    }
    
    
    /// 转换成以 BLS 开头的 url
    ///
    /// - Returns: url
    func urlStringWithBLS() -> String {
        
        if !self.hasPrefix("http://") {
            if self.hasPrefix("/") {
                return baseURL+self
            }
            return baseURL+"/"+self
        }
        return self
    }
}


