//
//  LoginViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXLoginViewController：账号密码登录 + 第三方登录入口
//  视觉：渐变顶部背景、卡片式表单、圆角输入框
//

import UIKit
import SnapKit
import MBProgressHUD

final class LoginViewController: BaseViewController {

    private let logoImageView = UIImageView()
    private let accountField  = UITextField()
    private let passwordField = UITextField()
    private let loginButton   = UIButton(type: .system)
    private let forgetButton  = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)
    private let thirdPartyContainer = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "登录"
        view.backgroundColor = QDXColor.background
        setupUI()
    }

    private func setupUI() {
        // 顶部渐变背景 + Logo
        let headerView = UIView()
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(280)
        }
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(hex: 0x66C3FF).cgColor, UIColor(hex: 0x0099FD).cgColor]
        gradient.startPoint = .init(x: 0, y: 0)
        gradient.endPoint = .init(x: 1, y: 1)
        headerView.layer.insertSublayer(gradient, at: 0)
        DispatchQueue.main.async { gradient.frame = headerView.bounds }

        logoImageView.image = UIImage(named: "logo") ?? UIImage()
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.tintColor = .white
        headerView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        let titleLabel = UILabel()
        titleLabel.text = "趣定向"
        titleLabel.font = QDXFont.bold(40)
        titleLabel.textColor = .white
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        // 表单卡片
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 16
        view.addSubview(card)
        card.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(-32)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(180)
        }

        configureField(accountField, placeholder: "请输入手机号")
        configureField(passwordField, placeholder: "请输入密码", isSecure: true)
        card.addSubview(accountField)
        card.addSubview(passwordField)
        let line = UIView()
        line.backgroundColor = QDXColor.lineColor
        card.addSubview(line)

        accountField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(56)
        }
        line.snp.makeConstraints { make in
            make.left.right.equalTo(accountField)
            make.top.equalTo(accountField.snp.bottom)
            make.height.equalTo(1)
        }
        passwordField.snp.makeConstraints { make in
            make.left.right.height.equalTo(accountField)
            make.top.equalTo(line.snp.bottom)
        }

        // 登录按钮
        loginButton.setTitle("登录", for: .normal)
        loginButton.titleLabel?.font = QDXFont.semibold(32)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = QDXColor.primary
        loginButton.layer.cornerRadius = 24
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(card.snp.bottom).offset(24)
            make.left.right.equalTo(card)
            make.height.equalTo(48)
        }

        // 忘记密码 / 注册
        forgetButton.setTitle("忘记密码?", for: .normal)
        forgetButton.setTitleColor(QDXColor.gray, for: .normal)
        forgetButton.titleLabel?.font = QDXFont.regular(26)
        forgetButton.addTarget(self, action: #selector(forgetTapped), for: .touchUpInside)
        registerButton.setTitle("新用户注册", for: .normal)
        registerButton.setTitleColor(QDXColor.primary, for: .normal)
        registerButton.titleLabel?.font = QDXFont.medium(26)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)

        let bottomStack = UIStackView(arrangedSubviews: [forgetButton, registerButton])
        bottomStack.axis = .horizontal
        bottomStack.distribution = .equalSpacing
        view.addSubview(bottomStack)
        bottomStack.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(16)
            make.left.right.equalTo(loginButton)
        }

        // 第三方登录
        let tipLabel = UILabel()
        tipLabel.text = "—— 第三方登录 ——"
        tipLabel.font = QDXFont.regular(24)
        tipLabel.textColor = QDXColor.lightGray
        tipLabel.textAlignment = .center
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-Screen.safeAreaBottom - 100)
            make.centerX.equalToSuperview()
        }
        thirdPartyContainer.axis = .horizontal
        thirdPartyContainer.spacing = 40
        thirdPartyContainer.distribution = .fillEqually
        view.addSubview(thirdPartyContainer)
        thirdPartyContainer.snp.makeConstraints { make in
            make.top.equalTo(tipLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(48)
        }
        let wxBtn = makeThirdPartyButton(icon: "sns_icon_6", action: #selector(wechatTapped))
        let qqBtn = makeThirdPartyButton(icon: "sns_icon_22", action: #selector(qqTapped))
        thirdPartyContainer.addArrangedSubview(wxBtn)
        thirdPartyContainer.addArrangedSubview(qqBtn)
    }

    private func configureField(_ field: UITextField, placeholder: String, isSecure: Bool = false) {
        field.placeholder = placeholder
        field.font = QDXFont.regular(28)
        field.isSecureTextEntry = isSecure
        field.clearButtonMode = .whileEditing
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
    }

    private func makeThirdPartyButton(icon: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: icon), for: .normal)
        btn.tintColor = QDXColor.gray
        btn.layer.cornerRadius = 24
        btn.backgroundColor = UIColor(white: 0.95, alpha: 1)
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.snp.makeConstraints { $0.width.height.equalTo(48) }
        return btn
    }

    // MARK: - 事件
    @objc private func loginTapped() {
        guard let account = accountField.text, !account.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showToast("请输入账号和密码", icon: .text)
            return
        }
        view.endEditing(true)
        showLoading("登录中...")
        AuthAPI.login(account: account, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading()
                switch result {
                case .success:
                    self?.dismiss(animated: true)
                case .failure(let err):
                    self?.showToast(err.localizedDescription)
                }
            }
        }
    }

    @objc private func wechatTapped() {
        showToast("微信登录待接入")
    }
    @objc private func qqTapped() {
        showToast("QQ 登录待接入")
    }
    @objc private func forgetTapped() {
        navigationController?.pushViewController(ForgetPasswordViewController(), animated: true)
    }
    @objc private func registerTapped() {
        navigationController?.pushViewController(RegisterViewController(), animated: true)
    }
}
