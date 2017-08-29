//
//  ArticleList.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/28.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import HandyJSON


class ArticleModel: HandyJSON {
    var id: String = ""
    var title: String = ""
    var description: String = ""
    var publishdate: Int = 0
    
    required init(){}
}

class ArticleList: HandyJSON {

    var total: Int = 0
    var page: Int = 0
    var rows: Int = 0
    var list: [ArticleModel] = []
    
    required init(){}
}
