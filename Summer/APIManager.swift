//
//  APIManager.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/7.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

class APIManager: NSObject {

    
    static let shareInstance:APIManager = APIManager()
    let baseUrl:String = "http://www.blueskylab.cn"
    
    
    //MARK: - request
    
    func getRequest(urlString: String, params: [String: Any]?, result: @escaping(_ resultObject: JSON?, _ code: Int, _ msg: String) -> ()) {
        
        var url = urlString
        if !urlString.hasPrefix("http") {
            url = baseUrl+urlString
        }
        
        let headers: HTTPHeaders = [
            "device": "app"
        ]
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            
            if let value = response.result.value {
                let resultDic = JSON(value)
//                let data = resultDic["data"]
//                let success = resultDic["success"]
//                let id = resultDic["id"]
                let num = resultDic["num"]
                let info = resultDic["info"]
                
                result(resultDic, num.intValue, info.stringValue)
            }
            else {
                result(nil, -2222, "网络请求失败!")
            }
        }
    }
    
    

}
