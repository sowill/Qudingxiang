//
//  OrderAPI.swift
//  趣定向 (Swift 迁移版)
//
//  订单与支付相关 API 封装
//

import Foundation

// MARK: - 订单详情中的门票使用信息
struct OrderInfo: Codable {
    var id:       String?  // ordersinfo_id
    var cn:       String?  // ordersinfo_cn 单号
    var ordersID: String?  // orders_id
    var ordersCn: String?  // orders_cn
    var udate:    String?  // ordersinfo_udate 使用时间
    var statusID: String?  // ordersinfost_id
    var statusCn: String?  // ordersinfost_cn
    var qrcode:   String?  // 二维码全路径

    enum CodingKeys: String, CodingKey {
        case id       = "ordersinfo_id"
        case cn       = "ordersinfo_cn"
        case ordersID = "orders_id"
        case ordersCn = "orders_cn"
        case udate    = "ordersinfo_udate"
        case statusID = "ordersinfost_id"
        case statusCn = "ordersinfost_cn"
        case qrcode   = "qrcode"
    }
}

// MARK: - 微信支付参数
struct WeixinPayParam: Codable {
    var appid:     String?
    var noncestr:  String?
    var partnerid: String?
    var prepayid:  String?
    var sign:      String?
    var timestamp: String?
    var package:   String?
}

// MARK: - 支付宝支付参数
struct AlipayParam: Codable {
    var partner:    String?
    var privateKey: String?
    var seller:     String?
    var notify:     String?
}

// MARK: - 订单 API
enum OrderAPI {
    /// 订单列表（按状态过滤）
    /// status: 0=全部 1=待支付 2=已支付 3=已完成
    static func list(status: Int,
                     completion: @escaping (Result<[Orders], APIError>) -> Void) {
        NetworkService.shared.requestJSON(path: APIPath.ordersList) { result in
            switch result {
            case .success(let dict):
                // 后端结构：{ Code, Msg: [ {orders: [...], ticketinfo: [...]}, ... ] }
                // 兼容多种结构
                var list: [Orders] = []
                if let arr = dict["Msg"] as? [[String: Any]] {
                    for item in arr {
                        if let orders = item["orders"] as? [[String: Any]] {
                            list += orders.compactMap { Orders(from: $0) }
                        } else {
                            if let o = Orders(from: item as? [String: Any]) { list.append(o) }
                        }
                    }
                }
                // 状态过滤
                if status != 0 {
                    list = list.filter { ($0.statusID ?? "0") == String(status) }
                }
                completion(.success(list))
            case .failure:
                // 请求不到时返回默认空列表
                completion(.success([]))
            }
        }
    }

    /// 添加 / 减少订单（购物车）
    static func add(goodsID: String, add: Bool,
                    completion: @escaping (Result<EmptyMsg, APIError>) -> Void) {
        NetworkService.shared.request(
            path: APIPath.addOrders,
            parameters: ["goods_id": goodsID, "add": add ? "1" : "0"],
            completion: completion
        )
    }

    /// 删除订单
    static func remove(orderID: String,
                       completion: @escaping (Result<EmptyMsg, APIError>) -> Void) {
        NetworkService.shared.request(
            path: APIPath.removeOrders,
            parameters: ["orders_id": orderID],
            completion: completion
        )
    }

    /// 订单详情（含门票使用信息）
    static func detail(orderID: String,
                       completion: @escaping (Result<[OrderInfo], APIError>) -> Void) {
        NetworkService.shared.requestJSON(path: APIPath.ordersInfo, parameters: ["orders_id": orderID]) { result in
            switch result {
            case .success(let dict):
                let list = (dict["Msg"] as? [[String: Any]])?.compactMap { OrderInfo(from: $0) } ?? []
                completion(.success(list))
            case .failure:
                // 请求不到时返回默认空列表
                completion(.success([]))
            }
        }
    }

    /// 拉起微信支付参数
    static func wechatPay(orderID: String,
                          completion: @escaping (Result<WeixinPayParam, APIError>) -> Void) {
        NetworkService.shared.requestJSON(
            path: APIPath.weixinPay, parameters: ["orders_id": orderID]
        ) { result in
            switch result {
            case .success(let dict):
                if let msg = dict["Msg"] as? [String: Any],
                   let data = try? JSONSerialization.data(withJSONObject: msg),
                   let param = try? JSONDecoder().decode(WeixinPayParam.self, from: data) {
                    completion(.success(param))
                } else {
                    completion(.failure(.invalidResponse))
                }
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }

    /// 拉起支付宝参数
    static func alipay(orderID: String,
                       completion: @escaping (Result<AlipayParam, APIError>) -> Void) {
        NetworkService.shared.requestJSON(
            path: APIPath.alipayPay, parameters: ["orders_id": orderID]
        ) { result in
            switch result {
            case .success(let dict):
                if let msg = dict["Msg"] as? [String: Any],
                   let data = try? JSONSerialization.data(withJSONObject: msg),
                   let param = try? JSONDecoder().decode(AlipayParam.self, from: data) {
                    completion(.success(param))
                } else {
                    completion(.failure(.invalidResponse))
                }
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }
}

// Orders 从字典构造（API 返回结构不固定）
extension Orders {
    init(from dict: [String: Any]) {
        id         = dict["orders_id"]        as? String
        cn         = dict["orders_cn"]        as? String
        customerID = dict["customer_id"]      as? String
        customerCn = dict["customer_cn"]      as? String
        goodsID    = dict["goods_id"]         as? String
        goodsCn    = dict["goods_cn"]         as? String
        cdate      = dict["orders_cdate"]     as? String
        quantity   = dict["orders_quantity"]  as? String
        amount     = dict["orders_am"]        as? String
        account    = dict["orders_account"]   as? String
        statusID   = dict["ordersst_id"]      as? String
        statusCn   = dict["ordersst_cn"]      as? String
        payID      = dict["orderspay_id"]     as? String
        payCn      = dict["orderspay_cn"]     as? String
        goodsURL   = dict["goods_url"]        as? String
    }
    init?(from dict: [String: Any]?) {
        guard let d = dict else { return nil }
        self.init(from: d)
    }
}

extension OrderInfo {
    init(from dict: [String: Any]) {
        id       = dict["ordersinfo_id"]    as? String
        cn       = dict["ordersinfo_cn"]    as? String
        ordersID = dict["orders_id"]        as? String
        ordersCn = dict["orders_cn"]        as? String
        udate    = dict["ordersinfo_udate"] as? String
        statusID = dict["ordersinfost_id"]  as? String
        statusCn = dict["ordersinfost_cn"]  as? String
        qrcode   = dict["qrcode"]           as? String
    }
    init?(from dict: [String: Any]?) {
        guard let d = dict else { return nil }
        self.init(from: d)
    }
}
