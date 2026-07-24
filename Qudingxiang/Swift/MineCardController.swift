//
//  MineCardController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 MineCardViewController.m：我的卡包列表 + 二维码弹层
//

import UIKit
import SnapKit
import MJRefresh
import SDWebImage

final class MineCardController: BaseViewController {

    private var cards: [Card] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "我的卡包"
        setupTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CardCell.self, forCellReuseIdentifier: CardCell.reuseID)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        let header = MJRefreshNormalHeader { [weak self] in self?.loadData() }
        header?.lastUpdatedTimeLabel?.isHidden = true
        tableView.mj_header = header
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func loadData() {
        MineAPI.cards { [weak self] result in
            DispatchQueue.main.async {
                self?.tableView.mj_header?.endRefreshing()
                switch result {
                case .success(let list):
                    self?.cards = list
                    self?.tableView.reloadData()
                    if list.isEmpty { self?.showEmpty("暂无卡片") } else { self?.hideEmpty() }
                case .failure(let err):
                    self?.showToast(err.localizedDescription)
                }
            }
        }
    }
}

extension MineCardController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { cards.count }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CardCell.reuseID, for: indexPath) as! CardCell
        cell.configure(with: cards[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showQRCode(for: cards[indexPath.row])
    }

    private func showQRCode(for card: Card) {
        guard let content = card.qrcode else { return }
        let bg = UIView(frame: view.bounds)
        bg.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        bg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissQR)))
        view.addSubview(bg)

        let card_ = UIView()
        card_.backgroundColor = .white
        card_.layer.cornerRadius = 12
        bg.addSubview(card_)
        card_.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(Screen.fit(560))
            make.height.equalTo(Screen.fit(480))
        }
        let title = UILabel()
        title.text = card.cn ?? "我的卡片"
        title.font = QDXFont.medium(28)
        title.textAlignment = .center
        card_.addSubview(title)
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen.fit(36))
            make.centerX.equalToSuperview()
        }
        let qr = QRCodeGenerator.image(from: content, size: Int(Screen.fit(340)))
        let iv = UIImageView(image: qr)
        card_.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(Screen.fit(36))
            make.centerX.equalToSuperview()
            make.width.height.equalTo(Screen.fit(340))
        }
    }
    @objc private func dismissQR() {
        view.subviews.last?.removeFromSuperview()
    }
}

// MARK: - 卡片 Cell
final class CardCell: UITableViewCell {
    static let reuseID = "CardCell"
    private let cardView = UIView()
    private let coverView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusBadge = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }
        coverView.contentMode = .scaleAspectFill
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = 8
        cardView.addSubview(coverView)
        coverView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(12)
            make.width.height.equalTo(76)
        }
        titleLabel.font = QDXFont.semibold(30); titleLabel.textColor = QDXColor.black
        cardView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(coverView.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
            make.top.equalTo(coverView).offset(8)
        }
        dateLabel.font = QDXFont.regular(22); dateLabel.textColor = QDXColor.gray
        cardView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
        statusBadge.font = QDXFont.medium(20); statusBadge.textColor = .white
        statusBadge.backgroundColor = QDXColor.green
        statusBadge.textAlignment = .center
        statusBadge.layer.cornerRadius = 4
        statusBadge.layer.masksToBounds = true
        cardView.addSubview(statusBadge)
        statusBadge.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(coverView).offset(-4)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(44)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with c: Card) {
        titleLabel.text = c.cn
        dateLabel.text = "有效期至：" + (c.vdate ?? "—")
        statusBadge.text = c.onoffID == "1" ? "可用" : "已用"
        if let urlString = c.url, let url = URL(string: APIHost.oldBase + urlString) {
            coverView.sd_setImage(with: url)
        }
    }
}
