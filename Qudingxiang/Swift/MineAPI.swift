//
//  MineAPI.swift
//  趣定向 (Swift 迁移版)
//
//  我的模块 API：用户信息修改、卡包、我的线路、团队线路
//

import Foundation

// MARK: - 我的线路
struct Myline: Codable {
    var id:        String?  // myline_id
    var lineID:    String?  // line_id
    var lineCn:    String?  // line_cn
    var customerID: String? // customer_id
    var customerCn: String? // customer_cn
    var statusID:  String?  // mylinest_id
    var statusCn:  String?  // mylinest_cn
    var adate:     String?  // myline_adate
    var score:     String?  // myline_score
    var ms:        String?  // myline_ms
    var team:      String?  // myline_team
    var group:     String?  // myline_group
    var preview:   String?  // myline_preview
    var print:     String?  // myline_print

    init(from dict: [String: Any]) {
        id         = dict["myline_id"]      as? String
        lineID     = dict["line_id"]        as? String
        lineCn     = dict["line_cn"]        as? String
        customerID = dict["customer_id"]    as? String
        customerCn = dict["customer_cn"]    as? String
        statusID   = dict["mylinest_id"]    as? String
        statusCn   = dict["mylinest_cn"]    as? String
        adate      = dict["myline_adate"]   as? String
        score      = dict["myline_score"]   as? String
        ms         = dict["myline_ms"]      as? String
        team       = dict["myline_team"]    as? String
        group      = dict["myline_group"]   as? String
        preview    = dict["myline_preview"] as? String
        print      = dict["myline_print"]   as? String
    }
}

// MARK: - 我的卡包
struct Card: Codable {
    var customerID: String?  // customer_id
    var cdate:      String?  // mycard_cdate
    var cn:         String?  // mycard_cn
    var id:         String?  // mycard_id
    var qrcode:     String?  // mycard_qrcode
    var url:        String?  // mycard_url
    var vdate:      String?  // mycard_vdate
    var onoffID:    String?  // onoff_id

    init(from dict: [String: Any]) {
        customerID = dict["customer_id"]   as? String
        cdate      = dict["mycard_cdate"]  as? String
        cn         = dict["mycard_cn"]     as? String
        id         = dict["mycard_id"]     as? String
        qrcode     = dict["mycard_qrcode"] as? String
        url        = dict["mycard_url"]    as? String
        vdate      = dict["mycard_vdate"]  as? String
        onoffID    = dict["onoff_id"]      as? String
    }
}

// MARK: - API
enum MineAPI {
    /// 自动登录 / 刷新用户信息
    static func authLogin(completion: @escaping (Result<Customer, APIError>) -> Void) {
        guard let token = AccountManager.shared.token else {
            completion(.failure(.business(code: 0, message: "未登录")))
            return
        }
        NetworkService.shared.requestJSON(
            path: APIPath.authLogin, parameters: ["customer_token": token], needToken: false
        ) { result in
            switch result {
            case .success(let dict):
                if (dict["Code"] as? Int) == 1, let msg = dict["Msg"] as? [String: Any] {
                    let c = Customer(from: msg)
                    AccountManager.shared.save(c)
                    completion(.success(c))
                } else {
                    AccountManager.shared.clear()
                    completion(.failure(.business(code: 0, message: "登录已失效")))
                }
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }

    /// 修改用户资料
    static func modify(params: [String: String],
                       completion: @escaping (Result<Customer, APIError>) -> Void) {
        NetworkService.shared.requestJSON(path: APIPath.modify, parameters: params) { result in
            switch result {
            case .success(let dict):
                if (dict["Code"] as? Int) == 1, let msg = dict["Msg"] as? [String: Any] {
                    let c = Customer(from: msg)
                    AccountManager.shared.save(c)
                    completion(.success(c))
                } else {
                    completion(.failure(.business(
                        code: dict["Code"] as? Int ?? -1,
                        message: (dict["Msg"] as? String) ?? "修改失败"
                    )))
                }
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }

    /// 我的线路列表
    static func myLines(completion: @escaping (Result<[Myline], APIError>) -> Void) {
        NetworkService.shared.requestJSON(path: APIPath.mineUrl) { result in
            switch result {
            case .success(let dict):
                let arr = (dict["Msg"] as? [[String: Any]]) ?? []
                completion(.success(arr.map { Myline(from: $0) }))
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }

    /// 团队线路列表
    static func teamLines(completion: @escaping (Result<[Myline], APIError>) -> Void) {
        NetworkService.shared.requestJSON(path: APIPath.teamUrl) { result in
            switch result {
            case .success(let dict):
                let arr = (dict["Msg"] as? [[String: Any]]) ?? []
                completion(.success(arr.map { Myline(from: $0) }))
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }

    /// 我的卡包
    static func cards(completion: @escaping (Result<[Card], APIError>) -> Void) {
        NetworkService.shared.requestJSON(path: APIPath.myCard) { result in
            switch result {
            case .success(let dict):
                let arr = (dict["Msg"] as? [[String: Any]]) ?? []
                completion(.success(arr.map { Card(from: $0) }))
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }
}
