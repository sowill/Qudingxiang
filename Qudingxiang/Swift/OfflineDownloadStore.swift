//
//  OfflineDownloadStore.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXOfflineDB.m + LocalSqlliteService.m
//  使用 SQLite.swift 类型安全封装，替代 OC 原生 sqlite3 C API
//  数据库：~/Documents/QDXOffine.sqlite（与 OC 保持同名）
//
//  表结构沿用 OC：
//   - qdx_myline          离线下载的线路
//   - qdx_history         历史记录
//   - qdx_line_point      线路-点标关联
//   - qdx_point           点标（MAC/label/rssi）
//   - qdx_question        题目
//   - qdx_point_question  点标-题目关联
//

import Foundation
import UIKit
import SQLite
import Alamofire

// MARK: - 离线模式数据模型（仅离线下载场景使用）

struct OfflineMyline {
    var lineID:     String
    var mylineID:   String
    var mstatusID:  String   // 0准备 / 1待开始 / 2进行中 / 3完成 / 4失败
    var sdate:      String
    var score:      String
    var isLeader:   String
    var pointmapID: String
}

struct OfflinePoint {
    var pointID:  String
    var areaID:   String
    var lat:      String
    var lon:      String
    var label:    String   // 形如 "AA:BB:CC:DD:EE:FF" 或 "AA:BB:..,11:22:.."
    var pointName: String
    var rssi:     String
}

struct OfflineLinePoint {
    var lineID:      String
    var pointID:     String
    var pointmapID:  String
    var pointmapDes: String
    var pindex:      String
    var linetypeID:  String   // 1 依次 / 2 自由 / 3 限时
}

struct OfflineQuestion {
    var questionName: String
    var qa: String
    var qb: String
    var qc: String
    var qd: String
    var qkey: String
    var questionID: String
}

struct OfflineHistory {
    var edate:    String
    var mylineID: String
    var pointID:  String
    var score:    String
}

// MARK: - Store

final class OfflineDownloadStore {

    static let shared = OfflineDownloadStore()

    private let db: Connection

    private init() {
        let path = (QDXPath.documents as NSString).appendingPathComponent("QDXOffine.sqlite")
        do {
            db = try Connection(path)
            try createTablesIfNeeded()
        } catch {
            // 兜底：使用内存库避免崩溃
            db = try! Connection(.inMemory)
            #if DEBUG
            print("[OfflineDownloadStore] 打开数据库失败，降级到内存库: \(error)")
            #endif
        }
    }

    // MARK: - 表定义

    private let mylineTable         = Table("qdx_myline")
    private let historyTable        = Table("qdx_history")
    private let linePointTable      = Table("qdx_line_point")
    private let pointTable          = Table("qdx_point")
    private let questionTable       = Table("qdx_question")
    private let pointQuestionTable  = Table("qdx_point_question")

    // 列
    private let col_m_l_id      = Expression<Int64>("m_l_id")
    private let col_line_id     = Expression<String?>("line_id")
    private let col_myline_id   = Expression<String?>("myline_id")
    private let col_mstatus_id  = Expression<String?>("mstatus_id")
    private let col_sdate       = Expression<String?>("sdate")
    private let col_score       = Expression<String?>("score")
    private let col_isLeader    = Expression<String?>("isLeader")
    private let col_pointmap_id = Expression<String?>("pointmap_id")

    private let col_h_id      = Expression<Int64>("h_id")
    private let col_edate     = Expression<String?>("edate")
    // myline_id / point_id / score 复用

    private let col_l_p_id      = Expression<Int64>("l_p_id")
    private let col_point_id    = Expression<String?>("point_id")
    private let col_pointmap_des = Expression<String?>("pointmap_des")
    private let col_pindex      = Expression<String?>("pindex")
    private let col_linetype_id = Expression<String?>("linetype_id")

    private let col_p_id      = Expression<Int64>("p_id")
    private let col_area_id   = Expression<String?>("area_id")
    private let col_lat       = Expression<String?>("LAT")
    private let col_lon       = Expression<String?>("LON")
    private let col_label     = Expression<String?>("label")
    private let col_point_name = Expression<String?>("point_name")
    private let col_rssi      = Expression<String?>("rssi")

    private let col_q_id       = Expression<Int64>("q_id")
    private let col_question_name = Expression<String?>("question_name")
    private let col_qa         = Expression<String?>("qa")
    private let col_qb         = Expression<String?>("qb")
    private let col_qc         = Expression<String?>("qc")
    private let col_qd         = Expression<String?>("qd")
    private let col_qkey       = Expression<String?>("qkey")
    private let col_question_id = Expression<String?>("question_id")

    private let col_p_q_id = Expression<Int64>("p_q_id")

    private func createTablesIfNeeded() throws {
        try db.run(mylineTable.create(ifNotExists: true) { t in
            t.column(col_m_l_id, primaryKey: .autoincrement)
            t.column(col_line_id)
            t.column(col_myline_id)
            t.column(col_mstatus_id)
            t.column(col_sdate)
            t.column(col_score)
            t.column(col_isLeader)
            t.column(col_pointmap_id)
        })
        try db.run(historyTable.create(ifNotExists: true) { t in
            t.column(col_h_id, primaryKey: .autoincrement)
            t.column(col_edate)
            t.column(col_myline_id)
            t.column(col_point_id)
            t.column(col_score)
        })
        try db.run(linePointTable.create(ifNotExists: true) { t in
            t.column(col_l_p_id, primaryKey: .autoincrement)
            t.column(col_line_id)
            t.column(col_point_id)
            t.column(col_pointmap_id)
            t.column(col_pointmap_des)
            t.column(col_pindex)
            t.column(col_linetype_id)
        })
        try db.run(pointTable.create(ifNotExists: true) { t in
            t.column(col_p_id, primaryKey: .autoincrement)
            t.column(col_point_id)
            t.column(col_area_id)
            t.column(col_lat)
            t.column(col_lon)
            t.column(col_label)
            t.column(col_point_name)
            t.column(col_rssi)
        })
        try db.run(questionTable.create(ifNotExists: true) { t in
            t.column(col_q_id, primaryKey: .autoincrement)
            t.column(col_question_name)
            t.column(col_qa)
            t.column(col_qb)
            t.column(col_qc)
            t.column(col_qd)
            t.column(col_qkey)
            t.column(col_question_id)
        })
        try db.run(pointQuestionTable.create(ifNotExists: true) { t in
            t.column(col_p_q_id, primaryKey: .autoincrement)
            t.column(col_question_id)
            t.column(col_pointmap_id)
        })
    }

    // MARK: - 删除全部表（清空离线数据）

    func closeAndReset() {
        try? db.run(mylineTable.delete())
        try? db.run(historyTable.delete())
        try? db.run(linePointTable.delete())
        try? db.run(pointTable.delete())
        try? db.run(questionTable.delete())
        try? db.run(pointQuestionTable.delete())
    }

    // MARK: - 去重（等价 OC deleteTheSame）

    func deleteDuplicates() {
        let sqls = [
            "DELETE FROM qdx_point_question WHERE p_q_id NOT IN (SELECT MIN(p_q_id) AS p_q_id FROM qdx_point_question GROUP BY question_id, pointmap_id)",
            "DELETE FROM qdx_question WHERE question_id IN (SELECT question_id FROM qdx_question GROUP BY question_id HAVING COUNT(question_id) > 1) AND q_id NOT IN (SELECT MIN(q_id) FROM qdx_question GROUP BY question_id HAVING COUNT(question_id) > 1)",
            "DELETE FROM qdx_history WHERE h_id NOT IN (SELECT MIN(h_id) AS h_id FROM qdx_history GROUP BY point_id, myline_id)",
            "DELETE FROM qdx_line_point WHERE l_p_id NOT IN (SELECT MIN(l_p_id) AS l_p_id FROM qdx_line_point GROUP BY line_id, pointmap_id)",
            "DELETE FROM qdx_point WHERE p_id NOT IN (SELECT MIN(p_id) AS p_id FROM qdx_point GROUP BY point_id)",
            "DELETE FROM qdx_myline WHERE m_l_id NOT IN (SELECT MAX(m_l_id) AS m_l_id FROM qdx_myline GROUP BY myline_id)"
        ]
        for sql in sqls { _ = try? db.run(sql) }
    }

    // MARK: - Myline

    func insertMyline(_ m: OfflineMyline) {
        try? db.run(mylineTable.insert(
            col_line_id     <- m.lineID,
            col_myline_id   <- m.mylineID,
            col_mstatus_id  <- m.mstatusID,
            col_sdate       <- m.sdate,
            col_score       <- m.score,
            col_isLeader    <- m.isLeader,
            col_pointmap_id <- m.pointmapID
        ))
    }

    func selectMyline(mylineID: String) -> OfflineMyline? {
        guard let row = try? db.pluck(mylineTable.filter(col_myline_id == mylineID)) else {
            return nil
        }
        return OfflineMyline(
            lineID:     row[col_line_id]     ?? "",
            mylineID:   row[col_myline_id]   ?? "",
            mstatusID:  row[col_mstatus_id]  ?? "",
            sdate:      row[col_sdate]       ?? "",
            score:      row[col_score]       ?? "",
            isLeader:   row[col_isLeader]    ?? "",
            pointmapID: row[col_pointmap_id] ?? ""
        )
    }

    func modifyMyline(_ m: OfflineMyline) {
        try? db.run(mylineTable
            .filter(col_myline_id == m.mylineID)
            .update(
                col_mstatus_id  <- m.mstatusID,
                col_sdate       <- m.sdate,
                col_score       <- m.score,
                col_pointmap_id <- m.pointmapID
            ))
    }

    // MARK: - Point

    func insertPoint(_ p: OfflinePoint) {
        try? db.run(pointTable.insert(
            col_point_id   <- p.pointID,
            col_area_id    <- p.areaID,
            col_lat        <- p.lat,
            col_lon        <- p.lon,
            col_label      <- p.label,
            col_point_name <- p.pointName,
            col_rssi       <- p.rssi
        ))
    }

    func selectPoint(pointID: String) -> OfflinePoint? {
        guard let row = try? db.pluck(pointTable.filter(col_point_id == pointID)) else {
            return nil
        }
        return OfflinePoint(
            pointID:   row[col_point_id]   ?? "",
            areaID:    row[col_area_id]    ?? "",
            lat:       row[col_lat]        ?? "",
            lon:       row[col_lon]        ?? "",
            label:     row[col_label]      ?? "",
            pointName: row[col_point_name] ?? "",
            rssi:      row[col_rssi]       ?? ""
        )
    }

    func selectAllPoints(pointIDs: [String]) -> [OfflinePoint] {
        guard !pointIDs.isEmpty else { return [] }
        var result: [OfflinePoint] = []
        for id in pointIDs {
            if let p = selectPoint(pointID: id) { result.append(p) }
        }
        return result
    }

    // MARK: - LinePoint

    func insertLinePoint(_ lp: OfflineLinePoint) {
        try? db.run(linePointTable.insert(
            col_line_id      <- lp.lineID,
            col_point_id     <- lp.pointID,
            col_pointmap_id  <- lp.pointmapID,
            col_pointmap_des <- lp.pointmapDes,
            col_pindex       <- lp.pindex,
            col_linetype_id  <- lp.linetypeID
        ))
    }

    func selectLinePoints(lineID: String) -> [OfflineLinePoint] {
        let query = linePointTable
            .filter(col_line_id == lineID)
            .order(col_pindex.asc)
        var result: [OfflineLinePoint] = []
        if let rows = try? db.prepare(query) {
            for row in rows {
                result.append(OfflineLinePoint(
                    lineID:      row[col_line_id]      ?? "",
                    pointID:     row[col_point_id]     ?? "",
                    pointmapID:  row[col_pointmap_id]  ?? "",
                    pointmapDes: row[col_pointmap_des] ?? "",
                    pindex:      row[col_pindex]       ?? "",
                    linetypeID:  row[col_linetype_id]  ?? ""
                ))
            }
        }
        return result
    }

    // MARK: - Question

    func insertQuestion(_ q: OfflineQuestion) {
        try? db.run(questionTable.insert(
            col_question_name <- q.questionName,
            col_qa            <- q.qa,
            col_qb            <- q.qb,
            col_qc            <- q.qc,
            col_qd            <- q.qd,
            col_qkey          <- q.qkey,
            col_question_id   <- q.questionID
        ))
    }

    func insertPointQuestion(questionID: String, pointmapID: String) {
        try? db.run(pointQuestionTable.insert(
            col_question_id  <- questionID,
            col_pointmap_id  <- pointmapID
        ))
    }

    func selectQuestions(pointmapID: String) -> [OfflineQuestion] {
        let subQuery = pointQuestionTable
            .select(col_question_id)
            .filter(col_pointmap_id == pointmapID)
        let query = questionTable.filter(col_question_id.in(subQuery))
        var result: [OfflineQuestion] = []
        if let rows = try? db.prepare(query) {
            for row in rows {
                result.append(OfflineQuestion(
                    questionName: row[col_question_name] ?? "",
                    qa: row[col_qa] ?? "",
                    qb: row[col_qb] ?? "",
                    qc: row[col_qc] ?? "",
                    qd: row[col_qd] ?? "",
                    qkey: row[col_qkey] ?? "",
                    questionID: row[col_question_id] ?? ""
                ))
            }
        }
        return result
    }

    // MARK: - History

    func insertHistory(_ h: OfflineHistory) {
        try? db.run(historyTable.insert(
            col_edate     <- h.edate,
            col_myline_id <- h.mylineID,
            col_point_id  <- h.pointID,
            col_score     <- h.score
        ))
    }

    func selectHistory(mylineID: String) -> [OfflineHistory] {
        let query = historyTable
            .filter(col_myline_id == mylineID)
            .order(col_h_id.asc)
        var result: [OfflineHistory] = []
        if let rows = try? db.prepare(query) {
            for row in rows {
                result.append(OfflineHistory(
                    edate:    row[col_edate]     ?? "",
                    mylineID: row[col_myline_id] ?? "",
                    pointID:  row[col_point_id]  ?? "",
                    score:    row[col_score]     ?? ""
                ))
            }
        }
        return result
    }
}

// MARK: - 离线下载服务（替代 LocalSqlliteService）

enum OfflineDownloadAPI {

    /// 拉取并落地 myline 基本信息 + 历史足迹 + 地图图片
    static func setupMylineInfo(mylineID: String, token: String,
                                completion: @escaping (Bool) -> Void) {
        let url = APIHost.base + "index.php/Home/Myline/getMyline"
        let params: [String: Any] = ["TokenKey": token, "myline_id": mylineID]

        AF.request(url, method: .post, parameters: params).responseJSON { resp in
            guard case .success(let value) = resp.result,
                  let dict = value as? [String: Any],
                  (dict["Code"] as? Int) == 1,
                  let msg = dict["Msg"] as? [String: Any] else {
                completion(false); return
            }

            // 写 myline
            let myline = OfflineMyline(
                lineID:     (msg["line_id"] as? String)     ?? "",
                mylineID:   (msg["myline_id"] as? String)   ?? "",
                mstatusID:  (msg["mstatus_id"] as? String)  ?? "",
                sdate:      (msg["sdate"] as? String)       ?? "",
                score:      (msg["score"] as? String)       ?? "",
                isLeader:   (msg["isLeader"] as? String)    ?? "",
                pointmapID: (msg["pointmap_id"] as? String) ?? ""
            )
            OfflineDownloadStore.shared.insertMyline(myline)

            // 写历史
            if let history = msg["history"] as? [[String: Any]] {
                for h in history {
                    let m = OfflineHistory(
                        edate:    (h["edate"] as? String)    ?? "",
                        mylineID: (h["myline_id"] as? String) ?? "",
                        pointID:  (h["point_id"] as? String) ?? "",
                        score:    (h["point_id"] as? String) ?? ""
                    )
                    OfflineDownloadStore.shared.insertHistory(m)
                }
            }

            // 下载地图图片到 Documents/image/map_{myline_id}.png
            if let area = (msg["point"] as? [String: Any])?["area"] as? [String: Any],
               let mapPath = area["map"] as? String {
                let mapURL = APIHost.oldBase + mapPath
                downloadMapImage(url: mapURL, mylineID: mylineID)
            }

            completion(true)
        }
    }

    /// 拉取点标 + 线路-点标关联
    static func loadPoints(mylineID: String,
                           completion: @escaping (Bool) -> Void) {
        let url = APIHost.base + "index.php/Home/Myline/loadPoint"
        let params: [String: Any] = ["myline_id": mylineID]

        AF.request(url, method: .post, parameters: params).responseJSON { resp in
            guard case .success(let value) = resp.result,
                  let dict = value as? [String: Any],
                  (dict["Code"] as? Int) == 1,
                  let arr = dict["Msg"] as? [[String: Any]] else {
                completion(false); return
            }

            for item in arr {
                let point = (item["point"] as? [String: Any]) ?? [:]
                let line  = (item["line"]   as? [String: Any]) ?? [:]

                OfflineDownloadStore.shared.insertPoint(OfflinePoint(
                    pointID:   (point["point_id"] as? String)  ?? "",
                    areaID:    (point["area_id"]  as? String)  ?? "",
                    lat:       (point["LAT"]      as? String)  ?? "",
                    lon:       (point["LON"]      as? String)  ?? "",
                    label:     (point["label"]    as? String)  ?? "",
                    pointName: (point["point_name"] as? String) ?? "",
                    rssi:      (point["rssi"]     as? String)  ?? ""
                ))

                OfflineDownloadStore.shared.insertLinePoint(OfflineLinePoint(
                    lineID:      (item["line_id"]      as? String) ?? "",
                    pointID:     (item["point_id"]     as? String) ?? "",
                    pointmapID:  (item["pointmap_id"]  as? String) ?? "",
                    pointmapDes: (item["pointmap_des"] as? String) ?? "",
                    pindex:      (item["pindex"]       as? String) ?? "",
                    linetypeID:  (line["linetype_id"]  as? String) ?? ""
                ))
            }
            completion(true)
        }
    }

    /// 拉取题目 + 点标-题目关联
    static func loadQuestions(mylineID: String,
                              completion: @escaping (Bool) -> Void) {
        let url = APIHost.base + "index.php/Home/Myline/loadQuestion"
        let params: [String: Any] = ["myline_id": mylineID]

        AF.request(url, method: .post, parameters: params).responseJSON { resp in
            guard case .success(let value) = resp.result,
                  let dict = value as? [String: Any],
                  (dict["Code"] as? Int) == 1,
                  let arr = dict["Msg"] as? [[String: Any]] else {
                completion(false); return
            }

            for item in arr {
                let q = (item["question"] as? [String: Any]) ?? [:]
                OfflineDownloadStore.shared.insertQuestion(OfflineQuestion(
                    questionName: (q["question_name"] as? String) ?? "",
                    qa: (q["qa"] as? String) ?? "",
                    qb: (q["qb"] as? String) ?? "",
                    qc: (q["qc"] as? String) ?? "",
                    qd: (q["qd"] as? String) ?? "",
                    qkey: (q["qkey"] as? String) ?? "",
                    questionID: (q["question_id"] as? String) ?? ""
                ))
                OfflineDownloadStore.shared.insertPointQuestion(
                    questionID: (item["question_id"] as? String) ?? "",
                    pointmapID: (item["pointmap_id"] as? String) ?? ""
                )
            }
            completion(true)
        }
    }

    /// 下载地图图片到本地（与 OC 路径一致：Documents/image/map_{myline_id}.png）
    private static func downloadMapImage(url: String, mylineID: String) {
        guard let u = URL(string: url) else { return }
        AF.request(u).responseData { resp in
            guard case .success(let data) = resp.result, let img = UIImage(data: data) else { return }
            let imageDir = (QDXPath.documents as NSString).appendingPathComponent("image")
            try? FileManager.default.createDirectory(
                atPath: imageDir,
                withIntermediateDirectories: true
            )
            let path = "\(imageDir)/map_\(mylineID).png"
            if let png = img.pngData() {
                try? png.write(to: URL(fileURLWithPath: path))
            } else if let jpg = img.jpegData(compressionQuality: 1) {
                try? jpg.write(to: URL(fileURLWithPath: path))
            }
        }
    }
}
