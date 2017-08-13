//
//  DatePickerView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/6/29.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

typealias PickDateHandler = (Date)->()

class DatePickerView: BaseActionSheetView {
    
    
    var pickDateAction: PickDateHandler?
    let picker: UIDatePicker! = UIDatePicker()
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(title: String?) {
        super.init(customView: picker, titleString: title)
        self.picker.datePickerMode = .date
        self.picker.tintColor = themeColor
    }

    override func handleTapConfirmBtn(_: UIButton) {
        if pickDateAction != nil {
            self.pickDateAction!(self.picker.date)
        }
        self.dismiss()
    }
}
