import UIKit


//var language = ""
class LanguageHelper: NSObject {
    
    //单例
    static let shareInstance = LanguageHelper()
    
    let def = UserDefaults.standard
    var bundle : Bundle?
    var language = "zh_CN"
    
    ///根据用户设置的语言类型获取字符串
    func getUserStr(key: String) -> String
    {
        // 获取本地化字符串，字符串根据手机系统语言自动切换
        let str = NSLocalizedString(key, comment: "default")
        return str
    }
    ///根据app内部设置的语言类型获取字符串
    func getAppStr(key: String) -> String
    {
        // 获取本地化字符串，字符串会根据app系统语言自动切换
        let str = NSLocalizedString(key, tableName: "Localizable", bundle: LanguageHelper.shareInstance.bundle!, value: "default", comment: "default")
        return str
    }
    
    ///设置app语言环境
    func setLanguage(langeuage: String) {
        var str = langeuage
        var appLanguage = "zh_CN"
        //如果获取不到系统语言，就把app语言设置为首选语言
        if langeuage == "" {
            //获取系统首选语言顺序
            let languages:[String] = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]
            let str2:String = languages[0]
            //如果首选语言是中文，则设置APP语言为中文，否则设置成英文
            if ((str2=="zh-Hans-CN")||(str2=="zh-Hans"))
            {
                str = "zh-Hans"
                appLanguage = "zh_CN"
            }
            else if str2 == "zh-Hant-HK" || str2 == "zh-Hant"
            {
                str = "zh-Hant-HK"
                appLanguage = "zh_TW"
            }
            else
            {
                str="en"
                appLanguage = "en_US"
            }
            
        }
        
        self.language = appLanguage
        SessionManager.sharedInstance.changeLanguage(language: appLanguage)
        
        //语言设置
        def.set(str, forKey: "language")
        def.synchronize()
        //根据str获取语言数据（因为设置了本地化，所以项目中有en.lproj和zn-Hans.lproj）
        let path = Bundle.main.path(forResource:str , ofType: "lproj")
        bundle = Bundle(path: path!)
        Bundle.main.onLanguage()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LanguageChanged"), object: nil)
        
    }
}
