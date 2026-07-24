//
//  Models.swift
//  趣定向 (Swift 迁移版)
//
//  使用 Codable 替代 MJExtension，集中定义核心业务模型
//

import Foundation

/// 通用响应包装：服务端返回 { Code, Msg, Data }
struct APIResponse<T: Decodable>: Decodable {
    let code: Int
    let msg: T?

    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case msg  = "Msg"
    }
}

// MARK: - 用户
struct Customer: Codable {
    var id:           String?   // customer_id
    var cn:           String?   // customer_cn 名称
    var code:         String?   // customer_code 登录账号
    var pwd:          String?   // customer_pwd
    var token:        String?   // customer_token
    var qid:          String?   // customer_qid QQ 授权
    var wxid:         String?   // customer_wxid 微信授权
    var headURL:      String?   // customer_headurl
    var signature:    String?   // customer_signature
    var cdate:        String?   // customer_cdate
    var ldate:        String?   // customer_ldate
    var ipAddress:    String?   // customer_Ipaddress
    var vcode:        String?   // customer_vcode
    var address:      String?   // customer_address
    var level:        String?   // customer_level
    var areaID:       String?   // area_id

    enum CodingKeys: String, CodingKey {
        case id        = "customer_id"
        case cn        = "customer_cn"
        case code      = "customer_code"
        case pwd       = "customer_pwd"
        case token     = "customer_token"
        case qid       = "customer_qid"
        case wxid      = "customer_wxid"
        case headURL   = "customer_headurl"
        case signature = "customer_signature"
        case cdate     = "customer_cdate"
        case ldate     = "customer_ldate"
        case ipAddress = "customer_Ipaddress"
        case vcode     = "customer_vcode"
        case address   = "customer_address"
        case level     = "customer_level"
        case areaID    = "area_id"
    }

    /// 兼容旧 OC 调用风格的便捷构造
    init(from dict: [String: Any]) {
        self.init(from: dict as? [String: Any])
    }
    init(from dict: [String: Any]?) {
        let d = dict ?? [:]
        id        = d["customer_id"]        as? String
        cn        = d["customer_cn"]        as? String
        code      = d["customer_code"]      as? String
        pwd       = d["customer_pwd"]       as? String
        token     = d["customer_token"]     as? String
        qid       = d["customer_qid"]       as? String
        wxid      = d["customer_wxid"]      as? String
        headURL   = d["customer_headurl"]   as? String
        signature = d["customer_signature"] as? String
        cdate     = d["customer_cdate"]     as? String
        ldate     = d["customer_ldate"]     as? String
        ipAddress = d["customer_Ipaddress"] as? String
        vcode     = d["customer_vcode"]     as? String
        address   = d["customer_address"]   as? String
        level     = d["customer_level"]     as? String
        areaID    = d["area_id"]            as? String
    }
}

// MARK: - 产品 / 赛事活动
struct Goods: Codable {
    var id:        String?   // goods_id
    var cn:        String?   // goods_cn 名称
    var index:     String?   // goods_index 顺序
    var topShow:   String?   // goods_topshow 首页显示
    var onoffCn:   String?   // onoff_cn
    var statusID:  String?   // goodstatus_id
    var statusCn:  String?   // goodstatus_cn
    var price:     String?   // goods_price
    var url:       String?   // goods_url 图片
    var flag:      String?   // goods_flag 含门票
    var des:       String?   // goods_des 详情
    var notice:    String?   // goods_notice 须知
    var prompt:    String?   // goods_prompt 提示
    var time:      String?   // goods_time 时间
    var address:   String?   // goods_address 地点
    var lineID:    String?   // line_id
    var lineCn:    String?   // line_cn
    var preview:   String?   // goods_preview 浏览
    var cdate:     String?   // goods_cdate
    var typeID:    String?   // goodstype_id
    var typeCn:    String?   // goodstype_cn

    enum CodingKeys: String, CodingKey {
        case id       = "goods_id"
        case cn       = "goods_cn"
        case index    = "goods_index"
        case topShow  = "goods_topshow"
        case onoffCn  = "onoff_cn"
        case statusID = "goodstatus_id"
        case statusCn = "goodstatus_cn"
        case price    = "goods_price"
        case url      = "goods_url"
        case flag     = "goods_flag"
        case des      = "goods_des"
        case notice   = "goods_notice"
        case prompt   = "goods_prompt"
        case time     = "goods_time"
        case address  = "goods_address"
        case lineID   = "line_id"
        case lineCn   = "line_cn"
        case preview  = "goods_preview"
        case cdate    = "goods_cdate"
        case typeID   = "goodstype_id"
        case typeCn   = "goodstype_cn"
    }
}

// MARK: - 订单
struct Orders: Codable {
    var id:          String?  // orders_id
    var cn:          String?  // orders_cn 订单号
    var customerID:  String?  // customer_id
    var customerCn:  String?  // customer_cn
    var goodsID:     String?  // goods_id
    var goodsCn:     String?  // goods_cn
    var cdate:       String?  // orders_cdate 时间
    var quantity:    String?  // orders_quantity 数量
    var amount:      String?  // orders_am 应付
    var account:     String?  // orders_account 实付
    var statusID:    String?  // ordersst_id
    var statusCn:    String?  // ordersst_cn
    var payID:       String?  // orderspay_id
    var payCn:       String?  // orderspay_cn
    var goodsURL:    String?  // goods_url

    enum CodingKeys: String, CodingKey {
        case id         = "orders_id"
        case cn         = "orders_cn"
        case customerID = "customer_id"
        case customerCn = "customer_cn"
        case goodsID    = "goods_id"
        case goodsCn    = "goods_cn"
        case cdate      = "orders_cdate"
        case quantity   = "orders_quantity"
        case amount     = "orders_am"
        case account    = "orders_account"
        case statusID   = "ordersst_id"
        case statusCn   = "ordersst_cn"
        case payID      = "orderspay_id"
        case payCn      = "orderspay_cn"
        case goodsURL   = "goods_url"
    }
}

// MARK: - 线路
struct Line: Codable {
    var id:        String?  // line_id
    var cn:        String?  // line_cn 名称
    var typeID:    String?  // linetype_id
    var typeCn:    String?  // linetype_cn
    var number:    String?  // line_number 组队人数
    var pass:      String?  // line_pass 全员通过
    var qrcode:    String?  // line_qrcode 二维码有效
    var bind:      String?  // line_bind 手机绑定
    var mapOn:     String?  // line_mapon 地图显示
    var map:       String?  // line_map
    var topLon:    String?  // line_toplon
    var topLat:    String?  // line_toplat
    var botLon:    String?  // line_botlon
    var botLat:    String?  // line_botlat
    var page:      String?  // line_page
    var statusID:  String?  // utilstatus_id
    var cdate:     String?  // line_cdate
    var areaID:    String?  // area_id

    enum CodingKeys: String, CodingKey {
        case id       = "line_id"
        case cn       = "line_cn"
        case typeID   = "linetype_id"
        case typeCn   = "linetype_cn"
        case number   = "line_number"
        case pass     = "line_pass"
        case qrcode   = "line_qrcode"
        case bind     = "line_bind"
        case mapOn    = "line_mapon"
        case map      = "line_map"
        case topLon   = "line_toplon"
        case topLat   = "line_toplat"
        case botLon   = "line_botlon"
        case botLat   = "line_botlat"
        case page     = "line_page"
        case statusID = "utilstatus_id"
        case cdate    = "line_cdate"
        case areaID   = "area_id"
    }
}

// MARK: - 城市 / 场地 / 合作单位
struct City: Codable {
    var id: String?         // city_id
    var cn: String?         // city_cn
    var provinceID: String? // province_id
    var provinceCn: String? // province_cn
    var statusID: String?   // utilstatus_id
    var statusCn: String?   // utilstatus_cn

    enum CodingKeys: String, CodingKey {
        case id         = "city_id"
        case cn         = "city_cn"
        case provinceID = "province_id"
        case provinceCn = "province_cn"
        case statusID   = "utilstatus_id"
        case statusCn   = "utilstatus_cn"
    }
    init(from dict: [String: Any]) {
        id         = dict["city_id"]        as? String
        cn         = dict["city_cn"]        as? String
        provinceID = dict["province_id"]    as? String
        provinceCn = dict["province_cn"]    as? String
        statusID   = dict["utilstatus_id"]  as? String
        statusCn   = dict["utilstatus_cn"]  as? String
    }
    init?(from dict: [String: Any]?) {
        guard let d = dict else { return nil }
        self.init(from: d)
    }
}

struct Area: Codable {
    var id: String?          // area_id
    var cn: String?          // area_cn
    var type: String?        // area_type
    var provinceID: String?  // province_id
    var provinceCn: String?  // province_cn
    var cityID: String?      // city_id
    var cityCn: String?      // city_cn
    var countyID: String?    // county_id
    var countyCn: String?    // county_cn
    var url: String?         // area_url
    var vcode: String?       // area_vcode
    var cdate: String?       // area_cdate
    var sysuserID: String?   // sysuser_id
    var sysuserCn: String?   // sysuser_cn

    enum CodingKeys: String, CodingKey {
        case id         = "area_id"
        case cn         = "area_cn"
        case type       = "area_type"
        case provinceID = "province_id"
        case provinceCn = "province_cn"
        case cityID     = "city_id"
        case cityCn     = "city_cn"
        case countyID   = "county_id"
        case countyCn   = "county_cn"
        case url        = "area_url"
        case vcode      = "area_vcode"
        case cdate      = "area_cdate"
        case sysuserID  = "sysuser_id"
        case sysuserCn  = "sysuser_cn"
    }
    init(from dict: [String: Any]) {
        id         = dict["area_id"]       as? String
        cn         = dict["area_cn"]       as? String
        type       = dict["area_type"]     as? String
        provinceID = dict["province_id"]   as? String
        provinceCn = dict["province_cn"]   as? String
        cityID     = dict["city_id"]       as? String
        cityCn     = dict["city_cn"]       as? String
        countyID   = dict["county_id"]     as? String
        countyCn   = dict["county_cn"]     as? String
        url        = dict["area_url"]      as? String
        vcode      = dict["area_vcode"]    as? String
        cdate      = dict["area_cdate"]    as? String
        sysuserID  = dict["sysuser_id"]    as? String
        sysuserCn  = dict["sysuser_cn"]    as? String
    }
    init?(from dict: [String: Any]?) {
        guard let d = dict else { return nil }
        self.init(from: d)
    }
}

struct Partner: Codable {
    var id: String?  // partner_id
    var cn: String?  // partner_cn
    var url: String? // partner_logo
    enum CodingKeys: String, CodingKey {
        case id = "partner_id"; case cn = "partner_cn"; case url = "partner_logo"
    }
}

// MARK: - 首页 banner
struct Banner: Codable {
    var id:  String?  // playimg_id
    var url: String?  // playimg_url
    var link: String? // playimg_link
    enum CodingKeys: String, CodingKey {
        case id = "playimg_id"; case url = "playimg_url"; case link = "playimg_link"
    }
}

// MARK: - 分页列表响应
struct PagedList<T> {
    let items: [T]
    let count: Int      // 总条数
    let allPage: Int    // 总页数
    let curr: Int       // 当前页
}

