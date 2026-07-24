//
//  MiscControllers.swift
//  趣定向 (Swift 迁移版)
//
//  集中迁移剩余零散控制器：
//  - QDXBindViewController       → BindPhoneViewController（QQ/微信绑定手机）
//  - QDXProtocolViewController   → ProtocolViewController（活动协议 + 同意进入游戏）
//  - QDXTicketSuccessViewController → TicketSuccessViewController（门票核销成功）
//  - HelpViewController          → HelpViewController（WKWebView 加载帮助页）
//  - NoticeViewController        → NoticeViewController（活动须知 WebView）
//
//  CheckDataTool 已迁移为 Validator；QDXStateView 已在 UIKitExtensions.swift 提供。
//

import UIKit
import SnapKit
import WebKit
import MBProgressHUD
import Alamofire

// MARK: - BindPhoneViewController（替代 QDXBindViewController）

/// QQ/微信授权后绑定手机号
final class BindPhoneViewController: BaseViewController {

    /// 外部传入：QQ openid
    var qqOpenid: String = ""
    /// 外部传入：微信 openid
    var wxOpenid: String = ""

    private let phoneField = UITextField()
    private let passwordField = UITextField()
    private let commitButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "绑定手机"
        view.backgroundColor = QDXColor.white

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "注册", style: .plain, target: self, action: #selector(registerTapped)
        )

        setupForm()
    }

    private func setupForm() {
        phoneField.placeholder = "请输入手机号"
        phoneField.borderStyle = .none
        phoneField.font = .systemFont(ofSize: 16)
        phoneField.textColor = UIColor(white: 0.4, alpha: 1.0)
        phoneField.keyboardType = .numberPad
        phoneField.backgroundColor = .white
        phoneField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        phoneField.leftViewMode = .always
        view.addSubview(phoneField)
        phoneField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen.navBarHeight + 20)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(40)
        }

        addUnderline(below: phoneField)

        passwordField.placeholder = "请输入密码"
        passwordField.borderStyle = .none
        passwordField.font = .systemFont(ofSize: 16)
        passwordField.textColor = UIColor(white: 0.4, alpha: 1.0)
        passwordField.isSecureTextEntry = true
        passwordField.backgroundColor = .white
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        passwordField.leftViewMode = .always
        view.addSubview(passwordField)
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(phoneField.snp.bottom).offset(20)
            make.left.right.height.equalTo(phoneField)
        }
        addUnderline(below: passwordField)

        commitButton.setTitle("提交", for: .normal)
        commitButton.setTitleColor(.white, for: .normal)
        commitButton.backgroundColor = QDXColor.primary
        commitButton.layer.cornerRadius = 8
        commitButton.addTarget(self, action: #selector(commitTapped), for: .touchUpInside)
        view.addSubview(commitButton)
        commitButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(25)
            make.left.right.equalTo(passwordField)
            make.height.equalTo(40)
        }
    }

    private func addUnderline(below view: UIView) {
        let line = UIView()
        line.backgroundColor = UIColor(white: 0.875, alpha: 1.0)
        self.view.addSubview(line)
        line.snp.makeConstraints { make in
            make.top.equalTo(view.snp.bottom)
            make.left.right.equalTo(view)
            make.height.equalTo(1)
        }
    }

    @objc private func registerTapped() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func commitTapped() {
        view.endEditing(true)
        let phone = phoneField.text ?? ""
        let pwd = passwordField.text ?? ""

        NetworkService.shared.requestJSON(
            path: APIPath.bind,
            parameters: [
                "customer_code": phone,
                "customer_pwd":  pwd,
                "customer_qid":  qqOpenid,
                "customer_wxid": wxOpenid
            ],
            needToken: false
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let dict):
                    if (dict["Code"] as? Int) == 1 {
                        self.showToast("绑定成功")
                        self.qqAndWxLogin()
                    } else {
                        self.showToast((dict["Msg"] as? String) ?? "绑定失败")
                    }
                case .failure(let e):
                    self.showToast(e.localizedDescription)
                }
            }
        }
    }

    /// 绑定成功后用 QQ/微信 openid 直接登录
    private func qqAndWxLogin() {
        NetworkService.shared.requestJSON(
            path: APIPath.qvLogin,
            parameters: [
                "customer_qid":  qqOpenid,
                "customer_wxid": wxOpenid
            ],
            needToken: false
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let dict):
                    if (dict["Code"] as? Int) == 1,
                       let msg = dict["Msg"] as? [String: Any],
                       let token = msg["customer_token"] as? String {
                        AccountManager.shared.saveToken(token)
                        NotificationCenter.default.post(name: .stateRefresh, object: nil)
                        self.showToast("登录成功")
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure:
                    self.showToast("登录失败")
                }
            }
        }
    }

    private func showToast(_ text: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = text
        hud.mode = .text
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1.5)
    }
}

// MARK: - ProtocolViewController（替代 QDXProtocolViewController）

/// 活动协议页：阅读协议 → 同意后进入游戏
final class ProtocolViewController: BaseViewController {

    /// 当前线路 ID（同意后进入游戏）
    var mylineID: String = ""

    private let webView = WKWebView()
    private let acceptButton = UIButton(type: .system)
    private let declineButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "协议"
        view.backgroundColor = QDXColor.background

        webView.scrollView.showsVerticalScrollIndicator = false
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-110)
        }

        declineButton.setTitle("拒绝", for: .normal)
        declineButton.setTitleColor(QDXColor.gray, for: .normal)
        declineButton.layer.borderWidth = 1
        declineButton.layer.borderColor = QDXColor.gray.cgColor
        declineButton.addTarget(self, action: #selector(declineTapped), for: .touchUpInside)
        view.addSubview(declineButton)
        declineButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-Screen.safeAreaBottom - 20)
            make.height.equalTo(40)
            make.width.equalTo((Screen.width - 30) / 2)
        }

        acceptButton.setTitle("同意", for: .normal)
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.backgroundColor = QDXColor.primary
        acceptButton.layer.cornerRadius = 4
        acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        view.addSubview(acceptButton)
        acceptButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.bottom.height.width.equalTo(declineButton)
        }

        loadProtocol()
    }

    private func loadProtocol() {
        NetworkService.shared.requestJSON(
            path: APIPath.portocol,
            parameters: [:],
            needToken: false
        ) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let dict) = result,
                   let html = dict["Msg"] as? String {
                    self?.webView.loadHTMLString(html, baseURL: nil)
                }
            }
        }
    }

    @objc private func declineTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func acceptTapped() {
        // 清理旧的当前线路缓存
        let path = (QDXPath.documents as NSString).appendingPathComponent("QDXCurrentMyLine.data")
        try? FileManager.default.removeItem(atPath: path)
        try? mylineID.write(toFile: QDXPath.currentMyLine, atomically: true, encoding: .utf8)

        let game = BaseGameViewController()
        game.mylineID = mylineID
        navigationController?.pushViewController(game, animated: true)
    }
}

// MARK: - TicketSuccessViewController（替代 QDXTicketSuccessViewController）

/// 门票核销成功页：点击「参加活动」拉取当前 myline 并进入游戏
final class TicketSuccessViewController: BaseViewController {

    /// 已有 mylineID 时直接进入，否则请求 getMyline
    var mylineID: String = ""

    private let stateView: QDXStateView

    init() {
        stateView = QDXStateView(
            frame: .zero,
            image: UIImage(named: "order_success"),
            detail: "活动票使用成功",
            buttonTitle: "参加活动"
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "使用成功"
        view.backgroundColor = QDXColor.white

        view.addSubview(stateView)
        stateView.snp.makeConstraints { $0.edges.equalToSuperview() }
        stateView.onTapButton = { [weak self] in self?.joinActivity() }
    }

    private func joinActivity() {
        NetworkService.shared.requestJSON(path: APIPath.getMyline) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let dict):
                    if (dict["Code"] as? Int) == 0 {
                        let alert = UIAlertController(
                            title: "提示",
                            message: (dict["Msg"] as? String) ?? "",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
                        self.present(alert, animated: true)
                    } else if let lineID = dict["Msg"] as? String {
                        if self.mylineID.isEmpty {
                            let vc = ProtocolViewController()
                            vc.mylineID = lineID
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            let game = BaseGameViewController()
                            game.mylineID = lineID
                            self.navigationController?.pushViewController(game, animated: true)
                        }
                    }
                case .failure(let e):
                    self.showToast(e.localizedDescription)
                }
            }
        }
    }

    private func showToast(_ text: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = text
        hud.mode = .text
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1.5)
    }
}

// MARK: - HelpViewController（替代 HelpViewController）

/// 帮助页：WKWebView 加载 helpUrl，注册 JS Success 回调
final class HelpViewController: BaseViewController {

    private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.mediaPlaybackRequiresUserAction = false
        config.allowsInlineMediaPlayback = true
        let userCC = WKUserContentController()
        // JS 调用 OC：window.webkit.messageHandlers.Success.postMessage(...)
        // 处理器在 viewDidLoad 后注册
        return WKWebView(frame: .zero, configuration: config)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "帮助"
        view.backgroundColor = QDXColor.white

        webView.configuration.userContentController.add(self, name: "Success")
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-15)
        }

        let url = APIHost.base + APIPath.help
        if let u = URL(string: url) {
            webView.load(URLRequest(url: u))
        }
    }
}

extension HelpViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if message.name == "Success" {
            // 与 OC 一致：暂无处理逻辑，留作扩展点
        }
    }
}

// MARK: - NoticeViewController（替代 NoticeViewController）

/// 活动须知页：从后端拉取 HTML 渲染（替代 OC 静态表格 + UIWebView 实现）
final class NoticeViewController: BaseViewController {

    private let webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "活动须知"
        view.backgroundColor = QDXColor.white

        webView.scrollView.showsVerticalScrollIndicator = false
        webView.backgroundColor = .clear
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Screen.navBarHeight)
        }

        loadNotice()
    }

    private func loadNotice() {
        NetworkService.shared.requestJSON(
            path: APIPath.portocol,
            parameters: [:],
            needToken: false
        ) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let dict) = result,
                   let html = dict["Msg"] as? String {
                    self?.webView.loadHTMLString(html, baseURL: nil)
                }
            }
        }
    }
}

// MARK: - Notification.Name 扩展

extension Notification.Name {
    /// 状态刷新通知（替代 OC 字符串 @"stateRefresh"）
    static let stateRefresh = Notification.Name("stateRefresh")
}
