//
//  HomeController.swift
//  趣定向 (Swift 迁移版)
//
//  首页：顶部城市选择 + Banner 轮播 + 活动列表（合作商家 / 赛事）
//  替代 HomeController.m，使用 UICollectionViewCompositionalLayout 现代布局
//

import UIKit
import SnapKit
import SDWebImage
import MJRefresh

final class HomeController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    private var banners: [Banner] = []
    private var goods: [Goods] = []
    private var partners: [Partner] = []

    private let bannerView = UIScrollView()
    private let pageControl = UIPageControl()
    private let cityButton = UIButton(type: .system)
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            // 每行一个横滑卡片
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(140)
                )
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(140)
                ),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12
            section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 24, trailing: 16)
            return section
        }
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "首页"
        setupNavigationBar()
        setupBanner()
        setupCollectionView()
        setupRefresh()
        loadData()
    }

    // MARK: - 导航栏（城市选择）
    private func setupNavigationBar() {
        cityButton.setTitle("北京 ▾", for: .normal)
        cityButton.setTitleColor(.darkText, for: .normal)
        cityButton.titleLabel?.font = QDXFont.medium(28)
        cityButton.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cityButton)

        let searchItem = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain, target: self, action: #selector(searchTapped)
        )
        searchItem.tintColor = .darkText
        navigationItem.rightBarButtonItem = searchItem
    }

    // MARK: - Banner
    private func setupBanner() {
        bannerView.isPagingEnabled = true
        bannerView.showsHorizontalScrollIndicator = false
        bannerView.layer.cornerRadius = 12
        bannerView.clipsToBounds = true
        view.addSubview(bannerView)
        bannerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(160)
        }
        view.addSubview(pageControl)
        pageControl.currentPageIndicatorTintColor = QDXColor.primary
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.6)
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(bannerView).offset(-8)
            make.centerX.equalTo(bannerView)
        }
    }

    // MARK: - CollectionView
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HomeGoodsCell.self, forCellWithReuseIdentifier: HomeGoodsCell.reuseID)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(bannerView.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }
    }

    private func setupRefresh() {
        let header = MJRefreshNormalHeader { [weak self] in self?.loadData() }
        header?.lastUpdatedTimeLabel?.isHidden = true
        collectionView.mj_header = header
        collectionView.mj_footer = MJRefreshAutoNormalFooter { [weak self] in
            // 分页加载（占位）
            self?.collectionView.mj_footer?.endRefreshing()
        }
    }

    // MARK: - 数据
    private func loadData() {
        // Banner
        NetworkService.shared.requestJSON(path: APIPath.getPlayimg, needToken: false) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let dict) = result, let list = dict["Msg"] as? [[String: Any]] {
                    self?.banners = list.compactMap { try? JSONSerialization.jsonObject(with: JSONSerialization.data(withJSONObject: $0)) as? [String: Any] }
                        .compactMap { Banner(from: $0) }
                    self?.refreshBanner()
                }
                self?.collectionView.mj_header?.endRefreshing()
            }
        }
        // 首页产品列表
        NetworkService.shared.requestJSON(path: APIPath.newGoods, needToken: false) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let dict) = result, let list = dict["Msg"] as? [[String: Any]] {
                    self?.goods = list.compactMap { Goods(from: $0) }
                    self?.collectionView.reloadData()
                    if self?.goods.isEmpty == true { self?.showEmpty("暂无活动") } else { self?.hideEmpty() }
                }
            }
        }
    }

    private func refreshBanner() {
        bannerView.subviews.forEach { $0.removeFromSuperview() }
        for (i, b) in banners.enumerated() {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            if let urlString = b.url, let url = URL(string: APIHost.oldBase + urlString) {
                iv.sd_setImage(with: url)
            }
            bannerView.addSubview(iv)
            iv.frame = CGRect(x: CGFloat(i) * Screen.width - 32, y: 0,
                              width: Screen.width - 32, height: 160)
        }
        bannerView.contentSize = CGSize(width: CGFloat(banners.count) * (Screen.width - 32), height: 160)
        pageControl.numberOfPages = banners.count
    }

    @objc private func searchTapped() {
        showToast("搜索功能待接入")
    }

    // MARK: - DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        goods.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeGoodsCell.reuseID, for: indexPath) as! HomeGoodsCell
        cell.configure(with: goods[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detail = LineDetailViewController()
        detail.goods = goods[indexPath.item]
        navigationController?.pushViewController(detail, animated: true)
    }
}

// MARK: - 首页活动卡片
final class HomeGoodsCell: UICollectionViewCell {
    static let reuseID = "HomeGoodsCell"

    private let cardView    = UIView()
    private let coverView   = UIImageView()
    private let titleLabel  = UILabel()
    private let addressLabel = UILabel()
    private let priceLabel  = UILabel()
    private let statusBadge = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { $0.edges.equalToSuperview() }

        coverView.contentMode = .scaleAspectFill
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = 8
        cardView.addSubview(coverView)
        coverView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(12)
            make.width.equalTo(120)
        }

        titleLabel.font = QDXFont.semibold(30)
        titleLabel.textColor = QDXColor.black
        titleLabel.numberOfLines = 2
        cardView.addSubview(titleLabel)

        addressLabel.font = QDXFont.regular(24)
        addressLabel.textColor = QDXColor.gray
        addressLabel.numberOfLines = 1
        cardView.addSubview(addressLabel)

        priceLabel.font = QDXFont.bold(32)
        priceLabel.textColor = QDXColor.accent
        cardView.addSubview(priceLabel)

        statusBadge.font = QDXFont.medium(20)
        statusBadge.textColor = .white
        statusBadge.backgroundColor = QDXColor.green
        statusBadge.textAlignment = .center
        statusBadge.layer.cornerRadius = 4
        statusBadge.layer.masksToBounds = true
        cardView.addSubview(statusBadge)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(coverView.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
            make.top.equalTo(coverView).offset(4)
        }
        addressLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(coverView).offset(-4)
        }
        statusBadge.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.bottom.equalTo(coverView)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(44)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with g: Goods) {
        titleLabel.text = g.cn
        addressLabel.text = g.address
        if let price = g.price { priceLabel.text = "¥ \(price)" }
        statusBadge.text = g.statusCn ?? "进行中"
        if let urlString = g.url, let url = URL(string: APIHost.oldBase + urlString) {
            coverView.sd_setImage(with: url)
        }
    }
}

// 为 Banner / Goods 增加从 [String:Any] 的便捷构造（部分接口字段动态）
extension Banner {
    init?(from dict: [String: Any]) {
        id = dict["playimg_id"] as? String
        url = dict["playimg_url"] as? String
        link = dict["playimg_link"] as? String
    }
}
extension Goods {
    init(from dict: [String: Any]) {
        id       = dict["goods_id"]        as? String
        cn       = dict["goods_cn"]        as? String
        index    = dict["goods_index"]     as? String
        topShow  = dict["goods_topshow"]   as? String
        onoffCn  = dict["onoff_cn"]        as? String
        statusID = dict["goodstatus_id"]   as? String
        statusCn = dict["goodstatus_cn"]   as? String
        price    = dict["goods_price"]     as? String
        url      = dict["goods_url"]       as? String
        flag     = dict["goods_flag"]      as? String
        des      = dict["goods_des"]       as? String
        notice   = dict["goods_notice"]    as? String
        prompt   = dict["goods_prompt"]    as? String
        time     = dict["goods_time"]      as? String
        address  = dict["goods_address"]   as? String
        lineID   = dict["line_id"]         as? String
        lineCn   = dict["line_cn"]         as? String
        preview  = dict["goods_preview"]   as? String
        cdate    = dict["goods_cdate"]     as? String
        typeID   = dict["goodstype_id"]    as? String
        typeCn   = dict["goodstype_cn"]    as? String
    }
}
