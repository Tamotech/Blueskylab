//
//  CheckUpdateViewController.swift
//  Summer
//
//  Created by 武淅 段 on 2017/7/8.
//  Copyright © 2017年 wuxi. All rights reserved.
//

import UIKit
import SwiftyJSON

class CheckUpdateViewController: BaseViewController {

    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var newestVersionLabel: UILabel!
    
    @IBOutlet weak var checkUpdateBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.versionLabel.text = "V\(version ?? "1.0")"
        self.title = NSLocalizedString("APPUpdate", comment: "")
        checkUpdateBtn.layer.cornerRadius = 22
        checkUpdateBtn.layer.shadowColor = UIColor(ri: 92, gi: 141, bi: 181)?.cgColor
        checkUpdateBtn.layer.shadowRadius = 6
        checkUpdateBtn.layer.shadowOffset = CGSize(width: 0, height: 3)
        checkUpdateBtn.layer.shadowOpacity = 0.4
    }

  
    @IBAction func didTapCheckUpdateBtn(_ sender: UIButton) {
        let path = "http://itunes.apple.com/cn/lookup?id=12132"
        let url = URL(string: path)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            if data != nil {
                do {
                    let dic = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    print("checkoutUpdate----\(dic)")
                }
                catch let error {
                    print("checkUpdate error ------- \(error)")
                }
            }
        }
        dataTask.resume()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
