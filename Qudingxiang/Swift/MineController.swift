//
//  MineController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 MineViewController.m：个人中心
//  - 渐变头部 + 头像 + 昵称 + 手机号 + 签名 + 编辑
//  - 表格：我的线路/团队线路、我的卡包/我的设置、关于我们/联系我们
//  - 头像上传（UIImagePickerController）
//  视觉：现代化渐变头部 + 圆角头像 + 卡片表格
//

import UIKit
import SnapKit
import SDWebImage

final class MineController: BaseViewController {

    private let scrollView = UIScrollView()
    private let headerView = UIView()
    private let avatarView = UIImageView()
    private let nameLabel = UILabel()
    private let phoneLabel = UILabel()
    private let signLabel = UILabel()
    private let editButton = UIButton(type: .system)

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var customer: Customer?

    private struct Row {
        let icon: String
        let title: String
        let action: () -> Void
    }
    private var sections: [(title: String, rows: [Row])] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "我的"
        setupHeader()
        setupTableView()
        NotificationCenter.default.addObserver(
            self, selector: #selector(refresh),
            name: NSNotification.Name("stateRefresh"), object: nil
        )
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 头部
    private func setupHeader() {
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(hex: 0x66C3FF).cgColor, UIColor(hex: 0x0099FD).cgColor]
        gradient.startPoint = .init(x: 0, y: 0)
        gradient.endPoint = .init(x: 1, y: 1)
        headerView.layer.insertSublayer(gradient, at: 0)
        scrollView.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.left.right.width.equalToSuperview()
            make.height.equalTo(220)
        }
        DispatchQueue.main.async { gradient.frame = self.headerView.bounds }

        avatarView.image = UIImage(named: "默认头像")
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 40
        avatarView.layer.borderColor = UIColor.white.cgColor
        avatarView.layer.borderWidth = 2
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAvatar)))
        headerView.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(80)
        }

        nameLabel.text = "昵称"
        nameLabel.font = QDXFont.semibold(34)
        nameLabel.textColor = .white
        headerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(16)
            make.top.equalTo(avatarView).offset(8)
        }

        phoneLabel.setTitle("************", for: .normal)
        phoneLabel.setTitleColor(UIColor.white.withAlphaComponent(0.9), for: .normal)
        phoneLabel.titleLabel?.font = QDXFont.regular(24)
        phoneLabel.setImage(UIImage(systemName: "iphone"), for: .normal)
        phoneLabel.tintColor = .white
        phoneLabel.semanticContentAttribute = .forceLeftToRight
        headerView.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
        }

        signLabel.text = "签名:"
        signLabel.font = QDXFont.regular(22)
        signLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        headerView.addSubview(signLabel)
        signLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(phoneLabel.snp.bottom).offset(6)
        }

        editButton.setTitle("编辑资料", for: .normal)
        editButton.setTitleColor(.white, for: .normal)
        editButton.titleLabel?.font = QDXFont.regular(24)
        editButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        editButton.tintColor = .white
        editButton.semanticContentAttribute = .forceRightToLeft
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        headerView.addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(avatarView)
        }
    }

    // MARK: - 表格
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = 56
        tableView.backgroundColor = .clear
        scrollView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(360)
        }
        scrollView.contentSize = CGSize(width: Screen.width, height: 220 + 12 + 360)
    }

    private func buildSections() {
        sections = [
            ("", [
                Row(icon: "我的线路icon", title: "我的线路", action: { [weak self] in self?.openMyLines() }),
                Row(icon: "团队线路icon", title: "团队线路", action: { [weak self] in self?.openTeamLines() })
            ]),
            ("", [
                Row(icon: "我的卡包icon", title: "我的卡包", action: { [weak self] in self?.openCards() }),
                Row(icon: "我的设置",     title: "我的设置", action: { [weak self] in self?.openSetting() })
            ]),
            ("", [
                Row(icon: "关于我们", title: "关于我们", action: { [weak self] in self?.openAbout() }),
                Row(icon: "联系我们", title: "联系我们", action: { [weak self] in self?.contactUs() })
            ])
        ]
        tableView.reloadData()
    }

    // MARK: - 数据
    @objc private func refresh() {
        MineAPI.authLogin { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if case .success(let c) = result {
                    self.customer = c
                    self.nameLabel.text = c.cn ?? "昵称"
                    // 手机号脱敏
                    if var code = c.code, code.count >= 9 {
                        let start = code.index(code.startIndex, offsetBy: 3)
                        let end = code.index(code.startIndex, offsetBy: 9)
                        code.replaceSubrange(start..<end, with: "******")
                        self.phoneLabel.setTitle(code, for: .normal)
                    }
                    self.signLabel.text = "签名:" + (c.signature ?? "")
                    if let urlString = c.headURL, let url = URL(string: APIHost.oldBase + urlString) {
                        self.avatarView.sd_setImage(with: url, placeholderImage: UIImage(named: "默认头像"))
                    }
                }
                self.buildSections()
            }
        }
    }

    // MARK: - 事件
    @objc private func editTapped() {
        guard isLoggedIn else { requireLogin(); return }
        let vc = EditMineInfoController()
        vc.customer = customer
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func changeAvatar() {
        guard isLoggedIn else { requireLogin(); return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "从相册选取", style: .default) { _ in
            picker.sourceType = .savedPhotosAlbum
            self.present(picker, animated: true)
        })
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "拍照", style: .default) { _ in
                picker.sourceType = .camera
                self.present(picker, animated: true)
            })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    private func openMyLines() {
        guard isLoggedIn else { requireLogin(); return }
        navigationController?.pushViewController(MyLineListController(mode: .personal), animated: true)
    }
    private func openTeamLines() {
        guard isLoggedIn else { requireLogin(); return }
        navigationController?.pushViewController(MyLineListController(mode: .team), animated: true)
    }
    private func openCards() {
        guard isLoggedIn else { requireLogin(); return }
        navigationController?.pushViewController(MineCardController(), animated: true)
    }
    private func openSetting() {
        guard isLoggedIn else { requireLogin(); return }
        navigationController?.pushViewController(SettingController(), animated: true)
    }
    private func openAbout() {
        let vc = AboutUsController()
        vc.level = customer?.level
        navigationController?.pushViewController(vc, animated: true)
    }
    private func contactUs() {
        let alert = UIAlertController(title: "400-820-3899", message: "客服工作时间:09:30-18:30", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "拨打", style: .default) { _ in
            if let url = URL(string: "tel:4008203899") {
                UIApplication.shared.open(url)
            }
        })
        present(alert, animated: true)
    }

    private func requireLogin() {
        let alert = UIAlertController(title: "提示", message: "登陆后才可使用此功能", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "暂不登录", style: .cancel))
        alert.addAction(UIAlertAction(title: "立即登录", style: .default) { _ in
            let login = LoginViewController()
            let nav = QDXNavigationController(rootViewController: login)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        })
        present(alert, animated: true)
    }
    private var isLoggedIn: Bool { AccountManager.shared.isLoggedIn }
}

// MARK: - DataSource
extension MineController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { sections.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let row = sections[indexPath.section].rows[indexPath.row]
        cell.imageView?.image = UIImage(named: row.icon)
        cell.textLabel?.text = row.title
        cell.textLabel?.font = QDXFont.regular(28)
        cell.textLabel?.textColor = QDXColor.black
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard isLoggedIn else { requireLogin(); return }
        sections[indexPath.section].rows[indexPath.row].action()
    }
}

// MARK: - 头像上传
extension MineController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else { return }
        avatarView.image = image
        // 压缩上传
        var data = image.pngData()
        var scale: CGFloat = 1.0
        while (data?.count ?? 0) / 1024 > 1048, scale > 0.1 {
            scale -= 0.1
            data = image.jpegData(compressionQuality: scale)
        }
        guard let imageData = data else { return }
        showLoading("上传中...")
        NetworkService.shared.uploadImage(imageData) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading()
                switch result {
                case .success(let path):
                    // 更新头像 URL
                    MineAPI.modify(params: ["customer_headurl": path]) { _ in
                        NotificationCenter.default.post(name: NSNotification.Name("stateRefresh"), object: nil)
                    }
                case .failure(let err):
                    self?.showToast(err.localizedDescription)
                }
            }
        }
    }
}
