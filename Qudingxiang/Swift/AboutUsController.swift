//
//  AboutUsController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 AboutUsViewController.m：关于趣定向
//  - Logo + 版本号 + 简介
//  - 活动须知（WebView）
//  - 点标管理（仅 level != "0" 显示）
//

import UIKit
import SnapKit
import WebKit

final class AboutUsController: BaseViewController {

    /// 用户等级（"0"=普通用户，不显示点标管理）
    var level: String?

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let versionString: String = {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return "V\(v)"
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "关于趣定向"
        setupTableView()
        setupFooter()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 280
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func setupFooter() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: Screen.width, height: 60))
        let label = UILabel()
        label.text = "趣定向体育科技发展(上海)有限公司"
        label.font = QDXFont.regular(22)
        label.textColor = QDXColor.gray
        label.textAlignment = .center
        footer.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        tableView.tableFooterView = footer
    }
}

extension AboutUsController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        level == "0" ? 2 : 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.accessoryType = .none
        // 清理旧视图
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        if indexPath.section == 0 {
            // Logo + 版本 + 简介
            let logo = UIImageView(image: UIImage(named: "icon"))
            logo.contentMode = .scaleAspectFit
            cell.contentView.addSubview(logo)
            logo.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(30)
                make.centerX.equalToSuperview()
                make.width.height.equalTo(80)
            }
            let version = UILabel()
            let attr = NSMutableAttributedString()
            attr.append(NSAttributedString(
                string: "当前版本 ",
                attributes: [.font: QDXFont.regular(24), .foregroundColor: QDXColor.gray]
            ))
            attr.append(NSAttributedString(
                string: versionString,
                attributes: [.font: QDXFont.regular(24), .foregroundColor: QDXColor.primary]
            ))
            version.attributedText = attr
            version.textAlignment = .center
            cell.contentView.addSubview(version)
            version.snp.makeConstraints { make in
                make.top.equalTo(logo.snp.bottom).offset(12)
                make.centerX.equalToSuperview()
            }
            let des = UILabel()
            des.numberOfLines = 0
            des.font = QDXFont.regular(26)
            des.textColor = QDXColor.gray
            let para = NSMutableParagraphStyle()
            para.lineSpacing = 4
            para.firstLineHeadIndent = 28
            des.attributedText = NSAttributedString(
                string: "趣定向是国内首家定向运动互联网增值服务平台运营商，同时也是国内最大的城市定向系列赛事的发起者和组织者。以'趣定向，趣生活'为理念，倡导全民户外定向运动。现已覆盖上海多家公园。",
                attributes: [.font: QDXFont.regular(26), .foregroundColor: QDXColor.gray, .paragraphStyle: para]
            )
            cell.contentView.addSubview(des)
            des.snp.makeConstraints { make in
                make.top.equalTo(version.snp.bottom).offset(20)
                make.left.right.equalToSuperview().inset(24)
                make.bottom.equalToSuperview().offset(-20)
            }
        } else if indexPath.section == 1 {
            cell.textLabel?.text = "活动须知"
            cell.textLabel?.font = QDXFont.regular(28)
            cell.textLabel?.textColor = QDXColor.black
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.textLabel?.text = "点标管理"
            cell.textLabel?.font = QDXFont.regular(28)
            cell.textLabel?.textColor = QDXColor.black
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let vc = WebViewController()
            vc.url = APIHost.base + APIPath.help
            vc.title = "活动须知"
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 2 {
            showToast("点标管理待接入")
        }
    }
}

// MARK: - 通用 WebView 控制器（替代原 UIWebView 加载网页）
final class WebViewController: BaseViewController {
    var url: String?
    var title_: String?
    private let webView = WKWebView()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = title_
        view.addSubview(webView)
        webView.snp.makeConstraints { $0.edges.equalToSuperview() }
        if let urlString = url, let u = URL(string: urlString) {
            webView.load(URLRequest(url: u))
        }
    }
}
