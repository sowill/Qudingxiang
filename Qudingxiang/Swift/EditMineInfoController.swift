//
//  EditMineInfoController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 editMineInfoViewController.m：编辑昵称 / 手机号 / 签名
//

import UIKit
import SnapKit

final class EditMineInfoController: BaseViewController {

    var customer: Customer?

    private let nameField  = FormField(placeholder: "请输入昵称")
    private let codeField  = FormField(placeholder: "请输入手机号", keyboardType: .numberPad)
    private let signField  = FormField(placeholder: "请输入签名")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "编辑资料"
        let saveBtn = UIBarButtonItem(
            title: "保存", style: .done, target: self, action: #selector(saveTapped)
        )
        saveBtn.tintColor = .white
        navigationItem.rightBarButtonItem = saveBtn
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
        card.addSubview(nameField)
        card.addSubview(codeField)
        card.addSubview(signField)
        nameField.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        codeField.snp.makeConstraints { make in
            make.top.equalTo(nameField.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        signField.snp.makeConstraints { make in
            make.top.equalTo(codeField.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
            make.bottom.equalToSuperview()
        }

        // 预填
        if let name = customer?.cn, !name.isEmpty {
            nameField.text = name
        }
        if let code = customer?.code, !code.isEmpty {
            codeField.text = code
        }
        if let sign = customer?.signature, !sign.isEmpty {
            signField.text = sign
        }
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        var params: [String: String] = [:]
        if let name = nameField.text, !name.isEmpty { params["customer_cn"] = name }
        if let code = codeField.text, !code.isEmpty { params["customer_code"] = code }
        if let sign = signField.text, !sign.isEmpty { params["customer_signature"] = sign }
        guard !params.isEmpty else { showToast("请填写内容"); return }
        showLoading("保存中...")
        MineAPI.modify(params: params) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading()
                switch result {
                case .success:
                    NotificationCenter.default.post(name: NSNotification.Name("stateRefresh"), object: nil)
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let err):
                    self?.showToast(err.localizedDescription)
                }
            }
        }
    }
}
