//
//  MainTabBarController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 LBTabBarController，使用原生 UITabBarController + 现代视觉
//

import UIKit
import SnapKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = QDXColor.background
        delegate = self
        setupChildControllers()
    }

    private func setupChildControllers() {
        let home     = wrap(HomeController(),       title: "首页", normal: "index_home_nomal",  selected: "index_home_click")
        let discover = wrap(DiscoverController(),   title: "发现", normal: "index_location_nomal", selected: "index_location_click")
        let order    = wrap(OrderController(),      title: "订单", normal: "index_order_nomal",  selected: "index_order_click")
        let mine     = wrap(MineController(),       title: "我的", normal: "index_more_nomal",   selected: "index_more_click")

        viewControllers = [home, discover, order, mine].map {
            let nav = QDXNavigationController(rootViewController: $0)
            nav.navigationBar.prefersLargeTitles = false
            return nav
        }
    }

    private func wrap(_ vc: UIViewController, title: String,
                      normal: String, selected: String) -> UIViewController {
        vc.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: normal)?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: selected)?.withRenderingMode(.alwaysOriginal)
        )
        // 文字样式
        let normalAttr: [NSAttributedString.Key: Any] = [
            .font: QDXFont.regular(20), .foregroundColor: QDXColor.gray
        ]
        let selectedAttr: [NSAttributedString.Key: Any] = [
            .font: QDXFont.medium(20), .foregroundColor: QDXColor.primary
        ]
        vc.tabBarItem.setTitleTextAttributes(normalAttr, for: .normal)
        vc.tabBarItem.setTitleTextAttributes(selectedAttr, for: .selected)
        vc.tabBarItem.imageInsets = UIEdgeInsets(top: -2, left: 0, bottom: 2, right: 0)
        vc.title = title
        return vc
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    // 拦截「订单」「我的」未登录跳转登录
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        guard let nav = viewController as? UINavigationController,
              let root = nav.viewControllers.first else { return true }
        let needLogin = (root is OrderController) || (root is MineController)
        if needLogin, !AccountManager.shared.isLoggedIn {
            let login = LoginViewController()
            let loginNav = QDXNavigationController(rootViewController: login)
            loginNav.modalPresentationStyle = .fullScreen
            present(loginNav, animated: true)
            return false
        }
        return true
    }
}

// MARK: - 自定义导航控制器
final class QDXNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = .white
    }
    // 禁用 iOS 后退手势文字
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
            let back = UIBarButtonItem()
            back.title = ""
            viewController.navigationItem.backBarButtonItem = back
        }
        super.pushViewController(viewController, animated: animated)
    }
}
