//
//  ActivityListController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXActivityViewController + RecentActivityViewController：
//  顶部「近期 / 已完成」分段 + 横向分页 ScrollView + 各子页列表
//

import UIKit
import SnapKit
import MJRefresh

protocol ActivitySelectionDelegate: AnyObject {
    func activitySelected(_ goods: Goods)
}

final class ActivityListController: BaseViewController {

    /// 标题
    var navTitle: String = "活动" { didSet { navigationItem.title = navTitle } }
    /// 类型 1=活动 2=赛事
    var type: String = "1"
    /// 城市ID
    var cityID: String = ""

    weak var delegate: ActivitySelectionDelegate?

    private let segmented = UISegmentedControl(items: ["近期", "已完成"])
    private let scrollView = UIScrollView()
    private let indicator = UIView()
    private var current = 0

    private let recentList = ActivitySubListController()
    private let doneList   = ActivitySubListController()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navTitle
        setupSegmented()
        setupScrollView()
        configureChildren()
    }

    private func setupSegmented() {
        segmented.selectedSegmentIndex = 0
        segmented.setTitleTextAttributes([
            .font: QDXFont.medium(28), .foregroundColor: QDXColor.gray
        ], for: .normal)
        segmented.setTitleTextAttributes([
            .font: QDXFont.semibold(28), .foregroundColor: QDXColor.primary
        ], for: .selected)
        view.addSubview(segmented)
        segmented.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }
        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    private func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(segmented.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
        let children: [UIViewController] = [recentList, doneList]
        children.forEach { addChild($0) }
        for (i, child) in children.enumerated() {
            scrollView.addSubview(child.view)
            child.view.frame = CGRect(x: CGFloat(i) * Screen.width, y: 0,
                                      width: Screen.width, height: scrollView.bounds.height)
            child.didMove(toParent: self)
        }
        scrollView.contentSize = CGSize(width: Screen.width * CGFloat(children.count), height: 0)
    }

    private func configureChildren() {
        recentList.configure(cityID: cityID, type: type, status: "1", delegate: self)
        doneList.configure(cityID: cityID, type: type, status: "4", delegate: self)
    }

    @objc private func segmentChanged() {
        current = segmented.selectedSegmentIndex
        let offset = CGFloat(current) * Screen.width
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
}

extension ActivityListController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let idx = Int(round(scrollView.contentOffset.x / Screen.width))
        if idx != current {
            current = idx
            segmented.selectedSegmentIndex = idx
        }
    }
}

extension ActivityListController: ActivitySelectionDelegate {
    func activitySelected(_ goods: Goods) {
        let detail = LineDetailViewController()
        detail.goods = goods
        navigationController?.pushViewController(detail, animated: true)
    }
}

// MARK: - 子列表（封装复用，替代 RecentActivityViewController）
final class ActivitySubListController: UIViewController {

    private var cityID = ""
    private var type = "1"
    private var status = "1"
    private weak var delegate: ActivitySelectionDelegate?

    private var items: [Goods] = []
    private let tableView = UITableView(frame: .zero, style: .plain)

    func configure(cityID: String, type: String, status: String,
                   delegate: ActivitySelectionDelegate) {
        self.cityID = cityID
        self.type = type
        self.status = status
        self.delegate = delegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = QDXColor.background
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ActivityCell.self, forCellReuseIdentifier: ActivityCell.reuseID)
        tableView.estimatedRowHeight = 320
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        let header = MJRefreshNormalHeader { [weak self] in self?.loadData() }
        header?.lastUpdatedTimeLabel?.isHidden = true
        tableView.mj_header = header
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if items.isEmpty { tableView.mj_header?.beginRefreshing() }
    }

    private func loadData() {
        ContentAPI.activities(cityID: cityID, type: type, status: status) { [weak self] result in
            DispatchQueue.main.async {
                self?.tableView.mj_header?.endRefreshing()
                switch result {
                case .success(let paged):
                    self?.items = paged.items
                    self?.tableView.reloadData()
                case .failure:
                    break
                }
            }
        }
    }
}

extension ActivitySubListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActivityCell.reuseID, for: indexPath) as! ActivityCell
        cell.configure(with: items[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.activitySelected(items[indexPath.row])
    }
}
