//
//  RegisterViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXRegisterViewController.m
//  视觉：卡片式表单 + 顶部渐变 + 显隐密码按钮
//

import UIKit
import SnapKit

final class RegisterViewController: BaseViewController {

    /// 由登录页传入的手机号，注册时复用
    var prefillAccount: String?

    private let nameField     = FormField(placeholder: "请输入昵称")
    private let accountField  = FormField(placeholder: "请输入手机号", keyboardType: .numberPad)
    private let passwordField = FormField(placeholder: "请输入密码", isSecure: true, rightAction: .passwordToggle)
    private let confirmField  = FormField(placeholder: "请确认密码", isSecure: true, rightAction: .passwordToggle)
    private let submitButton  = PrimaryButton(title: "注册")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "注册"
        setupUI()
    }

    private func setupUI() {
        if let account = prefillAccount { accountField.text = account }

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

        card.addSubview(nameField)
        card.addSubview(accountField)
        card.addSubview(passwordField)
        card.addSubview(confirmField)

        nameField.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        accountField.snp.makeConstraints { make in
            make.top.equalTo(nameField.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(accountField.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        confirmField.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
            make.bottom.equalToSuperview()
        }

        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(card.snp.bottom).offset(24)
            make.left.right.equalTo(card)
            make.height.equalTo(48)
        }
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }

    @objc private func submitTapped() {
        view.endEditing(true)
        guard let name = nameField.text, !name.isEmpty,
              let account = accountField.text, Validator.isMobilePhone(account),
              let password = passwordField.text,
              let confirm = confirmField.text else {
            showToast("请完善信息并填写正确手机号")
            return
        }
        guard password == confirm else {
            showToast("两次密码不一致")
            return
        }
        guard Validator.isPassword(password) else {
            showToast("密码在 6-16 位之间")
            return
        }
        showLoading("注册中...")
        AuthAPI.register(cn: name, account: account, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading()
                switch result {
                case .success(let customer):
                    AccountManager.shared.save(customer)
                    self?.dismiss(animated: true)
                case .failure(let err):
                    self?.showToast(err.localizedDescription)
                }
            }
        }
    }
}
