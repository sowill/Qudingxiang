//
//  OrderDetailViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXOrderDetailTableViewController.m：订单详情 + 门票使用信息 + 去支付按钮
//

import UIKit
import SnapKit
import SDWebImage

final class OrderDetailViewController: BaseViewController {

    var order: Orders?

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let bottomBar = UIView()
    private let payButton = PrimaryButton(title: "立即支付", enabled: false)
    private var orderInfos: [OrderInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "订单详情"
        setupTableView()
        setupBottomBar()
        loadData()
        // 监听支付完成刷新
        NotificationCenter.default.addObserver(
            self, selector: #selector(loadData),
            name: NSNotification.Name("pay"), object: nil
        )
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(InfoCell.self, forCellReuseIdentifier: InfoCell.reuseID)
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-80)
        }
    }

    private func setupBottomBar() {
        bottomBar.backgroundColor = .white
        view.addSubview(bottomBar)
        bottomBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(80 + Screen.safeAreaBottom)
        }
        let line = UIView(); line.backgroundColor = QDXColor.lineColor
        bottomBar.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview(); make.height.equalTo(0.5)
        }
        bottomBar.addSubview(payButton)
        payButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview().offset(-Screen.safeAreaBottom/2)
            make.width.equalTo(140); make.height.equalTo(44)
        }
        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)

        // 仅待支付显示
        if order?.statusID == "1" {
            payButton.isEnabled = true
        } else {
            payButton.isHidden = true
        }
    }

    @objc private func loadData() {
        guard let orderID = order?.id else { return }
        OrderAPI.detail(orderID: orderID) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let list) = result {
                    self?.orderInfos = list
                    self?.tableView.reloadData()
                }
            }
        }
    }

    @objc private func payTapped() {
        guard let order = order else { return }
        let pay = PayViewController()
        pay.order = order
        let nav = QDXNavigationController(rootViewController: pay)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

extension OrderDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : orderInfos.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "订单信息" : "门票使用记录"
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.reuseID, for: indexPath) as! InfoCell
        if indexPath.section == 0 {
            cell.configureOrder(order)
        } else {
            cell.configureOrderInfo(orderInfos[indexPath.row])
        }
        return cell
    }
}

// MARK: - 信息 Cell
final class InfoCell: UITableViewCell {
    static let reuseID = "InfoCell"
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let qrcodeImage = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        titleLabel.font = QDXFont.regular(28); titleLabel.textColor = QDXColor.gray
        valueLabel.font = QDXFont.medium(28); valueLabel.textColor = QDXColor.black
        valueLabel.textAlignment = .right
        qrcodeImage.contentMode = .scaleAspectFit
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(qrcodeImage)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16); make.centerY.equalToSuperview()
        }
        valueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16); make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(12)
        }
        qrcodeImage.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16); make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configureOrder(_ o: Orders?) {
        qrcodeImage.isHidden = true
        valueLabel.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-16); make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(12)
        }
        titleLabel.text = "订单金额"
        valueLabel.text = "¥ \(o?.account ?? o?.amount ?? "0")"
    }
    func configureOrderInfo(_ info: OrderInfo) {
        qrcodeImage.isHidden = false
        valueLabel.snp.remakeConstraints { make in
            make.right.equalTo(qrcodeImage.snp.left).offset(-8); make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(12)
        }
        titleLabel.text = info.udate ?? "—"
        valueLabel.text = info.statusCn ?? "—"
        if let qr = info.qrcode, let url = URL(string: qr) {
            qrcodeImage.sd_setImage(with: url)
        }
    }
}
