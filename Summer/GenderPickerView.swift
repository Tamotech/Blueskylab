//
//  GenderPickerView.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/2.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

typealias FinishSelectGender = (String) -> ()
class GenderPickerView: BaseActionSheetView, UIPickerViewDelegate, UIPickerViewDataSource {

    
    var picker: UIPickerView = UIPickerView()
    var items: [String] = []
    var currentItem: String?
    var finishSelectGender: FinishSelectGender?
    
    init(title:String?, items: [String]) {
        super.init(customView: picker, titleString: NSLocalizedString("SelectGender", comment: ""))
        self.items = items
        self.currentItem = items.first
        self.picker.showsSelectionIndicator = true
        self.picker.delegate = self
        self.picker.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    //MARK: - UIPickerView
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let title = items[row]
        return title
    }
    
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        let title = items[row]
//        let color = row == pickerView.selectedRow(inComponent: 0) ? themeColor! : gray72!
//        let attrTitle = NSAttributedString(string: title, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 15),
//             NSForegroundColorAttributeName:color])
//        return attrTitle
//    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currentItem = self.items[row]
    }
    
    override func handleTapConfirmBtn(_: UIButton) {
        if self.finishSelectGender != nil {
            self.finishSelectGender!(currentItem!)
        }
        self.dismiss()
    }
}
