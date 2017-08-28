//
//  AboutQACell.swift
//  Summer
//
//  Created by 武淅 段 on 2017/8/28.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit

class AboutQACell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var readMoreView: UIView!
    
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateCell(data: ArticleModel) {
        titleLabel.text = data.title
//        contentLabel.text = data.description
        
        let para = NSMutableParagraphStyle()
        para.lineSpacing = 8
        let attr = [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0),
                    NSForegroundColorAttributeName: UIColor(ri: 48, gi: 48, bi: 48)!,
        NSParagraphStyleAttributeName: para] as [String: Any]
        
        
        //计算 title 一行或两行
        let contentHeight1 = titleLabel.sizeThatFits(CGSize(width: titleLabel.width, height: 1000)).height
        let lines1 = contentHeight1/titleLabel.font.lineHeight
        if lines1 > 1 {
            titleHeight.constant = 44
        }
        else {
            titleHeight.constant = 20
        }
        
        var content = data.description
        contentLabel.attributedText = NSAttributedString(string: content, attributes: attr)
        //如果大于5行显示阅读全文
        let contentHeight = contentLabel.sizeThatFits(CGSize(width: contentLabel.width, height: 1000)).height
        let lines = contentHeight/contentLabel.font.lineHeight
        if lines >= 5 {
            readMoreView.isHidden = false
            content = content.substring(to: content.index(content.endIndex, offsetBy: -20))+"......"
        }
        else {
            readMoreView.isHidden = true
        }
        contentLabel.attributedText = NSAttributedString(string: content, attributes: attr)
        
    }
    
}
