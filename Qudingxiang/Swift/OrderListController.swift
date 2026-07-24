//
//  OrderListController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 OrderController.m：顶部状态分段 + 子页 TableViewController 列表
//  视觉：现代化分段控件 + inset grouped 列表
//

import UIKit
import SnapKit
import SDWebImage
import MJRefresh

final class OrderListController: BaseViewController {

    private let segmented = UISegmentedControl(items: ["全部", "待支付", "已支付", "已完成"])
    private let containerView = UIView()
    private var current: Int = 0
    private var orders: [Orders] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "我的订单"
        setupSegmented()
        setupTableView()
        loadData()
    }

    private func setupSegmented() {
        segmented.selectedSegmentIndex = 0
        segmented.setTitleTextAttributes([
            .font: QDXFont.medium(26), .foregroundColor: QDXColor.gray
        ], for: .normal)
        segmented.setTitleTextAttributes([
            .font: QDXFont.semibold(26), .foregroundColor: QDXColor.primary
        ], for: .selected)
        view.addSubview(segmented)
        segmented.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }
        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(OrderCell.self, forCellReuseIdentifier: OrderCell.reuseID)
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        let header = MJRefreshNormalHeader { [weak self] in self?.loadData() }
        header?.lastUpdatedTimeLabel?.isHidden = true
        tableView.mj_header = header
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmented.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }
    }

    @objc private func segmentChanged() {
        current = segmented.selectedSegmentIndex
        loadData()
    }

    private func loadData() {
        OrderAPI.list(status: current) { [weak self] result in
            DispatchQueue.main.async {
                self?.tableView.mj_header?.endRefreshing()
                switch result {
                case .success(let list):
                    self?.orders = list
                    self?.tableView.reloadData()
                    if list.isEmpty { self?.showEmpty("暂无订单") } else { self?.hideEmpty() }
                case .failure(let err):
                    self?.showToast(err.localizedDescription)
                }
            }
        }
    }
}

extension OrderListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orders.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.reuseID, for: indexPath) as! OrderCell
        cell.configure(with: orders[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let order = orders[indexPath.row]
        let detail = OrderDetailViewController()
        detail.order = order
        navigationController?.pushViewController(detail, animated: true)
    }
}

// MARK: - 订单卡片
final class OrderCell: UITableViewCell {
    static let reuseID = "OrderCell"
    private let cardView    = UIView()
    private let coverView   = UIImageView()
    private let titleLabel  = UILabel()
    private let timeLabel   = UILabel()
    private let priceLabel  = UILabel()
    private let statusLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        coverView.contentMode = .scaleAspectFill
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = 8
        cardView.addSubview(coverView)
        coverView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(12)
            make.width.equalTo(80); make.height.equalTo(80)
        }
        titleLabel.font = QDXFont.semibold(30); titleLabel.textColor = QDXColor.black
        titleLabel.numberOfLines = 2
        cardView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(coverView.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
            make.top.equalTo(coverView).offset(4)
        }
        timeLabel.font = QDXFont.regular(22); timeLabel.textColor = QDXColor.gray
        cardView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
        priceLabel.font = QDXFont.bold(30); priceLabel.textColor = QDXColor.accent
        cardView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(coverView).offset(-4)
        }
        statusLabel.font = QDXFont.medium(22); statusLabel.textColor = QDXColor.green
        cardView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.bottom.equalTo(coverView)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with o: Orders) {
        titleLabel.text = o.goodsCn
        timeLabel.text  = o.cdate
        if let amount = o.account { priceLabel.text = "¥ \(amount)" }
        else if let am = o.amount { priceLabel.text = "¥ \(am)" }
        statusLabel.text = o.statusCn ?? "—"
        if let urlString = o.goodsURL, let url = URL(string: APIHost.oldBase + urlString) {
            coverView.sd_setImage(with: url)
        }
    }
}
