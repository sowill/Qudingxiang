//
//  GameAPI.swift
//  趣定向 (Swift 迁移版)
//
//  游戏相关 API：任务刷新、任务定位、历史足迹、结束活动
//

import Foundation

enum GameAPI {
    /// 任务刷新（获取当前状态与点标信息）
    static func taskRefresh(mylineID: String,
                            completion: @escaping (Result<TaskRefresh, APIError>) -> Void) {
        NetworkService.shared.requestJSON(
            path: APIPath.taskRefresh, parameters: ["myline_id": mylineID]
        ) { result in
            switch result {
            case .success(let dict):
                if (dict["Code"] as? Int) == 1, let msg = dict["Msg"] as? [String: Any] {
                    completion(.success(TaskRefresh(from: msg)))
                } else {
                    completion(.failure(.business(
                        code: dict["Code"] as? Int ?? -1,
                        message: (dict["Msg"] as? String) ?? "任务信息获取失败"
                    )))
                }
            case .failure:
                // 请求不到时返回默认空模型，保证游戏流程不中断
                completion(.success(TaskRefresh(from: [:])))
            }
        }
    }

    /// 任务定位（地图点标与自定义底图）
    static func taskLocation(mylineID: String,
                             completion: @escaping (Result<TaskLocation, APIError>) -> Void) {
        NetworkService.shared.requestJSON(
            path: APIPath.taskLocation, parameters: ["myline_id": mylineID], needToken: false
        ) { result in
            switch result {
            case .success(let dict):
                // 后端直接返回 TaskLocation 字段
                let loc = TaskLocation(from: dict)
                completion(.success(loc))
            case .failure:
                completion(.success(TaskLocation(from: [:])))
            }
        }
    }

    /// 历史足迹
    static func history(mylineID: String,
                        completion: @escaping (Result<[History], APIError>) -> Void) {
        NetworkService.shared.requestJSON(
            path: APIPath.history, parameters: ["myline_id": mylineID], needToken: false
        ) { result in
            switch result {
            case .success(let dict):
                if let arr = dict["historyArray"] as? [[String: Any]] {
                    completion(.success(arr.map { History(from: $0) }))
                } else if let arr = dict["Msg"] as? [[String: Any]] {
                    completion(.success(arr.map { History(from: $0) }))
                } else {
                    completion(.success([]))
                }
            case .failure:
                completion(.success([]))
            }
        }
    }

    /// 结束活动（退赛）
    static func gameover(mylineID: String,
                         completion: @escaping (Result<String, APIError>) -> Void) {
        NetworkService.shared.requestJSON(
            path: APIPath.gameover, parameters: ["myline_id": mylineID]
        ) { result in
            switch result {
            case .success(let dict):
                if (dict["Code"] as? Int) == 1 {
                    completion(.success((dict["Msg"] as? String) ?? "已结束"))
                } else {
                    completion(.failure(.business(
                        code: dict["Code"] as? Int ?? -1,
                        message: (dict["Msg"] as? String) ?? "操作失败"
                    )))
                }
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }
}
