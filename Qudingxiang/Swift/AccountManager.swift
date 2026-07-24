//
//  AccountManager.swift
//  趣定向 (Swift 迁移版)
//
//  用户登录态管理：替代旧版的 XWLAccount.data + NSKeyedArchiver
//  使用 KeychainAccess 安全存储 token，UserDefaults 缓存用户基本信息
//

import Foundation
import KeychainAccess

final class AccountManager {
    static let shared = AccountManager()
    private init() {}

    private let keychain = Keychain(service: "cn.qudingxiang.app")
    private let defaults = UserDefaults.standard
    private let tokenKey    = "customer_token"
    private let customerKey = "customer_basic_info"

    /// 当前 token
    var token: String? {
        keychain[tokenKey]
    }

    /// 是否已登录
    var isLoggedIn: Bool {
        (token?.isEmpty == false)
    }

    /// 当前用户基本信息（不含敏感字段）
    var current: Customer? {
        guard let data = defaults.data(forKey: customerKey) else { return nil }
        return try? JSONDecoder().decode(Customer.self, from: data)
    }

    /// 登录成功后保存
    func save(_ customer: Customer) {
        if let t = customer.token, !t.isEmpty {
            keychain[tokenKey] = t
        }
        if let data = try? JSONEncoder().encode(customer) {
            defaults.set(data, forKey: customerKey)
        }
    }

    /// 仅更新 token
    func updateToken(_ token: String) {
        keychain[tokenKey] = token
    }

    /// 退出登录
    func clear() {
        try? keychain.remove(tokenKey)
        defaults.removeObject(forKey: customerKey)
    }

    /// 旧版本数据迁移：读取 XWLAccount.data 中的 token
    func migrateFromLegacyIfNeeded() {
        guard token == nil else { return }
        if FileManager.default.fileExists(atPath: QDXPath.account),
           let t = try? String(contentsOfFile: QDXPath.account, encoding: .utf8),
           !t.isEmpty {
            keychain[tokenKey] = t
            try? FileManager.default.removeItem(atPath: QDXPath.account)
        }
    }
}
