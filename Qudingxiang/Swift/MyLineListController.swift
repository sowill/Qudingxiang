//
//  MyLineListController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 MineLineController.m + TeamLineController.m：
//  我的线路 / 团队线路 列表（按模式区分）
//

import UIKit
import SnapKit
import MJRefresh

final class MyLineListController: BaseViewController {

    enum Mode {
        case personal   // 我的线路
        case team       // 团队线路

        var title: String { self == .personal ? "我的线路" : "团队线路" }
    }

    let mode: Mode

    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    private var items: [Myline] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = mode.title
        setupTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if items.isEmpty { loadData() }
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MyLineCell.self, forCellReuseIdentifier: MyLineCell.reuseID)
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableView.automaticDimension
        let header = MJRefreshNormalHeader { [weak self] in self?.loadData() }
        header?.lastUpdatedTimeLabel?.isHidden = true
        tableView.mj_header = header
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func loadData() {
        let api = mode == .personal ? MineAPI.myLines : MineAPI.teamLines
        api { [weak self] result in
            DispatchQueue.main.async {
                self?.tableView.mj_header?.endRefreshing()
                switch result {
                case .success(let list):
                    self?.items = list
                    self?.tableView.reloadData()
                    if list.isEmpty { self?.showEmpty("暂无线路") } else { self?.hideEmpty() }
                case .failure(let err):
                    self?.showToast(err.localizedDescription)
                }
            }
        }
    }
}

extension MyLineListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyLineCell.reuseID, for: indexPath) as! MyLineCell
        cell.configure(with: items[indexPath.row], isTeam: mode == .team)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let id = items[indexPath.row].id else { return }
        let vc = BaseGameViewController()
        vc.mylineID = id
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - 线路 Cell
final class MyLineCell: UITableViewCell {
    static let reuseID = "MyLineCell"
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let teamLabel = UILabel()
    private let dateLabel = UILabel()
    private let scoreLabel = UILabel()
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
        titleLabel.font = QDXFont.semibold(30); titleLabel.textColor = QDXColor.black
        cardView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        teamLabel.font = QDXFont.regular(22); teamLabel.textColor = QDXColor.gray
        cardView.addSubview(teamLabel)
        teamLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
        dateLabel.font = QDXFont.regular(22); dateLabel.textColor = QDXColor.lightGray
        cardView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.left.equalTo(teamLabel.snp.right).offset(12)
            make.centerY.equalTo(teamLabel)
        }
        scoreLabel.font = QDXFont.bold(28); scoreLabel.textColor = QDXColor.accent
        cardView.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-12)
        }
        statusBadge.font = QDXFont.medium(20); statusBadge.textColor = .white
        statusBadge.backgroundColor = QDXColor.green
        statusBadge.textAlignment = .center
        statusBadge.layer.cornerRadius = 4
        statusBadge.layer.masksToBounds = true
        cardView.addSubview(statusBadge)
        statusBadge.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(scoreLabel)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(44)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with m: Myline, isTeam: Bool) {
        titleLabel.text = m.lineCn
        teamLabel.text  = isTeam ? "队名：" + (m.team ?? "—") : "玩家：" + (m.customerCn ?? "—")
        dateLabel.text  = m.adate
        scoreLabel.text = "成绩 " + (m.score ?? "—")
        statusBadge.text = m.statusCn ?? "—"
    }
}
