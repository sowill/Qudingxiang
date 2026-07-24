//
//  PopContainerView.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXPopView.h/.m：半透明遮罩 + 底部上浮容器，用于承载 WKWebView 任务书
//  使用现代动画与圆角样式
//

import UIKit
import SnapKit

final class PopContainerView: UIView {

    private let overlayView = UIView()
    private let containerView = UIView()
    private let closeButton = UIButton(type: .system)
    private var contentView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        overlayView.addGestureRecognizer(tap)
        addSubview(overlayView)
        overlayView.snp.makeConstraints { $0.edges.equalToSuperview() }

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.clipsToBounds = true
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(Screen.height * 0.85)
        }
        // 初始位于屏幕下方
        layoutIfNeeded()
        containerView.transform = CGAffineTransform(translationX: 0, y: Screen.height * 0.85)

        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = QDXColor.lightGray
        closeButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        containerView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.right.top.equalToSuperview().inset(12)
            make.width.height.equalTo(32)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    /// 设置内容视图（WebView 等）
    func setContentView(_ view: UIView) {
        contentView?.removeFromSuperview()
        contentView = view
        containerView.addSubview(view)
        view.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(44)
        }
    }

    func show(in parent: UIView) {
        parent.addSubview(self)
        snp.makeConstraints { $0.edges.equalToSuperview() }
        layoutIfNeeded()
        UIView.animate(withDuration: 0.3) {
            self.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.containerView.transform = .identity
        }
    }

    @objc func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.overlayView.backgroundColor = .clear
            self.containerView.transform = CGAffineTransform(translationX: 0, y: Screen.height * 0.85)
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}
