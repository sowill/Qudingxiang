//
//  PayViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXPayTableViewController.m：选择支付方式 + 拉起支付
//  视觉：金额高亮卡片 + 单选支付方式
//

import UIKit
import SnapKit
import MBProgressHUD

final class PayViewController: BaseViewController {

    var order: Orders?

    private let amountCard = UIView()
    private let amountLabel = UILabel()
    private let amountValue = UILabel()
    private let wechatRow   = PayMethodRow(icon: UIImage(systemName: "message.fill"),
                                          title: "微信支付", tint: QDXColor.green)
    private let alipayRow   = PayMethodRow(icon: UIImage(systemName: "creditcard.fill"),
                                          title: "支付宝", tint: QDXColor.blue)
    private let confirmBtn  = PrimaryButton(title: "确认支付", enabled: false)
    private var selected: PayType?
    private var wechatParam: WeixinPayParam?
    private var alipayParam: AlipayParam?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "订单支付"
        setupAmountCard()
        setupMethodRows()
        setupConfirmButton()
    }

    private func setupAmountCard() {
        amountCard.backgroundColor = UIColor(hex: 0xFEF5DC)
        amountCard.layer.cornerRadius = 12
        view.addSubview(amountCard)
        amountCard.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(72)
        }
        amountLabel.text = "应付金额"
        amountLabel.font = QDXFont.medium(28)
        amountLabel.textColor = QDXColor.gray
        amountCard.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16); make.centerY.equalToSuperview()
        }
        amountValue.font = QDXFont.bold(40)
        amountValue.textColor = QDXColor.accent
        amountValue.text = "¥ \(order?.account ?? order?.amount ?? "0")"
        amountCard.addSubview(amountValue)
        amountValue.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16); make.centerY.equalToSuperview()
        }
    }

    private func setupMethodRows() {
        let title = UILabel()
        title.text = "选择支付方式"
        title.font = QDXFont.medium(28)
        title.textColor = QDXColor.black
        view.addSubview(title)
        title.snp.makeConstraints { make in
            make.top.equalTo(amountCard.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(16)
        }
        view.addSubview(wechatRow)
        view.addSubview(alipayRow)
        wechatRow.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(64)
        }
        alipayRow.snp.makeConstraints { make in
            make.top.equalTo(wechatRow.snp.bottom).offset(1)
            make.left.right.height.equalTo(wechatRow)
        }
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(selectWechat))
        wechatRow.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(selectAlipay))
        alipayRow.addGestureRecognizer(tap2)
    }

    private func setupConfirmButton() {
        view.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { make in
            make.top.equalTo(alipayRow.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        confirmBtn.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }

    @objc private func selectWechat() {
        selected = .wechat
        wechatRow.setSelected(true)
        alipayRow.setSelected(false)
        confirmBtn.isEnabled = true
        // 预拉取参数
        guard let orderID = order?.id, wechatParam == nil else { return }
        OrderAPI.wechatPay(orderID: orderID) { [weak self] result in
            if case .success(let p) = result { self?.wechatParam = p }
        }
    }
    @objc private func selectAlipay() {
        selected = .alipay
        wechatRow.setSelected(false)
        alipayRow.setSelected(true)
        confirmBtn.isEnabled = true
        guard let orderID = order?.id, alipayParam == nil else { return }
        OrderAPI.alipay(orderID: orderID) { [weak self] result in
            if case .success(let p) = result { self?.alipayParam = p }
        }
    }

    @objc private func confirmTapped() {
        guard let type = selected else { return }
        showLoading("正在处理...")
        switch type {
        case .wechat:
            guard let param = wechatParam else { hideLoading(); showToast("支付参数未就绪"); return }
            PayManager.shared.wechatPay(param: param) { [weak self] result in
                DispatchQueue.main.async { self?.handleResult(result) }
            }
        case .alipay:
            guard let param = alipayParam else { hideLoading(); showToast("支付参数未就绪"); return }
            // 构造订单信息字符串（实际由后端返回签名后的 orderString 更佳）
            let orderString = "partner=\"\(param.partner ?? "")\"&seller_id=\"\(param.seller ?? "")\"&notify_url=\"\(param.notify ?? "")\""
            PayManager.shared.alipay(orderString: orderString) { [weak self] result in
                DispatchQueue.main.async { self?.handleResult(result) }
            }
        }
    }

    private func handleResult(_ result: PayResult) {
        hideLoading()
        switch result {
        case .success:
            NotificationCenter.default.post(name: NSNotification.Name("pay"), object: nil)
            showToast("支付成功")
            dismiss(animated: true)
        case .processing:
            showToast("支付处理中")
        case .canceled:
            showToast("已取消支付")
        case .failure(let msg):
            showToast(msg)
        }
    }
}

// MARK: - 支付方式行
final class PayMethodRow: UIView {
    private let iconView   = UIImageView()
    private let titleLabel = UILabel()
    private let selectView = UIImageView()

    init(icon: UIImage?, title: String, tint: UIColor) {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 12
        clipsToBounds = true
        iconView.image = icon?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = tint
        addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16); make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        titleLabel.text = title
        titleLabel.font = QDXFont.medium(30)
        titleLabel.textColor = QDXColor.black
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(12); make.centerY.equalToSuperview()
        }
        selectView.image = UIImage(systemName: "circle")
        selectView.tintColor = QDXColor.lightGray
        addSubview(selectView)
        selectView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16); make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func setSelected(_ selected: Bool) {
        let name = selected ? "checkmark.circle.fill" : "circle"
        selectView.image = UIImage(systemName: name)
        selectView.tintColor = selected ? QDXColor.primary : QDXColor.lightGray
    }
}
