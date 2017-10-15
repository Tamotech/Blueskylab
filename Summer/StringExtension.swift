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
    
    /// 从字符串中提取 整数数字
    func getIntFromString() -> Int {
        let scanner = Scanner(string: self)
        scanner.scanUpToCharacters(from: CharacterSet.decimalDigits, into: nil)
        var number :Int = 0
        
        scanner.scanInt(&number)
        
        return number
    }
    
    /// 从字符串中提取浮点数数字
    func getFloatFromString() -> CGFloat {
        let scanner = Scanner(string: self)
        scanner.scanUpToCharacters(from: CharacterSet.decimalDigits, into: nil)
        var number : Float = 0
        
        scanner.scanFloat(&number)
        
        return CGFloat(number)
    }
    
    /// 比较版本号大小
    static func compareVersionString(first: String, second: String) -> Int {
        let l1 = first.components(separatedBy: ".")
        let l2 = second.components(separatedBy: ".")
        let c1 = l1.count
        let c2 = l2.count
        var min = c1
        if c2 < c1 {
            min = c2
        }
        for i in 0..<min {
            let j = Int(l1[i])!
            let k = Int(l2[i])!
            if j != k {
                return j - k
            }
        }
        if c1 != c2 {
            return c1 - c2
        }
        else {
            return 0
        }
        
    }
}


