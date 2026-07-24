//
//  GuideViewController.swift
//  趣定向 (Swift 迁移版)
//
//  新版本引导页：UIScrollView 分页 + 现代渐变背景
//

import UIKit
import SnapKit

final class GuideViewController: UIViewController, UIScrollViewDelegate {

    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let enterButton = UIButton(type: .system)

    private let pages: [(title: String, subtitle: String, gradient: [CGColor])] = [
        ("线下定向", "蓝牙感应点标，计时完成比赛", [UIColor(hex: 0x66C3FF).cgColor, UIColor(hex: 0x0099FD).cgColor]),
        ("丰富活动", "赛事 / 场地 / 亲子，一键报名", [UIColor(hex: 0xFF8A5C).cgColor, UIColor(hex: 0xFF5100).cgColor]),
        ("在线支付", "微信 / 支付宝，安全便捷", [UIColor(hex: 0x4ED976).cgColor, UIColor(hex: 0x2FBD47).cgColor])
    ]

    override var prefersStatusBarHidden: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupScrollView()
        setupPageControl()
        setupEnterButton()
    }

    private func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        for (i, page) in pages.enumerated() {
            let v = UIView()
            let gradient = CAGradientLayer()
            gradient.colors = page.gradient
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            v.layer.insertSublayer(gradient, at: 0)
            v.layer.backgroundColor = nil
            let titleLabel = UILabel()
            titleLabel.text = page.title
            titleLabel.font = QDXFont.bold(64)
            titleLabel.textColor = .white
            v.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-30)
            }
            let subLabel = UILabel()
            subLabel.text = page.subtitle
            subLabel.font = QDXFont.regular(28)
            subLabel.textColor = UIColor.white.withAlphaComponent(0.9)
            v.addSubview(subLabel)
            subLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(16)
                make.centerX.equalToSuperview()
            }
            scrollView.addSubview(v)
            v.snp.makeConstraints { make in
                make.width.equalTo(Screen.width)
                make.height.equalTo(Screen.height)
                make.left.equalToSuperview().offset(CGFloat(i) * Screen.width)
                make.top.bottom.equalToSuperview()
            }
            // 渐变层布局
            v.didMoveToSuperview()
            gradient.frame = CGRect(x: 0, y: 0, width: Screen.width, height: Screen.height)
        }
        scrollView.contentSize = CGSize(width: Screen.width * CGFloat(pages.count), height: Screen.height)
    }

    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.4)
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-Screen.safeAreaBottom - 80)
            make.centerX.equalToSuperview()
        }
    }

    private func setupEnterButton() {
        enterButton.setTitle("立即体验", for: .normal)
        enterButton.titleLabel?.font = QDXFont.semibold(32)
        enterButton.setTitleColor(QDXColor.primary, for: .normal)
        enterButton.backgroundColor = .white
        enterButton.layer.cornerRadius = 24
        enterButton.layer.shadowColor = UIColor.black.cgColor
        enterButton.layer.shadowOpacity = 0.15
        enterButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        enterButton.layer.shadowRadius = 12
        enterButton.isHidden = true
        enterButton.addTarget(self, action: #selector(enterApp), for: .touchUpInside)
        view.addSubview(enterButton)
        enterButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-Screen.safeAreaBottom - 24)
            make.centerX.equalToSuperview()
            make.width.equalTo(240)
            make.height.equalTo(48)
        }
    }

    @objc private func enterApp() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.setValue(MainTabBarController(), forKey: "window.rootViewController")
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / Screen.width))
        pageControl.currentPage = index
        enterButton.isHidden = (index != pages.count - 1)
    }
}
