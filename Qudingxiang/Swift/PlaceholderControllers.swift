//
//  PlaceholderControllers.swift
//  趣定向 (Swift 迁移版)
//
//  占位控制器：发现 / 订单 / 我的，确保工程可编译运行
//  后续按模块逐个迁移对应的 OC 控制器实现
//

import UIKit
import SnapKit

/// 发现（场地列表入口，承载 PlaceController）
final class DiscoverController: BaseViewController {
    private let placeVC = PlaceController()
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(placeVC)
        view.addSubview(placeVC.view)
        placeVC.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        placeVC.didMove(toParent: self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 委托给子控制器处理导航栏
        placeVC.navigationItem.title = "发现"
    }
}

/// 订单
final class OrderController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "订单"
        let label = UILabel()
        label.text = "我的订单（迁移中）"
        label.font = QDXFont.medium(30)
        label.textColor = QDXColor.gray
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

/// 我的
final class MineController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "我的"
        let label = UILabel()
        label.text = "个人中心（迁移中）"
        label.font = QDXFont.medium(30)
        label.textColor = QDXColor.gray
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
