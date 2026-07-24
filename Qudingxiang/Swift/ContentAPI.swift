//
//  ContentAPI.swift
//  趣定向 (Swift 迁移版)
//
//  活动与场地相关 API：城市、场地、活动、合作单位、产品详情、报名
//

import Foundation

enum ContentAPI {

    // MARK: - 城市列表
    static func cities(completion: @escaping (Result<[City], APIError>) -> Void) {
        NetworkService.shared.requestJSON(path: APIPath.getCity, needToken: false) { result in
            switch result {
            case .success(let dict):
                let list = (dict["Msg"] as? [[String: Any]])?.compactMap { City(from: $0) } ?? []
                completion(.success(list))
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }

    // MARK: - 热门场地
    static func hotAreas(completion: @escaping (Result<[Area], APIError>) -> Void) {
        NetworkService.shared.requestJSON(path: APIPath.getHotArea, needToken: false) { result in
            switch result {
            case .success(let dict):
                let list = (dict["Msg"] as? [[String: Any]])?.compactMap { Area(from: $0) } ?? []
                completion(.success(list))
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }

    // MARK: - 场地列表（按城市）
    static func areas(cityID: String,
                      completion: @escaping (Result<PagedList<Area>, APIError>) -> Void) {
        NetworkService.shared.requestJSON(
            path: APIPath.getArea, parameters: ["city_id": cityID], needToken: false
        ) { result in
            switch result {
            case .success(let dict):
                let arr = (dict["Msg"] as? [[String: Any]]) ?? []
                let items = arr.compactMap { Area(from: $0) }
                let paged = PagedList<Area>(
                    items: items,
                    count: Int((dict["count"] as? String) ?? "0") ?? 0,
                    allPage: Int((dict["allpage"] as? String) ?? "0") ?? 0,
                    curr: Int((dict["curr"] as? String) ?? "1") ?? 1
                )
                completion(.success(paged))
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }

    // MARK: - 合作单位
    static func partners(completion: @escaping (Result<[Partner], APIError>) -> Void) {
        NetworkService.shared.requestJSON(path: APIPath.getPartner, needToken: false) { result in
            switch result {
            case .success(let dict):
                let list = (dict["Msg"] as? [[String: Any]])?.compactMap {
                    Partner(id: $0["partner_id"] as? String,
                            cn: $0["partner_cn"] as? String,
                            url: $0["partner_logo"] as? String)
                } ?? []
                completion(.success(list))
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }

    // MARK: - 活动列表（赛事 / 活动，按状态过滤）
    /// type: 1=活动 2=赛事
    /// status: 1=近期 4=已完成
    static func activities(cityID: String, type: String, status: String,
                           completion: @escaping (Result<PagedList<Goods>, APIError>) -> Void) {
        let path = (type == "2") ? APIPath.getMatch : APIPath.getAction
        NetworkService.shared.requestJSON(
            path: path,
            parameters: ["city_id": cityID, "goodstatus_id": status],
            needToken: false
        ) { result in
            switch result {
            case .success(let dict):
                let arr = (dict["Msg"] as? [[String: Any]]) ?? []
                let items = arr.compactMap { Goods(from: $0) }
                let paged = PagedList<Goods>(
                    items: items,
                    count: Int((dict["count"] as? String) ?? "0") ?? 0,
                    allPage: Int((dict["allpage"] as? String) ?? "0") ?? 0,
                    curr: Int((dict["curr"] as? String) ?? "1") ?? 1
                )
                completion(.success(paged))
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }

    // MARK: - 场地产品列表（按场地）
    static func goodsByArea(areaID: String,
                            completion: @escaping (Result<[Goods], APIError>) -> Void) {
        NetworkService.shared.requestJSON(
            path: APIPath.getGoods,
            parameters: ["area_id": areaID],
            needToken: false
        ) { result in
            switch result {
            case .success(let dict):
                let arr = (dict["Msg"] as? [[String: Any]]) ?? []
                let items = arr.compactMap { Goods(from: $0) }
                completion(.success(items))
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }

    // MARK: - 区域路线列表（按场地）
    static func linesByArea(areaID: String,
                            completion: @escaping (Result<[Line], APIError>) -> Void) {
        NetworkService.shared.requestJSON(
            path: APIPath.areaUrl,
            parameters: ["area_id": areaID],
            needToken: false
        ) { result in
            switch result {
            case .success(let dict):
                // 后端返回 Msg.data 为路线数组；为空或 NSNull 时视为无数据
                let msg = dict["Msg"] as? [String: Any]
                let arr = (msg?["data"] as? [[String: Any]]) ?? []
                let items = arr.compactMap { Line(from: $0) }
                completion(.success(items))
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }

    // MARK: - 报名下单
    /// 返回新建订单
    static func signUp(goodsID: String, quantity: Int,
                       completion: @escaping (Result<Orders, APIError>) -> Void) {
        NetworkService.shared.requestJSON(
            path: APIPath.addOrders,
            parameters: ["goods_id": goodsID, "orders_quantity": String(quantity)]
        ) { result in
            switch result {
            case .success(let dict):
                if (dict["Code"] as? Int) == 1,
                   let msg = dict["Msg"] as? [String: Any] {
                    completion(.success(Orders(from: msg)))
                } else {
                    completion(.failure(.business(
                        code: dict["Code"] as? Int ?? -1,
                        message: (dict["Msg"] as? String) ?? "报名失败"
                    )))
                }
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }
}
