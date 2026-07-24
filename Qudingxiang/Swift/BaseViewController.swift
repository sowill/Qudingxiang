//
//  BaseViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 BaseViewController.m：统一返回按钮、网络监听、HUD、空数据占位
//

import UIKit
import SnapKit
import MBProgressHUD
import ReachabilitySwift

class BaseViewController: UIViewController {

    private var isLoading = false
    private var loadingHUD: MBProgressHUD?
    private var emptyView: UIView?
    private let reachability = try? Reachability()

    // 子类可重写
    func reloadData() {}

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = QDXColor.background
        setupBackButtonIfNeeded()
        startNetworkObservation()
    }

    deinit {
        stopNetworkObservation()
    }

    // MARK: - 返回按钮
    private func setupBackButtonIfNeeded() {
        let titles: Set<String> = ["首页", "发现", "订单", "我的"]
        if navigationItem.leftBarButtonItem == nil,
           let title = navigationItem.title, !titles.contains(title) {
            let backBtn = UIButton(type: .system)
            backBtn.setImage(UIImage(named: "close"), for: .normal)
            backBtn.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
            let item = UIBarButtonItem(customView: backBtn)
            let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            spacer.width = -10
            navigationItem.leftBarButtonItems = [spacer, item]
        }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }

    // MARK: - 网络监听
    private func startNetworkObservation() {
        guard let reachability = reachability else { return }
        NotificationCenter.default.addObserver(
            self, selector: #selector(networkChanged(_:)),
            name: .reachabilityChanged, object: reachability
        )
        try? reachability.startNotifier()
    }
    private func stopNetworkObservation() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
    }

    @objc private func networkChanged(_ note: Notification) {
        guard let r = note.object as? Reachability else { return }
        if r.connection == .none {
            showNoNetworkView()
        } else {
            view.subviews
                .filter { $0 is NoNetworkView }
                .forEach { $0.removeFromSuperview() }
        }
    }

    private func showNoNetworkView() {
        let v = NoNetworkView(frame: CGRect(x: 0, y: 0,
                                            width: Screen.width,
                                            height: Screen.height - Screen.tabBarHeight))
        view.addSubview(v)
    }

    // MARK: - HUD
    func showLoading(_ message: String? = nil) {
        guard !isLoading else { return }
        isLoading = true
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = message ?? "加载中..."
        hud.bezelView.color = UIColor(white: 0, alpha: 0.85)
        hud.contentColor = .white
        hud.margin = 16
        loadingHUD = hud
    }

    func hideLoading() {
        loadingHUD?.hide(animated: true)
        loadingHUD = nil
        isLoading = false
    }

    func showToast(_ message: String, icon: MBProgressHUDMode = .text) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = icon
        hud.label.text = message
        hud.bezelView.color = UIColor(white: 0, alpha: 0.85)
        hud.contentColor = .white
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1.5)
    }

    // MARK: - 空数据
    func showEmpty(_ message: String? = nil) {
        emptyView?.removeFromSuperview()
        let container = UIView()
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let icon = UIImageView(image: UIImage(named: "notdata.png"))
        icon.contentMode = .scaleAspectFit
        container.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.width.height.equalTo(60)
        }
        let label = UILabel()
        label.text = message ?? "无相关数据"
        label.textColor = QDXColor.gray
        label.font = QDXFont.regular(28)
        label.textAlignment = .center
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        emptyView = container
    }

    func hideEmpty() {
        emptyView?.removeFromSuperview()
        emptyView = nil
    }
}

// MARK: - 无网络占位视图
final class NoNetworkView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = QDXColor.background
        let icon = UIImageView(image: UIImage(named: "nonetwork.png"))
        icon.contentMode = .scaleAspectFit
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        let label = UILabel()
        label.text = "网络似乎开小差了"
        label.textColor = QDXColor.gray
        label.font = QDXFont.regular(28)
        label.textAlignment = .center
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}
