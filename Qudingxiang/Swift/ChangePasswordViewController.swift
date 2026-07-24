//
//  ChangePasswordViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXChangePwdViewController.m：修改密码
//

import UIKit
import SnapKit

final class ChangePasswordViewController: BaseViewController {

    private let passwordField = FormField(placeholder: "请输入新密码", isSecure: true, rightAction: .passwordToggle)
    private let confirmField  = FormField(placeholder: "请确认新密码", isSecure: true, rightAction: .passwordToggle)
    private let submitButton  = PrimaryButton(title: "完成")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "修改密码"
        setupUI()
    }

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
        card.addSubview(passwordField)
        card.addSubview(confirmField)
        passwordField.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
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
        guard let pwd = passwordField.text,
              let confirm = confirmField.text else { return }
        guard pwd == confirm else { showToast("两次密码不一致"); return }
        guard Validator.isPassword(pwd) else { showToast("密码在 6-16 位之间"); return }
        showLoading("提交中...")
        NetworkService.shared.requestJSON(
            path: APIPath.modify,
            parameters: ["customer_pwd": pwd]
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading()
                switch result {
                case .success(let dict):
                    if (dict["Code"] as? Int) == 1,
                       let msg = dict["Msg"] as? [String: Any] {
                        let c = Customer(from: msg)
                        AccountManager.shared.save(c)
                        self?.dismiss(animated: true)
                    } else {
                        self?.showToast((dict["Msg"] as? String) ?? "修改失败")
                    }
                case .failure(let err):
                    self?.showToast(err.localizedDescription)
                }
            }
        }
    }
}
