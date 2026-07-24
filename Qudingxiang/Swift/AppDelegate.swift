//
//  AppDelegate.swift
//  趣定向 (Swift 迁移版)
//
//  替代原 AppDelegate.m，负责 SDK 注册、自动登录与根视图切换
//

import UIKit
import Alamofire
import AMapLocationKit
import AMapFoundationKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    /// 微信支付完成回调
    var weChatPayCompletion: (() -> Void)?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupWindow()
        setupThirdPartySDKs()
        setupAppearance()
        tryAutoLogin()

        if isVersionChanged {
            saveCurrentVersion()
            showGuide()
        } else {
            showMainTabBar()
        }
        return true
    }

    // MARK: - Window
    private func setupWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = QDXColor.background
        window.makeKeyAndVisible()
        self.window = window
    }

    // MARK: - SDK 注册
    private func setupThirdPartySDKs() {
        // 微信
        // WXApi.registerApp(SDKKeys.wechat, universalLink: "https://www.qudingxiang.cn/app/")
        // 高德
        AMapServices.shared().apiKey = SDKKeys.amap
        AMapLocationPrivacyAgree(.didAgree)
        AMapLocationPrivacyShow(.didShow)
    }

    // MARK: - 全局外观
    private func setupAppearance() {
        // 导航栏
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = QDXColor.primary
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: QDXFont.semibold(34)
        ]
        navAppearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance   = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().tintColor = .white

        // TabBar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance   = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        UITabBar.appearance().tintColor = QDXColor.primary
    }

    // MARK: - 自动登录
    private func tryAutoLogin() {
        guard let token = AccountManager.shared.token, !token.isEmpty else {
            AccountManager.shared.clear()
            return
        }
        let url = APIHost.base + APIPath.authLogin
        AF.request(url, method: .post, parameters: ["customer_token": token])
            .validate()
            .responseJSON { resp in
                switch resp.result {
                case .success(let value):
                    if let dict = value as? [String: Any],
                       (dict["Code"] as? Int) != 0,
                       let msg = dict["Msg"] as? [String: Any] {
                        let customer = Customer(from: msg)
                        AccountManager.shared.save(customer)
                    } else {
                        AccountManager.shared.clear()
                    }
                case .failure:
                    break
                }
            }
    }

    // MARK: - 版本判断
    private var isVersionChanged: Bool {
        let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let saved   = (try? String(contentsOfFile: QDXPath.version, encoding: .utf8)) ?? ""
        return current != saved
    }
    private func saveCurrentVersion() {
        let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        try? current.write(toFile: QDXPath.version, atomically: true, encoding: .utf8)
    }

    // MARK: - 根视图
    private func showGuide() {
        window?.rootViewController = GuideViewController()
    }
    private func showMainTabBar() {
        window?.rootViewController = MainTabBarController()
    }

    // MARK: - 微信回调
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // 微信 / QQ / 支付宝统一在此处理
        // return WXApi.handleOpen(url, delegate: self) || TencentOAuth.handleOpen(url)
        return true
    }
}
