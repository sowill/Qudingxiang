//
//  PayManager.swift
//  趣定向 (Swift 迁移版)
//
//  统一支付管理：替代原 QDXPayTableViewController 中分散的微信/支付宝调用
//  使用现代 SDK API：WechatOpenSDK、AlipaySDK
//

import UIKit
import AlipaySDK
// import WXApi  // Pod 'WechatOpenSDK-XCFramework'

enum PayType: Int {
    case wechat = 0
    case alipay = 1
}

enum PayResult {
    case success
    case processing       // 8000 处理中
    case canceled         // 6001 用户取消
    case failure(String)
}

final class PayManager: NSObject {
    static let shared = PayManager()
    private override init() { super.init() }

    /// 支付结果回调
    var payCompletion: ((PayResult) -> Void)?

    // MARK: - 拉起支付
    /// 拉起微信支付
    func wechatPay(param: WeixinPayParam, completion: @escaping (PayResult) -> Void) {
        self.payCompletion = completion
        // 真实集成时调用：
        // let req = PayReq()
        // req.partnerId   = param.partnerid ?? ""
        // req.prepayId    = param.prepayid ?? ""
        // req.nonceStr    = param.noncestr ?? ""
        // req.timeStamp   = UInt32(param.timestamp ?? "0") ?? 0
        // req.package     = param.package ?? ""
        // req.sign        = param.sign ?? ""
        // WXApi.send(req)
        // 这里由于 SDK 未在桥接中，先返回失败提示
        completion(.failure("微信 SDK 未接入"))
    }

    /// 拉起支付宝
    func alipay(orderString: String, scheme: String = "alipay2088121109128595",
                completion: @escaping (PayResult) -> Void) {
        self.payCompletion = completion
        AlipaySDK.defaultService().payOrder(orderString, fromScheme: scheme) { [weak self] result in
            self?.handleAlipayResult(result as? [String: Any] ?? [:])
        }
    }

    // MARK: - 支付宝结果解析
    private func handleAlipayResult(_ result: [String: Any]) {
        let status = (result["resultStatus"] as? Int) ?? 0
        var msg = ""
        switch status {
        case 9000: msg = "订单支付成功"
        case 8000: msg = "正在处理中"
        case 4000: msg = "订单支付失败"
        case 6001: msg = "用户中途取消"
        case 6002: msg = "网络连接错误"
        default:  msg = "未知错误"
        }
        let res: PayResult
        switch status {
        case 9000: res = .success
        case 8000: res = .processing
        case 6001: res = .canceled
        default:  res = .failure(msg)
        }
        payCompletion?(res)
    }

    // MARK: - 处理 App 跳回 URL（在 AppDelegate / SceneDelegate 中调用）
    func handleOpenURL(_ url: URL) {
        // AlipaySDK.defaultService().processOrder(with: result, standbyCallback: ...)
        // WXApi.handleOpen(url, delegate: self)
    }
}
