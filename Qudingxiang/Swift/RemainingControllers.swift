//
//  RemainingControllers.swift
//  趣定向 (Swift 迁移版)
//
//  迁移剩余未被覆盖的 OC 控制器：
//  - MoreViewController           → MoreController（玩法介绍，3 种玩法分页展示）
//  - CellLineController           → AreaLineListController（区域路线列表，调 Line/getListAjax）
//  - QDXCreateCodeViewController  → CreateCodeViewController（注册前验证码：setVcode + validateCode → Register）
//
//  注：codeWebViewController 已由 AboutUsController.swift 中的通用 WebViewController 覆盖。
//

import UIKit
import SnapKit
import SDWebImage

// MARK: - MoreController（替代 MoreViewController）

/// 玩法介绍页：分页展示 3 种玩法（依次穿越 / 自由规划 / 自由挑战）
final class MoreController: BaseViewController {

    fileprivate struct PlayMode {
        let image: String
        let title: String
        let detail: String
    }

    private let modes: [PlayMode] = [
        PlayMode(image: "依次穿越", title: "依次穿越",
                 detail: "依次按提示依次到达各点标，直至终点，用时少胜。"),
        PlayMode(image: "自由规划", title: "自由规划",
                 detail: "一次性给出所有点标，自行规划线路，直至寻访所有点标，用时少胜。"),
        PlayMode(image: "自由挑战", title: "自由挑战",
                 detail: "一次性给出所有点标，在规定时间内，以寻访点标数量多为胜。")
    ]

    private let collectionView: UICollectionView
    private static let reuseID = "PlayModeCell"

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width,
                                 height: UIScreen.main.bounds.height - Screen.navBarHeight - Screen.tabBarHeight)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "玩法"
        view.backgroundColor = QDXColor.background

        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.register(PlayModeCell.self, forCellWithReuseIdentifier: Self.reuseID)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

extension MoreController: UICollectionViewDataSource {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection s: Int) -> Int { modes.count }
    func collectionView(_ cv: UICollectionView, cellForItemAt ip: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: Self.reuseID, for: ip) as! PlayModeCell
        cell.configure(with: modes[ip.item])
        return cell
    }
}

/// 玩法卡片：大图 + 标题 + 描述
final class PlayModeCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(Screen.fit(574))
        }

        titleLabel.font = QDXFont.bold(40)
        titleLabel.textColor = QDXColor.primary
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
        }

        detailLabel.font = QDXFont.regular(28)
        detailLabel.textColor = QDXColor.gray
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(32)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with mode: MoreController.PlayMode) {
        imageView.image = UIImage(named: mode.image)
        titleLabel.text = mode.title
        detailLabel.text = mode.detail
    }
}

// MARK: - AreaLineListController（替代 CellLineController）

/// 区域路线列表：按场地拉取路线列表，点击进入线路详情
final class AreaLineListController: BaseViewController {

    /// 外部传入：场地 ID
    var areaID: String = ""

    private var lines: [Line] = []
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "路线选择"
        view.backgroundColor = QDXColor.background

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = .zero
        tableView.showsVerticalScrollIndicator = false
        tableView.register(AreaLineCell.self, forCellReuseIdentifier: "AreaLineCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }

        loadData()
    }

    override func reloadData() { loadData() }

    private func loadData() {
        guard !areaID.isEmpty else { return }
        showLoading()
        ContentAPI.linesByArea(areaID: areaID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case .success(let list):
                    self.lines = list
                    self.tableView.reloadData()
                    if list.isEmpty {
                        self.showEmpty("没有有效信息，敬请期待")
                    } else {
                        self.hideEmpty()
                    }
                case .failure(let e):
                    self.showToast(e.localizedDescription)
                }
            }
        }
    }
}

extension AreaLineListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection s: Int) -> Int { lines.count }

    func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "AreaLineCell", for: ip) as! AreaLineCell
        cell.configure(with: lines[ip.row])
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tv: UITableView, heightForRowAt ip: IndexPath) -> CGFloat { 64 }

    func tableView(_ tv: UITableView, didSelectRowAt ip: IndexPath) {
        tv.deselectRow(at: ip, animated: true)
        let vc = LineDetailViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

/// 区域路线 Cell
final class AreaLineCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let iconView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        iconView.contentMode = .scaleAspectFit
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        titleLabel.font = QDXFont.medium(30)
        titleLabel.textColor = QDXColor.black
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(12)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with line: Line) {
        titleLabel.text = line.cn
        iconView.image = UIImage(named: "j\(0)")
    }
}

// MARK: - CreateCodeViewController（替代 QDXCreateCodeViewController）

/// 注册前验证码页：手机号 + 验证码 → 校验通过后跳注册页
final class CreateCodeViewController: BaseViewController {

    private let phoneField   = FormField(placeholder: "请输入手机号码", keyboardType: .numberPad)
    private let codeField    = FormField(placeholder: "请输入短信验证码", keyboardType: .numberPad)
    private let getCodeBtn   = UIButton(type: .system)
    private let nextButton   = PrimaryButton(title: "下一步")
    private let rulesButton  = UIButton(type: .system)

    private var countdown = 0
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "获取验证码"
        setupUI()
    }
    deinit { timer?.invalidate() }

    private func setupUI() {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 16
        view.addSubview(card)
        card.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }

        card.addSubview(phoneField)
        phoneField.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56)
        }

        let codeRow = UIView()
        card.addSubview(codeRow)
        codeRow.snp.makeConstraints { make in
            make.top.equalTo(phoneField.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
            make.bottom.equalToSuperview()
        }
        codeRow.addSubview(codeField)
        codeField.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-110)
        }
        getCodeBtn.setTitle("获取验证码", for: .normal)
        getCodeBtn.titleLabel?.font = QDXFont.medium(26)
        getCodeBtn.setTitleColor(QDXColor.primary, for: .normal)
        getCodeBtn.setTitleColor(QDXColor.lightGray, for: .disabled)
        getCodeBtn.addTarget(self, action: #selector(getCodeTapped), for: .touchUpInside)
        codeRow.addSubview(getCodeBtn)
        getCodeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(94)
        }

        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(card.snp.bottom).offset(24)
            make.left.right.equalTo(card)
            make.height.equalTo(48)
        }
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        rulesButton.setTitle("注册即表示同意趣定向服务条款", for: .normal)
        rulesButton.titleLabel?.font = .systemFont(ofSize: 14)
        rulesButton.setTitleColor(QDXColor.primary, for: .normal)
        rulesButton.addTarget(self, action: #selector(rulesTapped), for: .touchUpInside)
        view.addSubview(rulesButton)
        rulesButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-Screen.safeAreaBottom - 20)
            make.centerX.equalToSuperview()
            make.height.equalTo(35)
        }
    }

    // MARK: - 获取验证码
    @objc private func getCodeTapped() {
        guard let phone = phoneField.text, Validator.isMobilePhone(phone) else {
            showToast("请输入正确的手机号")
            return
        }
        startCountdown()
        NetworkService.shared.requestJSON(
            path: APIPath.setVcode,
            parameters: ["customer_code": phone],
            needToken: false
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let dict):
                    if (dict["Code"] as? Int) == 1 {
                        self?.showToast("验证码已发送")
                    } else {
                        self?.showToast((dict["Msg"] as? String) ?? "发送失败")
                        self?.stopCountdown()
                    }
                case .failure(let e):
                    self?.showToast(e.localizedDescription)
                    self?.stopCountdown()
                }
            }
        }
    }

    private func startCountdown() {
        countdown = 60
        getCodeBtn.isEnabled = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            self.countdown -= 1
            if self.countdown <= 0 {
                self.stopCountdown()
            } else {
                self.getCodeBtn.setTitle("\(self.countdown)s 后重发", for: .normal)
            }
        }
    }
    private func stopCountdown() {
        timer?.invalidate()
        getCodeBtn.isEnabled = true
        getCodeBtn.setTitle("获取验证码", for: .normal)
    }

    // MARK: - 下一步：校验验证码后进入注册
    @objc private func nextTapped() {
        view.endEditing(true)
        guard let phone = phoneField.text, Validator.isMobilePhone(phone),
              let code = codeField.text, !code.isEmpty else {
            showToast("请填写正确手机号与验证码")
            return
        }
        showLoading("验证中...")
        NetworkService.shared.requestJSON(
            path: APIPath.validateCode,
            parameters: ["customer_code": phone, "customer_vcode": code],
            needToken: false
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case .success(let dict):
                    if (dict["Code"] as? Int) == 1 {
                        let register = RegisterViewController()
                        register.prefillAccount = phone
                        self.navigationController?.pushViewController(register, animated: true)
                    } else {
                        self.showToast((dict["Msg"] as? String) ?? "验证失败")
                    }
                case .failure(let e):
                    self.showToast(e.localizedDescription)
                }
            }
        }
    }

    @objc private func rulesTapped() {
        let vc = ProtocolViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
