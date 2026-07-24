//
//  Constants.swift
//  趣定向 (Swift 迁移版)
//
//  全局常量、配色、尺寸、URL 配置
//

import UIKit

// MARK: - 第三方 SDK Key
enum SDKKeys {
    static let wechat       = "wxd7bdc3ac4f2505fe"
    static let wechatSecret = "d4624c36b6795d1d99dcf0547af5443d"
    static let amap         = "deebe04a4a659c7c40eeeaad2e4b97cf"
    static let qq           = "1104830915"
}

// MARK: - 服务端地址
enum APIHost {
    static let base    = "https://www.qudingxiang.cn/qdx/"
    static let oldBase = "https://www.qudingxiang.cn/"
}

// MARK: - API 路径
enum APIPath {
    // 鉴权
    static let login            = "Home/Customer/login"
    static let authLogin        = "Home/Customer/authlogin"
    static let vcodeLogin       = "Home/Customer/vcodeLogin"
    static let qvLogin          = "Home/Customer/qvLogin"
    static let bind             = "Home/Customer/bind"
    static let getVcode         = "Home/Customer/getVcode"
    static let setVcode         = "Home/Customer/setVcode"
    static let validateCode     = "Home/Customer/validateCode"
    static let register         = "Home/Customer/register"
    static let modify           = "Home/Customer/modify"

    // 首页
    static let title            = "Home/Util/title"
    static let dbVersion        = "Home/util/Dbversion"
    static let help             = "Home/Util/help"
    static let portocol         = "Home/Util/portocol"
    static let getPlayimg       = "index.php/Home/Util/getPlayimg"

    // 城市 / 场地 / 合作
    static let getCity          = "Home/City/getList"
    static let getHotArea       = "Home/Area/getListHot"
    static let getArea          = "Home/Area/getList"
    static let getPartner       = "Home/Partner/getList"
    static let getGoods         = "Home/Goods/getList"
    static let newGoods         = "index.php/Home/Goods/GetHomeListAjax"
    static let getMatch         = "Home/Match/getList"
    static let getAction        = "Home/Action/getList"
    static let goodsIndex       = "Home/Goods/index"

    // 线路 / 门票
    static let getList          = "Home/Myline/getList"
    static let getTeamList      = "Home/Myline/getTeamList"
    static let getMyline        = "Home/Myline/getMyline"
    static let selectMyline     = "Home/Myline/selectMyline"
    static let getLineList      = "Home/Ticketline/getLineList"
    static let mineUrl          = "index.php/Home/Myline/getMyLineList"
    static let teamUrl          = "index.php/Home/Myline/getMyTeamLineList"
    static let areaUrl          = "index.php/Home/Line/getListAjax"
    static let lineInfoUrl      = "index.php/Home/Line/getInfoAjax"
    static let choiceUrl        = "index.php/Home/Myline/selectMyline"
    static let lineUrl          = "index.php/Home/Myline/getCurrentLine"
    static let ticketUrl        = "index.php/Home/Ticketline/getListByTicket"
    static let usingTicket      = "index.php/Home/Ticketinfo/getCurrentTicket"
    static let actUrl           = "index.php/Home/Ticketinfo/checkTicket"

    // 任务 / 游戏
    static let gameover         = "Home/Myline/gameover"
    static let taskRefresh      = "Home/Task/refresh"
    static let taskLocation     = "Home/Task/location"
    static let taskIndex        = "Home/Task/index"
    static let taskTask         = "Home/Task/task"
    static let history          = "Home/Task/history"
    static let pointhistory     = "Home/Task/pointhistory"
    static let toimg            = "Home/Cert/toimg"
    static let uploadHistory    = "index.php/Home/util/changpoint"
    static let loadDb           = "index.php/Home/util/loadDb"

    // 团队
    static let getTeam          = "Home/Team/getTeam"
    static let setTeam          = "Home/Team/setTeam"
    static let teamqrcode       = "Home/Team/teamqrcode"

    // 订单 / 支付
    static let ordersList       = "Home/Orders/getList"
    static let addOrders        = "Home/Orders/addOrders"
    static let removeOrders     = "Home/Orders/remove"
    static let ordersInfo       = "Home/Orders/getInfo"
    static let weixinPay        = "Home/Weixin/pay"
    static let alipayPay        = "Home/Alipay/pay"

    // 点标
    static let pointModify      = "Home/Point/modify"
    static let getPointList     = "Home/Point/getPointList"

    // 卡包 / 上传
    static let myCard           = "Home/Mycard/getList"
    static let uploadImage      = "Home/Upmfile/upfile"
}

// MARK: - 屏幕尺寸
enum Screen {
    static var width:  CGFloat { UIScreen.main.bounds.width }
    static var height: CGFloat { UIScreen.main.bounds.height }
    /// 安全区域
    static var safeAreaTop:    CGFloat {
        (UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.safeAreaInsets.top) ?? 20
    }
    static var safeAreaBottom: CGFloat {
        (UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.safeAreaInsets.bottom) ?? 0
    }
    static var statusBarHeight: CGFloat { safeAreaTop }
    static var tabBarHeight: CGFloat { 49 + safeAreaBottom }
    static var navBarHeight: CGFloat { 44 + safeAreaTop }

    /// 按 750 设计稿等比换算
    static func fit(_ value: CGFloat) -> CGFloat {
        value / 750.0 * width
    }
}

// MARK: - 主题配色
enum QDXColor {
    static let background = UIColor(hex: 0xF5F5F5)
    static let gray       = UIColor(hex: 0x666666)
    static let lightGray  = UIColor(hex: 0xD6D6D6)
    static let black      = UIColor(hex: 0x111111)
    static let blue       = UIColor(hex: 0x0099FD)
    static let darkBlue   = UIColor(hex: 0x0089E3)
    static let lightBlue  = UIColor(hex: 0x66C3FF)
    static let orange     = UIColor(hex: 0xFF5100)
    static let green      = UIColor(hex: 0x2FBD47)
    static let lineColor  = UIColor(hex: 0xE5E5E5)
    static let white      = UIColor.white

    /// 主题色（用于按钮、导航栏）
    static let primary    = blue
    static let accent     = orange
}

// MARK: - 字体
enum QDXFont {
    static func regular(_ size: CGFloat) -> UIFont {
        .systemFont(ofSize: Screen.fit(size), weight: .regular)
    }
    static func medium(_ size: CGFloat) -> UIFont {
        .systemFont(ofSize: Screen.fit(size), weight: .medium)
    }
    static func semibold(_ size: CGFloat) -> UIFont {
        .systemFont(ofSize: Screen.fit(size), weight: .semibold)
    }
    static func bold(_ size: CGFloat) -> UIFont {
        .systemFont(ofSize: Screen.fit(size), weight: .bold)
    }
}

// MARK: - 本地存储路径
enum QDXPath {
    static var caches: String {
        NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }
    static var documents: String {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    static let goods         = caches + "/QDXGoods.data"
    static let myline        = caches + "/QDXline.data"
    static let currentMyLine = caches + "/QDXCurrentMyLine.data"
    static let version       = documents + "/QDXVersion.data"
    static let account       = documents + "/XWLAccount.data"
}

// MARK: - UIColor 扩展
extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        self.init(
            red:   CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8)  / 255.0,
            blue:  CGFloat( hex & 0x0000FF)        / 255.0,
            alpha: alpha
        )
    }
}
