//
//  Summer.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/7.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import Foundation
import Moya

let configuration = URLSessionConfiguration.default
configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders

let manager = Manager(configuration: configuration)
manager.startRequestsImmediately = false
return manager

let provider = MoyaProvider<Summer>(manager: manager)

public enum Summer {
    case login(name:String)
    case capture(name:String)
}


extension Summer: TargetType {

    public var baseURL: URL {
        return URL(string: "http://www.blueskylab.cn")!
    }
    
    public var path: String {
        return ""
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var parameters: [String : Any]? {
        return nil
    }
    
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    public var task: Task {
        return .request
    }
    
    public var validate: Bool {
        return true
    }
    
    
    public var sampleData: Data {
        switch self {
        case .login(let name):
            return "[{\"name\": \(name)}]".data(using: String.Encoding.utf8)!
        default:
            return Data()
        }
        
    }
    
}
