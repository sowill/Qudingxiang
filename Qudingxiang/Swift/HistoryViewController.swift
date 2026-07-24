//
//  HistoryViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXHistoryViewController.m：定向足迹列表 + 点开查看详情 WebView
//

import UIKit
import SnapKit
import WebKit

final class HistoryViewController: BaseViewController {

    /// 当前线路 ID
    var mylineID: String = ""

    private var history: [History] = []
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var popView: PopContainerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "定向足迹"
        setupTableView()
        loadData()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.reuseID)
        tableView.rowHeight = 73
        tableView.backgroundColor = QDXColor.background
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.bottom.equalToSuperview()
        }
    }

    private func loadData() {
        GameAPI.history(mylineID: mylineID) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let list) = result {
                    self?.history = list
                    self?.tableView.reloadData()
                    if list.isEmpty { self?.showEmpty("暂无足迹") } else { self?.hideEmpty() }
                }
            }
        }
    }
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        history.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.reuseID, for: indexPath) as! HistoryCell
        let h = history[history.count - 1 - indexPath.row]
        cell.configure(with: h)
        cell.viewHistory = { [weak self] in
            guard let id = h.pointmapID else { return }
            let url = APIHost.base + APIPath.pointhistory + "/pointmap_id/\(id)"
            self?.showDetail(url: url)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .white
        let label = UILabel()
        label.text = "定向足迹"
        label.font = QDXFont.medium(28)
        label.textColor = QDXColor.black
        header.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12); make.centerY.equalToSuperview()
        }
        let line = UIView(); line.backgroundColor = UIColor(white: 0.875, alpha: 1)
        header.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview(); make.height.equalTo(1)
        }
        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 40 }
}

private extension HistoryViewController {
    func showDetail(url: String) {
        let pop = PopContainerView()
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let wk = WKWebView(frame: .zero, configuration: config)
        if let u = URL(string: url) { wk.load(URLRequest(url: u)) }
        pop.setContentView(wk)
        pop.show(in: view)
        popView = pop
    }
}
