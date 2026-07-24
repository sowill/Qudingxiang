//
//  SettingController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 SettingViewController.m：清除缓存 / 修改密码 / 退出登录
//

import UIKit
import SnapKit

final class SettingController: BaseViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var cacheSize: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "设置"
        setupTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cacheSize = calcCacheSize()
        tableView.reloadData()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 56
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - 缓存
    private func cachePath() -> String {
        NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }
    private func calcCacheSize() -> Double {
        let path = cachePath()
        let fm = FileManager.default
        guard fm.fileExists(atPath: path),
              let files = fm.subpaths(atPath: path) else { return 0 }
        var size: Double = 0
        for f in files {
            if let attr = try? fm.attributesOfItem(atPath: path + "/" + f),
               let s = attr[.size] as? Int {
                size += Double(s) / 1024.0 / 1024.0
            }
        }
        return size
    }
    private func clearCache() {
        let path = cachePath()
        let fm = FileManager.default
        guard let files = fm.subpaths(atPath: path) else { return }
        for f in files where !f.hasSuffix(".png") {
            try? fm.removeItem(atPath: path + "/" + f)
        }
        cacheSize = calcCacheSize()
        tableView.reloadData()
    }
}

extension SettingController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 2 : 1
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.font = QDXFont.regular(28)
        cell.textLabel?.textColor = QDXColor.black
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.accessoryView = nil

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "清除图片缓存"
                let badge = UILabel()
                badge.text = String(format: "%.2fMB", cacheSize)
                badge.font = QDXFont.regular(24)
                badge.textColor = QDXColor.gray
                badge.sizeToFit()
                cell.accessoryView = badge
            } else {
                cell.textLabel?.text = "修改密码"
                cell.accessoryType = .disclosureIndicator
            }
        } else {
            cell.textLabel?.text = "退出当前账号"
            cell.textLabel?.textColor = QDXColor.primary
            cell.textLabel?.textAlignment = .center
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                confirmClearCache()
            } else {
                navigationController?.pushViewController(ChangePasswordViewController(), animated: true)
            }
        } else {
            confirmLogout()
        }
    }

    private func confirmClearCache() {
        let alert = UIAlertController(
            title: "提示",
            message: String(format: "缓存大小:%.2fM,是否清除？", cacheSize),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            self?.clearCache()
            self?.showToast("缓存已清理")
        })
        present(alert, animated: true)
    }

    private func confirmLogout() {
        let alert = UIAlertController(
            title: "提示",
            message: "退出后不会删除任何历史数据,下次登录依然可以使用本账号",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "退出登录", style: .default) { [weak self] _ in
            AccountManager.shared.clear()
            NotificationCenter.default.post(name: NSNotification.Name("stateRefresh"), object: nil)
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
