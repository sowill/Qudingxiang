//
//  TaskCardViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXTaskViewController.m：任务卡弹层
//  - 以addChildViewController方式弹出，覆盖半透明遮罩 + 圆角卡片
//  - 初始显示「闯关成功」图 + 「查看提示」按钮
//  - 点击「查看提示」切换为：标题栏 + WKWebView 加载 mylineweb + 「好的」按钮 + 关闭按钮
//  - 点击「好的」或「关闭」移除自身
//
//  作为子控制器使用：父控制器 addChild + view.addSubview，再调用 didMove(toParent:)
//

import UIKit
import SnapKit
import WebKit

final class TaskCardViewController: BaseViewController {

    /// 当前 myline ID
    var mylineID: String = ""

    /// 标题（通常为 line.line_sub）
    var cardTitle: String = ""

    private let bgView = UIView()
    private let cardView = UIView()
    private let successImageView = UIImageView()
    private let showTipButton = UIButton(type: .system)
    private var webView: WKWebView?
    private var showOKButton: UIButton?
    private var showTitleButton: UIButton?
    private var cancelButton: UIButton?

    // 卡片尺寸（与 OC 一致：宽 0.875 屏宽，高 0.73 屏高）
    private var cardWidth: CGFloat { Screen.width * 0.875 }
    private var cardHeight: CGFloat { Screen.height * 0.73 }
    private var bottomBarHeight: CGFloat { cardHeight * 0.1 }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        // 1. 遮罩
        bgView.frame = UIScreen.main.bounds
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.addSubview(bgView)

        // 2. 卡片
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.clear.cgColor
        view.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(cardWidth)
            make.height.equalTo(cardHeight)
        }

        // 3. 闯关成功图
        successImageView.image = UIImage(named: "任务卡－闯关成功")
        successImageView.contentMode = .scaleAspectFill
        successImageView.clipsToBounds = true
        cardView.addSubview(successImageView)
        successImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(cardHeight - bottomBarHeight)
        }

        // 4. 查看提示按钮
        showTipButton.setTitle("查看提示", for: .normal)
        showTipButton.setTitleColor(.white, for: .normal)
        showTipButton.backgroundColor = QDXColor.primary
        showTipButton.layer.cornerRadius = 4
        showTipButton.addTarget(self, action: #selector(showTipTapped), for: .touchUpInside)
        cardView.addSubview(showTipButton)
        showTipButton.snp.makeConstraints { make in
            make.top.equalTo(successImageView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    // MARK: - 切换到任务书视图

    @objc private func showTipTapped() {
        showTipButton.removeFromSuperview()
        successImageView.removeFromSuperview()

        // 标题栏
        let titleBtn = UIButton(type: .system)
        titleBtn.isUserInteractionEnabled = false
        titleBtn.setTitle(cardTitle, for: .normal)
        titleBtn.setTitleColor(UIColor(white: 0.067, alpha: 1.0), for: .normal)
        titleBtn.titleLabel?.font = .systemFont(ofSize: 20)
        titleBtn.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        cardView.addSubview(titleBtn)
        titleBtn.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(bottomBarHeight)
        }
        showTitleButton = titleBtn

        // 关闭按钮
        let cancel = UIButton(type: .system)
        cancel.setBackgroundImage(UIImage(named: "任务卡－取消"), for: .normal)
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cardView.addSubview(cancel)
        cancel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.width.height.equalTo(15)
        }
        cancelButton = cancel

        // WebView 加载 mylineweb
        let webView = WKWebView()
        self.webView = webView
        cardView.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalTo(titleBtn.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-bottomBarHeight)
        }

        if let token = AccountManager.shared.token,
           let u = URL(string: APIHost.base + "index.php/home/myline/mylineweb/myline_id/\(mylineID)/tmp/\(token)") {
            webView.load(URLRequest(url: u))
        }

        // 好的按钮
        let ok = UIButton(type: .system)
        ok.setTitle("好的", for: .normal)
        ok.setTitleColor(UIColor(red: 0, green: 0.6, blue: 0.992, alpha: 1), for: .normal)
        ok.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        ok.addTarget(self, action: #selector(okTapped), for: .touchUpInside)
        cardView.addSubview(ok)
        ok.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(webView.snp.bottom)
        }
        showOKButton = ok
    }

    @objc private func okTapped() {
        // 与 OC 一致：reload 后移除
        webView?.reload()
        removeSelf()
    }

    @objc private func cancelTapped() {
        removeSelf()
    }

    /// 从父控制器移除
    private func removeSelf() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
