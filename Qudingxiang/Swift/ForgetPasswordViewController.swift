//
//  ForgetPasswordViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXForgetPasswordViewController.m：手机号 + 验证码 → 跳转修改密码
//

import UIKit
import SnapKit

final class ForgetPasswordViewController: BaseViewController {

    private let phoneField   = FormField(placeholder: "请输入手机号", keyboardType: .numberPad)
    private let codeField    = FormField(placeholder: "请输入短信验证码", keyboardType: .numberPad)
    private let getCodeBtn   = UIButton(type: .system)
    private let nextButton   = PrimaryButton(title: "下一步")

    private var countdown = 0
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "找回密码"
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

        // 验证码行：输入框 + 获取按钮
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
    }

    // MARK: - 获取验证码
    @objc private func getCodeTapped() {
        guard let phone = phoneField.text, Validator.isMobilePhone(phone) else {
            showToast("请输入正确的手机号")
            return
        }
        startCountdown()
        AuthAPI.getVcode(account: phone) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success: self?.showToast("验证码已发送")
                case .failure(let err):
                    self?.showToast(err.localizedDescription)
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

    // MARK: - 下一步（验证码登录，服务端返回 token 后跳修改密码）
    @objc private func nextTapped() {
        view.endEditing(true)
        guard let phone = phoneField.text, Validator.isMobilePhone(phone),
              let code = codeField.text, !code.isEmpty else {
            showToast("请填写正确手机号与验证码")
            return
        }
        showLoading("验证中...")
        NetworkService.shared.request(
            path: APIPath.vcodeLogin,
            parameters: ["customer_code": phone, "customer_vcode": code],
            needToken: false
        ) { [weak self] (result: Result<Customer, APIError>) in
            DispatchQueue.main.async {
                self?.hideLoading()
                switch result {
                case .success(let customer):
                    AccountManager.shared.save(customer)
                    let change = ChangePasswordViewController()
                    self?.navigationController?.pushViewController(change, animated: true)
                case .failure(let err):
                    self?.showToast(err.localizedDescription)
                }
            }
        }
    }
}
