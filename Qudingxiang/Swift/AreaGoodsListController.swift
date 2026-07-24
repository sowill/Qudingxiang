//
//  AreaGoodsListController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXActivityPriceViewController：某场地下的产品 / 活动列表
//

import UIKit
import SnapKit
import MJRefresh

final class AreaGoodsListController: BaseViewController {

    /// 当前场地
    var area: Area?
    var type: String = "0"

    private var items: [Goods] = []
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = area?.cn ?? "场地"
        setupTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ActivityCell.self, forCellReuseIdentifier: ActivityCell.reuseID)
        tableView.estimatedRowHeight = 320
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = QDXColor.background
        let header = MJRefreshNormalHeader { [weak self] in self?.loadData() }
        header?.lastUpdatedTimeLabel?.isHidden = true
        tableView.mj_header = header
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func loadData() {
        guard let areaID = area?.id else { return }
        ContentAPI.goodsByArea(areaID: areaID) { [weak self] result in
            DispatchQueue.main.async {
                self?.tableView.mj_header?.endRefreshing()
                switch result {
                case .success(let list):
                    self?.items = list
                    self?.tableView.reloadData()
                    if list.isEmpty { self?.showEmpty("该场地暂无活动") } else { self?.hideEmpty() }
                case .failure(let err):
                    self?.showToast(err.localizedDescription)
                }
            }
        }
    }
}

extension AreaGoodsListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActivityCell.reuseID, for: indexPath) as! ActivityCell
        cell.configure(with: items[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detail = LineDetailViewController()
        detail.goods = items[indexPath.row]
        navigationController?.pushViewController(detail, animated: true)
    }
}
