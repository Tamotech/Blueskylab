//
//  NSBundle+Lanauage.swift
//  LocalDemo
//
//  Created by gongkai on 15/6/4.
//  Copyright (c) 2015年 gongkai. All rights reserved.
//

import Foundation

/**
 *  当调用onLanguage后替换掉mainBundle为当前语言的bundle
 */
class BundleEx: Bundle {
    
    
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = languageBundle() {
            return bundle.localizedString(forKey:key, value: value, table: tableName)
        }else{
            return super.localizedString(forKey:key, value: value, table: tableName)
        }
    }
}

extension Bundle{
    
    func onLanguage(){
        
        //替换NSBundle.mainBundle()为自定义的BundleEx
        let justOnce: AnyClass = {
            object_setClass(Bundle.main, BundleEx.self)
        }()
        let _ = justOnce
        
    }
    
    //当前语言的bundle
    func languageBundle()->Bundle?{
        return LanguageHelper.shareInstance.bundle
    }
}

