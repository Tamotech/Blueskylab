//
//  UserHandbookController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/30.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import Kingfisher

class UserHandbookController: BaseViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet var footerView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentContainer: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var bannerView: UIImageView!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var bannerTop: NSLayoutConstraint!
    
    
    ///常见问题  关于产品 关于售后数据源
    var questionsArr: ArticleList?
    var aboutProductArr: ArticleList?
    var aboutAfterSaleArr: ArticleList?
    
    var currentIndex: Int = 0
    
    var playerLayer = AVPlayerLayer()
    var player = AVPlayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        playerLayer.player = player
        playerLayer.frame = bannerView.bounds
        bannerView.layer.addSublayer(playerLayer)
        loadData()
        
        let nib = UINib(nibName: "AboutQACell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        tableView.tableFooterView = footerView
        
        self.title = NSLocalizedString("UserHandbook", comment:"")
        
        let segment = BaseSegmentControl(items: [NSLocalizedString("CommenQuestions", comment: ""), NSLocalizedString("AboutProduct", comment: ""), NSLocalizedString("AboutAfterSale", comment: "")], defaultIndex: 0)
        segment.bottom = segment.bottom
        segmentContainer.addSubview(segment)
        segment.selectItemAction = {[weak self](index:Int, item: String) in
            
            self?.currentIndex = index
            self?.tableView.reloadData()
        }
    }
    
    
    
    
    /// 拉去数据  视频地址  文章列表
    func loadData() {
        APIRequest.getUserConfig(codes: "u_ug_video_preimg,u_ug_video,s_ug_kefu_email") { [weak self](JSONData) in
            let data = JSONData as! JSON
            let videoUrl = data["u_ug_video"]["v"].stringValue
            let thumUrl = data["u_ug_video_preimg"]["v"].stringValue
            let email = data["s_ug_kefu_email"]["v"].stringValue
            if thumUrl.characters.count > 0 {
                let rc = ImageResource(downloadURL: URL(string:thumUrl)!)
                self?.bannerView.kf.setImage(with: rc)
            }
            if videoUrl.characters.count > 0 {
                let item = AVPlayerItem(asset: AVURLAsset(url: URL(string: videoUrl)!))
                self?.player.replaceCurrentItem(with: item)
                print("complete set player \(videoUrl)")
            }
            
            self?.emailLabel.text = email
        }
        
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        APIRequest.getArticleList(channelId: 8, page: 1, rows: 10) {
            [weak self] (data) in
            MBProgressHUD.hide(for: (self?.view)!, animated: true)
            self?.questionsArr = data as? ArticleList
            self?.tableView.reloadData()
        }
        
        APIRequest.getArticleList(channelId: 9, page: 1, rows: 10) { [weak self] (data) in
            self?.aboutProductArr = data as? ArticleList
        }
        
        APIRequest.getArticleList(channelId: 10, page: 1, rows: 10) { [weak self] (data) in
            self?.aboutAfterSaleArr = data as? ArticleList
        }
        
    }

    
    
    //MARK: - tableView 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = self.getCurrentData() else {
            return 0
        }
        return data.list.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AboutQACell
        let article = self.getCurrentData()!.list[indexPath.row]
        cell.updateCell(data: article)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = self.getCurrentData()?.list[indexPath.row]
        let vc = ArticleDetailController()
        vc.articleId = article?.id ?? ""
        vc.showCustomTitle(title: article?.title ?? "")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        if offset.y > 0 && offset.y < bannerView.height {
            //banner 上划
            bannerTop.constant = 64-offset.y
        }
        else if offset.y > bannerView.height {
            bannerTop.constant = 64-bannerView.height
        }
        else if offset.y < 0 {
            bannerTop.constant = 64
        }
    }
    
    @IBAction func handleTapPlayButton(_ sender: UIButton) {
        
        if player.currentItem != nil {
            playButton.isHidden = true
            player.play()
        }
    }

    
    func getCurrentData() -> ArticleList? {
        switch currentIndex {
        case 0:
            return questionsArr
        case 1:
            return aboutProductArr
        case 2:
            return aboutAfterSaleArr
        default:
            return nil
        }
    }
}
