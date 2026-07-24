//
//  LineDetailViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXLineDetailViewController.m：
//  - WKWebView 加载活动详情页（顶部进度条）
//  - 底部价格 + 立即报名按钮
//  - 报名抽屉（数量选择、总价、去支付）
//  视觉：现代化圆角抽屉 + 渐变遮罩 + 步进器
//

import UIKit
import SnapKit
import WebKit
import SDWebImage
import MBProgressHUD

final class LineDetailViewController: BaseViewController {

    /// 活动数据
    var goods: Goods?

    private let webView = WKWebView()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private var progressObserver: NSKeyValueObservation?

    private let bottomBar = UIView()
    private let priceLabel = UILabel()
    private let signUpButton = PrimaryButton(title: "立即报名")

    // 报名抽屉
    private let overlayView = UIView()
    private let drawerView = UIView()
    private let closeButton = UIButton(type: .system)
    private let coverImageView = UIImageView()
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let timeLabel = UILabel()
    private let stepperContainer = UIView()
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)
    private let quantityLabel = UILabel()
    private let totalLabel = UILabel()
    private let totalValueLabel = UILabel()
    private let payButton = PrimaryButton(title: "去支付")

    private var quantity: Int = 1
    private var totalPrice: Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = goods?.cn
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain, target: self, action: #selector(shareTapped)
        )
        setupWebView()
        loadDetail()
        // 仅当活动状态为进行中（goodstatus_id == 1）时显示报名栏
        if goods?.statusID == "1" { setupBottomBar() }
    }
    deinit { progressObserver?.invalidate() }

    // MARK: - WebView
    private func setupWebView() {
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(goods?.statusID == "1" ? -80 : 0)
        }
        progressView.tintColor = QDXColor.primary
        progressView.trackTintColor = .white
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(2)
        }
        progressObserver = webView.observe(\.estimatedProgress, options: .new) { [weak self] _, change in
            DispatchQueue.main.async {
                guard let p = change.newValue else { return }
                if p >= 1.0 {
                    self?.progressView.isHidden = true
                    self?.progressView.setProgress(0, animated: false)
                } else {
                    self?.progressView.isHidden = false
                    self?.progressView.setProgress(Float(p), animated: true)
                }
            }
        }
    }

    private func loadDetail() {
        guard let id = goods?.id else { return }
        let url = APIHost.base + APIPath.goodsIndex + "/goods_id/\(id)"
        webView.load(URLRequest(url: URL(string: url)!))
    }

    // MARK: - 底部报名栏
    private func setupBottomBar() {
        bottomBar.backgroundColor = .white
        view.addSubview(bottomBar)
        bottomBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(80 + Screen.safeAreaBottom)
        }
        let line = UIView(); line.backgroundColor = QDXColor.lineColor
        bottomBar.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview(); make.height.equalTo(0.5)
        }
        priceLabel.font = QDXFont.bold(36)
        priceLabel.textColor = QDXColor.accent
        priceLabel.text = "¥ \(goods?.price ?? "0")"
        bottomBar.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview().offset(-Screen.safeAreaBottom/2)
        }
        bottomBar.addSubview(signUpButton)
        signUpButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview().offset(-Screen.safeAreaBottom/2)
            make.width.equalTo(140); make.height.equalTo(44)
        }
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
    }

    // MARK: - 报名抽屉
    @objc private func signUpTapped() {
        guard AccountManager.shared.isLoggedIn else {
            let alert = UIAlertController(title: "提示", message: "登录后才可使用此功能", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "暂不登录", style: .cancel))
            alert.addAction(UIAlertAction(title: "立即登录", style: .default) { _ in
                let login = LoginViewController()
                self.navigationController?.pushViewController(login, animated: true)
            })
            present(alert, animated: true)
            return
        }
        presentDrawer()
    }

    private func presentDrawer() {
        guard let goods = goods else { return }
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0)
        overlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissDrawer)))
        view.addSubview(overlayView)
        overlayView.snp.makeConstraints { $0.edges.equalToSuperview() }

        drawerView.backgroundColor = .white
        drawerView.layer.cornerRadius = 16
        drawerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        drawerView.clipsToBounds = true
        view.addSubview(drawerView)
        drawerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(360)
        }
        // 初始位于屏幕下方
        view.layoutIfNeeded()
        drawerView.transform = CGAffineTransform(translationX: 0, y: 360)

        // 内容
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = QDXColor.gray
        closeButton.addTarget(self, action: #selector(dismissDrawer), for: .touchUpInside)
        drawerView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.right.top.equalToSuperview().inset(16)
            make.width.height.equalTo(28)
        }
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 8
        drawerView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16); make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(80)
        }
        if let urlString = goods.url, let url = URL(string: APIHost.oldBase + urlString) {
            coverImageView.sd_setImage(with: url)
        }
        titleLabel.font = QDXFont.semibold(30); titleLabel.textColor = QDXColor.black
        titleLabel.numberOfLines = 2
        titleLabel.text = goods.cn
        drawerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(coverImageView.snp.right).offset(12)
            make.right.equalTo(closeButton.snp.left).offset(-8)
            make.top.equalTo(coverImageView)
        }
        addressLabel.font = QDXFont.regular(24); addressLabel.textColor = QDXColor.gray
        addressLabel.numberOfLines = 1
        addressLabel.text = goods.address
        drawerView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
        timeLabel.font = QDXFont.regular(22); timeLabel.textColor = QDXColor.lightGray
        timeLabel.text = "截止日期：\(goods.time ?? "—")"
        drawerView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(addressLabel.snp.bottom).offset(4)
        }

        // 步进器
        let quantityTitle = UILabel()
        quantityTitle.text = "数量"
        quantityTitle.font = QDXFont.medium(28)
        quantityTitle.textColor = QDXColor.black
        drawerView.addSubview(quantityTitle)
        quantityTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(coverImageView.snp.bottom).offset(24)
        }
        drawerView.addSubview(stepperContainer)
        stepperContainer.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(quantityTitle)
            make.width.equalTo(120); make.height.equalTo(32)
        }
        minusButton.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        minusButton.tintColor = QDXColor.primary
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        plusButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        plusButton.tintColor = QDXColor.primary
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        quantityLabel.text = "1"
        quantityLabel.font = QDXFont.medium(28)
        quantityLabel.textColor = QDXColor.black
        quantityLabel.textAlignment = .center
        stepperContainer.addSubview(minusButton)
        stepperContainer.addSubview(quantityLabel)
        stepperContainer.addSubview(plusButton)
        minusButton.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview(); make.width.height.equalTo(32)
        }
        quantityLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        plusButton.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview(); make.width.height.equalTo(32)
        }

        // 总价
        totalLabel.text = "合计："
        totalLabel.font = QDXFont.medium(28)
        totalLabel.textColor = QDXColor.gray
        drawerView.addSubview(totalLabel)
        totalLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-Screen.safeAreaBottom - 60)
        }
        totalPrice = Float(goods.price ?? "0") ?? 0
        totalValueLabel.font = QDXFont.bold(38)
        totalValueLabel.textColor = QDXColor.accent
        updateTotalLabel()
        drawerView.addSubview(totalValueLabel)
        totalValueLabel.snp.makeConstraints { make in
            make.left.equalTo(totalLabel.snp.right).offset(8)
            make.centerY.equalTo(totalLabel)
        }
        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        drawerView.addSubview(payButton)
        payButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(totalLabel)
            make.width.equalTo(140); make.height.equalTo(44)
        }

        // 动画进入
        UIView.animate(withDuration: 0.3) {
            self.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.drawerView.transform = .identity
        }
    }

    @objc private func dismissDrawer() {
        UIView.animate(withDuration: 0.3, animations: {
            self.overlayView.backgroundColor = .clear
            self.drawerView.transform = CGAffineTransform(translationX: 0, y: 360)
        }, completion: { _ in
            self.overlayView.removeFromSuperview()
            self.drawerView.removeFromSuperview()
        })
    }

    @objc private func minusTapped() {
        guard quantity > 1 else { return }
        quantity -= 1
        quantityLabel.text = "\(quantity)"
        updateTotalLabel()
    }
    @objc private func plusTapped() {
        guard quantity < 99 else { return }
        quantity += 1
        quantityLabel.text = "\(quantity)"
        updateTotalLabel()
    }
    private func updateTotalLabel() {
        totalValueLabel.text = "¥ \(String(format: "%.2f", totalPrice * Float(quantity)))"
    }

    @objc private func payTapped() {
        guard let goodsID = goods?.id else { return }
        dismissDrawer()
        showLoading("提交订单...")
        ContentAPI.signUp(goodsID: goodsID, quantity: quantity) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading()
                switch result {
                case .success(let order):
                    NotificationCenter.default.post(name: NSNotification.Name("pay"), object: nil)
                    let detail = OrderDetailViewController()
                    detail.order = order
                    self?.navigationController?.pushViewController(detail, animated: true)
                case .failure(let err):
                    self?.showToast(err.localizedDescription)
                }
            }
        }
    }

    @objc private func shareTapped() {
        showToast("分享功能待接入")
    }
}

extension LineDetailViewController: WKNavigationDelegate {}
