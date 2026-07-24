//
//  DiscoverController.swift
//  趣定向 (Swift 迁移版)
//
//  发现 Tab：承载场地列表 PlaceController
//

import UIKit
import SnapKit

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
        placeVC.navigationItem.title = "发现"
    }
}
