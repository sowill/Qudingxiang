//
//  TeamsViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXTeamsViewController.m：组队管理
//  - Section 0：扫一扫组队（点击弹出二维码弹层，请求 teamqrcode）
//  - Section 1：队名输入框
//  - Section 2：队长 + 4 个队员输入框
//  - 底部完成按钮：setTeam 提交
//
//  模型 Team / TeamList 已并入此文件。
//

import UIKit
import SnapKit
import SDWebImage
import MBProgressHUD
import Alamofire

// MARK: - 模型

struct TeamMember {
    var mylineID: String   // myline_id
    var cn: String         // team_cn
    var id: String         // team_id
    var leader: String     // team_leader

    init(from dict: [String: Any]) {
        mylineID = (dict["myline_id"]   as? String) ?? ""
        cn       = (dict["team_cn"]     as? String) ?? ""
        id       = (dict["team_id"]     as? String) ?? ""
        leader   = (dict["team_leader"] as? String) ?? ""
    }
}

// MARK: - TeamsAPI

enum TeamsAPI {
    /// 获取当前 myline 的队伍信息
    static func getTeam(mylineID: String,
                        completion: @escaping (Result<(teamName: String, members: [TeamMember]), APIError>) -> Void) {
        NetworkService.shared.requestJSON(
            path: APIPath.getTeam,
            parameters: ["myline_id": mylineID],
            needToken: false
        ) { result in
            switch result {
            case .success(let dict):
                if (dict["Code"] as? Int) == 0 {
                    completion(.failure(.business(
                        code: 0,
                        message: (dict["Msg"] as? String) ?? "获取失败"
                    )))
                } else {
                    let teamName = (dict["myline_team"] as? String) ?? ""
                    var members: [TeamMember] = []
                    if let arr = dict["teamArray"] as? [[String: Any]] {
                        members = arr.map { TeamMember(from: $0) }
                    } else if let arr = dict["Msg"] as? [[String: Any]] {
                        members = arr.map { TeamMember(from: $0) }
                    }
                    completion(.success((teamName, members)))
                }
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }

    /// 获取组队二维码 URL
    static func teamQRCode(mylineID: String,
                           completion: @escaping (Result<String, APIError>) -> Void) {
        NetworkService.shared.requestJSON(
            path: APIPath.teamqrcode,
            parameters: ["myline_id": mylineID],
            needToken: false
        ) { result in
            switch result {
            case .success(let dict):
                if (dict["Code"] as? Int) == 0 {
                    completion(.failure(.business(
                        code: 0,
                        message: (dict["Msg"] as? String) ?? "获取二维码失败"
                    )))
                } else if let url = dict["Msg"] as? String {
                    completion(.success(url))
                } else {
                    completion(.failure(.invalidResponse))
                }
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }

    /// 提交队伍信息
    static func setTeam(mylineID: String,
                        teamName: String,
                        members: [String],
                        completion: @escaping (Result<Void, APIError>) -> Void) {
        var params: [String: Any] = [
            "myline_id": mylineID,
            "myline_team": teamName
        ]
        // members[0] 是队长，对应 team_cn；members[1..] 是队员，对应 team_cn2..5
        // 与 OC 一致：索引 1 -> team_cn, 2 -> team_cn2, ..., 5 -> team_cn5
        let keys = ["team_cn", "team_cn2", "team_cn3", "team_cn4", "team_cn5"]
        for (idx, name) in members.enumerated() where idx < keys.count && !name.isEmpty {
            params[keys[idx]] = name
        }
        NetworkService.shared.requestJSON(path: APIPath.setTeam, parameters: params) { result in
            switch result {
            case .success(let dict):
                if (dict["Code"] as? Int) == 0 {
                    completion(.failure(.business(
                        code: 0,
                        message: (dict["Msg"] as? String) ?? "提交失败"
                    )))
                } else {
                    completion(.success(()))
                }
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }
}

// MARK: - TeamsViewController

final class TeamsViewController: BaseViewController {

    /// 当前 myline ID（外部注入）
    var mylineID: String = ""

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let completeButton = UIButton(type: .system)

    /// 数据源：[0] 队名，[1] 队长，[2..5] 队员
    private var names: [String] = ["", "", "", "", "", ""]

    // 二维码弹层
    private var bgView: UIView?
    private var deliverView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "组队"
        view.backgroundColor = QDXColor.background

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TeamInputCell.self, forCellReuseIdentifier: TeamInputCell.reuseID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ScanCell")
        tableView.backgroundColor = QDXColor.background
        tableView.rowHeight = Screen.fit(120)
        tableView.tableFooterView = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tableView.addGestureRecognizer(tap)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }

        completeButton.setTitle("完成", for: .normal)
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.backgroundColor = QDXColor.primary
        completeButton.layer.cornerRadius = 8
        completeButton.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)
        view.addSubview(completeButton)
        completeButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-Screen.safeAreaBottom - 20)
            make.height.equalTo(44)
        }

        loadData()
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    private func loadData() {
        TeamsAPI.getTeam(mylineID: mylineID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    self.names[0] = data.teamName
                    for (idx, m) in data.members.enumerated() where idx + 1 < self.names.count {
                        self.names[idx + 1] = m.cn
                    }
                    self.tableView.reloadData()
                case .failure(let e):
                    self.showToast(e.localizedDescription)
                }
            }
        }
    }

    @objc private func completeTapped() {
        view.endEditing(true)
        let teamName = names[0]
        let members = Array(names.dropFirst())
        TeamsAPI.setTeam(mylineID: mylineID, teamName: teamName, members: members) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.navigationController?.popViewController(animated: true)
                case .failure(let e):
                    self.showToast(e.localizedDescription)
                }
            }
        }
    }

    // MARK: - 扫一扫组队

    private func showQRCode() {
        TeamsAPI.teamQRCode(mylineID: mylineID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let url):
                    self.presentQRCode(url: url)
                case .failure(let e):
                    self.showToast(e.localizedDescription)
                }
            }
        }
    }

    private func presentQRCode(url: String) {
        let bg = UIView(frame: view.bounds)
        bg.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissQRCode))
        bg.addGestureRecognizer(tap)
        view.addSubview(bg)
        bgView = bg

        let cardW = Screen.fit(560)
        let cardH = Screen.fit(480)
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 8
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.clear.cgColor
        view.addSubview(card)
        card.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(cardW)
            make.height.equalTo(cardH)
        }
        deliverView = card

        let title = UILabel()
        title.text = "请队员扫描以下二维码组队"
        title.textColor = QDXColor.black
        title.font = .systemFont(ofSize: 14)
        title.textAlignment = .center
        card.addSubview(title)
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen.fit(36))
            make.centerX.equalToSuperview()
        }

        let qr = UIImageView()
        qr.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "加载中-1"))
        qr.contentMode = .scaleAspectFit
        card.addSubview(qr)
        qr.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(Screen.fit(36))
            make.centerX.equalToSuperview()
            make.width.height.equalTo(Screen.fit(340))
        }
    }

    @objc private func dismissQRCode() {
        bgView?.removeFromSuperview()
        deliverView?.removeFromSuperview()
        bgView = nil
        deliverView = nil
    }

    private func showToast(_ text: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = text
        hud.mode = .text
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1.5)
    }
}

// MARK: - UITableViewDataSource / Delegate

extension TeamsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 2 ? 5 : 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Screen.fit(20)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.961, alpha: 1.0)
        return v
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScanCell", for: indexPath)
            cell.selectionStyle = .none
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }

            let bg = UIView()
            bg.backgroundColor = .white
            cell.contentView.addSubview(bg)
            bg.snp.makeConstraints { $0.edges.equalToSuperview() }

            let label = UILabel()
            label.text = "扫一扫组队"
            label.textColor = QDXColor.black
            label.font = .systemFont(ofSize: 16)
            bg.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(Screen.fit(30))
                make.centerY.equalToSuperview()
            }

            let icon = UIImageView(image: UIImage(named: "二维码"))
            bg.addSubview(icon)
            icon.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-Screen.fit(30))
                make.centerY.equalToSuperview()
                make.width.height.equalTo(Screen.fit(48))
            }
            return cell
        }

        // 输入框 cell
        let cell = tableView.dequeueReusableCell(withIdentifier: TeamInputCell.reuseID, for: indexPath) as! TeamInputCell
        cell.onTextChange = { [weak self] text in
            guard let self = self else { return }
            if indexPath.section == 1 {
                self.names[0] = text
            } else if indexPath.section == 2 {
                self.names[indexPath.row + 1] = text
            }
        }

        if indexPath.section == 1 {
            cell.configure(title: "队名：", placeholder: "请输入队伍名称", text: names[0])
        } else {
            let title = indexPath.row == 0 ? "队长：" : "队员："
            cell.configure(title: title, placeholder: "请输入昵称", text: names[indexPath.row + 1])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            showQRCode()
        }
    }
}

// MARK: - TeamInputCell（替代 TextFieldTableViewCell + UITextField+IndexPath）

final class TeamInputCell: UITableViewCell {

    static let reuseID = "TeamInputCell"

    var onTextChange: ((String) -> Void)?

    private let titleLabel = UILabel()
    private let textField = UITextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white

        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = QDXColor.black
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen.fit(30))
            make.centerY.equalToSuperview()
            make.width.equalTo(Screen.fit(120))
        }

        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = QDXColor.gray
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        contentView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(8)
            make.right.equalToSuperview().offset(-Screen.fit(30))
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, placeholder: String, text: String) {
        titleLabel.text = title
        textField.placeholder = placeholder
        textField.text = text
    }

    @objc private func textChanged() {
        onTextChange?(textField.text ?? "")
    }
}
