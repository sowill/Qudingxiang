//
//  OfflineDBService.swift
//  趣定向 (Swift 迁移版)
//
//  替代 LocalDBService.m：在线缓存型离线服务
//  - 用 Codable + JSON 文件 替代 NSKeyedArchiver
//  - 用 Alamofire 替代 AFHTTPSessionManager
//  - 保持原有键名前缀：/MylineInfo、/Myline、/MylineHistory、/MylineQuestion
//  - 离线状态下完成点标感应、出题、判定、写历史；网络恢复后批量上传
//
//  说明：服务端返回的 mylineinfo 结构高度动态（嵌套 pointqumap/question 等），
//  此处仍以 [String: Any] 字典承接，避免过度建模；
//  持久化时序列化为 JSON Data 写入文件。
//

import Foundation
import Alamofire

final class OfflineDBService {

    static let shared = OfflineDBService()
    private init() {}

    // MARK: - 路径

    /// 离线缓存根目录（与 OC accountFile 保持一致：Documents）
    private var root: String { QDXPath.documents }

    private func file(for prefix: String, mylineID: String) -> URL {
        URL(fileURLWithPath: root)
            .appendingPathComponent("\(prefix)\(mylineID)")
    }

    private let infoPrefix    = "/MylineInfo"
    private let mylinePrefix  = "/Myline"
    private let historyPrefix = "/MylineHistory"
    private let questionPrefix = "/MylineQuestion"
    private let questionHTML  = "/question.html"

    // MARK: - 通用 JSON 文件读写

    private func writeJSON(_ object: Any, to url: URL) {
        do {
            let data = try JSONSerialization.data(
                withJSONObject: object,
                options: [.fragmentsAllowed]
            )
            try data.write(to: url, options: .atomic)
        } catch {
            #if DEBUG
            print("[OfflineDBService] 写入失败 \(url.lastPathComponent): \(error)")
            #endif
        }
    }

    private func readJSON(from url: URL) -> Any? {
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              !data.isEmpty else { return nil }
        return try? JSONSerialization.jsonObject(
            with: data, options: [.allowFragments, .mutableContainers]
        )
    }

    // MARK: - LoadDb：从服务端拉取线路库并落地

    /// 等价 OC + (void)LoadDb:...
    func loadDb(lineID: String,
                mylineID: String,
                completion: @escaping ([String: Any]?) -> Void,
                failure: @escaping (Error) -> Void) {

        let url = APIHost.base + APIPath.loadDb
        let params: [String: Any] = ["line_id": lineID]
        let fileURL = file(for: infoPrefix, mylineID: mylineID)

        AF.request(url, method: .post, parameters: params)
            .validate()
            .responseJSON { [weak self] resp in
                switch resp.result {
                case .success(let value):
                    let dict = (value as? [String: Any]) ?? [:]
                    self?.writeJSON(dict, to: fileURL)
                    completion(dict)
                case .failure(let err):
                    failure(err)
                }
            }
    }

    // MARK: - Read 系列

    func readMylineInfo(_ mylineID: String) -> [[String: Any]] {
        let url = file(for: infoPrefix, mylineID: mylineID)
        return (readJSON(from: url) as? [[String: Any]]) ?? []
    }

    func readMyline(_ mylineID: String) -> [String: Any] {
        let url = file(for: mylinePrefix, mylineID: mylineID)
        return (readJSON(from: url) as? [String: Any]) ?? [:]
    }

    func readQuestion(_ mylineID: String) -> [String: Any] {
        let url = file(for: questionPrefix, mylineID: mylineID)
        return (readJSON(from: url) as? [String: Any]) ?? [:]
    }

    // MARK: - Write 系列

    func writeMyline(_ dict: [String: Any]) {
        guard let mylineID = dict["myline_id"] as? String else { return }
        writeJSON(dict, to: file(for: mylinePrefix, mylineID: mylineID))
    }

    func writeHistory(_ mylineID: String, dict: Any) {
        writeJSON(dict, to: file(for: historyPrefix, mylineID: mylineID))
    }

    // MARK: - CheckHistory

    /// 检查本线路本点标是否已记录
    func checkHistory(_ mylineID: String, pointmapID: String) -> Bool {
        let url = file(for: historyPrefix, mylineID: mylineID)
        let arr = (readJSON(from: url) as? [[String: Any]]) ?? []
        return arr.contains { ($0["pointmap_id"] as? String) == pointmapID }
    }

    // MARK: - ResetQuestion：随机抽题并写入 question.html

    /// 等价 OC + (void)ResetQuestion:Dic:
    func resetQuestion(_ mylineID: String, candidates: [[String: Any]]) {
        let url = file(for: questionPrefix, mylineID: mylineID)
        let current = readQuestion(mylineID)
        let currentQID = current["pointqumap_id"] as? String

        var picked: [String: Any]? = nil
        if candidates.count == 1 {
            picked = candidates.first
        } else if !candidates.isEmpty {
            // 多题时尽量避开当前题
            let offset = Int.random(in: 0..<candidates.count)
            for (idx, q) in candidates.enumerated() where idx == offset {
                let qid = q["pointqumap_id"] as? String
                if qid != currentQID {
                    picked = q
                }
            }
            if picked == nil { picked = candidates[offset] }
        }
        guard let pickedDict = picked else { return }
        writeJSON(pickedDict, to: url)

        // 写 question.html（WKWebView 直接 load）
        if let question = (pickedDict["question"] as? [String: Any])?["question_name"] as? String {
            let htmlURL = URL(fileURLWithPath: root).appendingPathComponent(questionHTML)
            try? question.data(using: .utf8)?.write(to: htmlURL, options: .atomic)
        }
    }

    // MARK: - PassChange：通过点标，更新线路状态与历史

    /// 等价 OC + (bool)PassChange:PointMap:
    /// - Parameters:
    ///   - myline: 当前线路字典（可变引用语义，调用方传入后已被修改）
    ///   - info: 命中的 mylineinfo 点标
    @discardableResult
    func passChange(_ myline: inout [String: Any], point info: [String: Any]) -> Bool {

        myline["pointmap_id"] = info["pointmap_id"]
        myline["img_url"]     = info["pointmap_img"]
        myline["pointmap"]    = info

        // 终点判定：pindex >= 998 视为完成
        let pindex = Int((info["pindex"] as? String) ?? "0") ?? 0
        myline["mstatus_id"] = pindex >= 998 ? "3" : "2"

        // 依次型线路：自动滚动到下一个点标
        let linetypeID = Int(((myline["line"] as? [String: Any])?["linetype_id"] as? String) ?? "0") ?? 0
        if linetypeID == 1 {
            let mylineID = (myline["myline_id"] as? String) ?? ""
            let infos = readMylineInfo(mylineID)
            let currIdx = Int(((myline["pointmap"] as? [String: Any])?["pindex"] as? String) ?? "0") ?? 0
            var point = (myline["point"] as? [String: Any]) ?? [:]
            for info2 in infos {
                let idx2 = Int((info2["pindex"] as? String) ?? "0") ?? 0
                if idx2 > currIdx {
                    point["label"]      = "\(info2["point_id"] ?? ""),\(info2["label"] ?? "")"
                    point["point_name"] = info2["point_name"]
                    break
                }
            }
            myline["point"] = point
        }

        // 追加历史
        var history = (myline["history"] as? [[String: Any]]) ?? []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let edate = formatter.string(from: Date())

        var his: [String: Any] = [:]
        his["edate"]          = edate
        his["myline_id"]      = myline["myline_id"]
        his["point_id"]       = info["point_id"]
        his["pointmap_id"]    = info["pointmap_id"]
        his["score"]          = "0"
        his["mylineinfo_id"]  = "0"
        his["point"] = [
            "rssi":       info["rssi"] ?? "",
            "point_name": info["point_name"] ?? ""
        ]
        history.append(his)
        myline["history"] = history

        writeMyline(myline)
        writeHistory((myline["myline_id"] as? String) ?? "", dict: history)
        return true
    }

    // MARK: - CheckTask：核心调度

    /// 等价 OC + (NSDictionary *)CheckTask:
    /// - Returns: ["Code": "0/1/2", "Msg": ...]
    ///   Code = 0 已记录 / 1 出题（Msg 含题目 HTML）/ 2 通过
    func checkTask(_ param: [String: Any]) -> [String: Any] {

        var result = param
        let mylineID = (param["myline_id"] as? String) ?? ""
        let infos = readMylineInfo(mylineID)
        var myline = readMyline(mylineID)

        // —— 1. 通过 mac 匹配点标 ——
        if let mac = param["mac"] as? String, !mac.isEmpty {
            // 12 位无冒号 -> 转带冒号格式，便于匹配 label
            var macFmt = mac
            if macFmt.count == 12 {
                var parts: [String] = []
                var idx = macFmt.startIndex
                for _ in 0..<6 {
                    let next = macFmt.index(idx, offsetBy: 2)
                    parts.append(String(macFmt[idx..<next]))
                    idx = next
                }
                macFmt = parts.joined(separator: ":")
            }

            for info in infos {
                let pid   = (info["point_id"] as? String) ?? ""
                let label = (info["label"] as? String) ?? ""
                if pid == macFmt || label == macFmt {

                    let pmapID = (info["pintmap_id"] as? String) ?? (info["pointmap_id"] as? String) ?? ""
                    if checkHistory(mylineID, pointmapID: pmapID) {
                        result["Code"] = "0"
                        result["Msg"]  = "已记录"
                        return result
                    }

                    let pq = info["pointqumap"]
                    if pq is NSNull || pq == nil {
                        // 无题直接通过
                        passChange(&myline, point: info)
                        result["Code"] = "2"
                        result["Msg"]  = "Yes"
                        return result
                    } else {
                        // 有题：随机抽一题
                        resetQuestion(mylineID,
                                      candidates: (pq as? [[String: Any]]) ?? [pq as? [String: Any]].compactMap { $0 })
                        result["Code"] = "1"
                        result["Msg"]  = readQuestion(mylineID)
                        return result
                    }
                }
            }
        }

        // —— 2. 通过 answer 判题 ——
        if let answer = param["answer"] as? String, !answer.isEmpty {
            let que = readQuestion(mylineID)
            var pointmap: [String: Any] = [:]
            let qPmapID = (que["pointmap_id"] as? String) ?? ""
            for info in infos where (info["pointmap_id"] as? String) == qPmapID {
                pointmap = info
                break
            }
            let qkey = ((que["question"] as? [String: Any])?["qkey"] as? String) ?? ""
            if answer == qkey {
                passChange(&myline, point: pointmap)
                result["Code"] = "2"
                result["Msg"]  = "Yes"
                return result
            } else {
                let pq = pointmap["pointqumap"]
                resetQuestion(mylineID,
                              candidates: (pq as? [[String: Any]]) ?? [pq as? [String: Any]].compactMap { $0 })
                result["Code"] = "1"
                result["Msg"]  = readQuestion(mylineID)
                return result
            }
        }

        return result
    }

    // MARK: - UploadHistory：网络恢复后批量上传

    /// 等价 OC + (void)UploadHistory:
    /// 上传所有 mylineinfo_id == 0 的历史记录，成功后回写 mylineinfo_id
    func uploadHistory(_ mylineID: String) {
        let myline = readMyline(mylineID)
        guard let history = myline["history"] as? [[String: Any]] else { return }

        let url = APIHost.base + APIPath.uploadHistory

        for (idx, his) in history.enumerated() {
            let infoID = (his["mylineinfo_id"] as? String) ?? ""
            guard Int(infoID) == 0 else { continue }

            let params: [String: Any] = [
                "time":        (his["edate"] as? String) ?? "",
                "myline_id":   (his["myline_id"] as? String) ?? mylineID,
                "pointmap_id": (his["pointmap_id"] as? String) ?? ""
            ]

            AF.request(url, method: .post, parameters: params)
                .validate()
                .responseJSON { [weak self] resp in
                    guard let self = self else { return }
                    if case .success(let value) = resp.result,
                       let dict = value as? [String: Any],
                       (dict["Code"] as? Int) == 1,
                       let msg = dict["Msg"] as? [String: Any] {
                        var updated = self.readMyline(mylineID)
                        if var arr = updated["history"] as? [[String: Any]],
                           idx < arr.count {
                            arr[idx]["score"]          = msg["score"] ?? "0"
                            arr[idx]["mylineinfo_id"]  = msg["mylineinfo_id"] ?? ""
                            updated["history"] = arr
                            self.writeMyline(updated)
                        }
                    }
                }
        }
    }
}
