//
//  PlaceholderControllers.swift
//  趣定向 (Swift 迁移版)
//
//  占位控制器：发现 / 订单 / 我的，确保工程可编译运行
//  后续按模块逐个迁移对应的 OC 控制器实现
//

import UIKit
import SnapKit

/// 发现
final class DiscoverController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "发现"
        let label = UILabel()
        label.text = "发现模块（迁移中）"
        label.font = QDXFont.medium(30)
        label.textColor = QDXColor.gray
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
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
