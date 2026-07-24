//
//  PlaceController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 PlaceViewController：场地列表（网格）+ 城市切换入口
//

import UIKit
import SnapKit
import SDWebImage
import MJRefresh

protocol CitySelectionDelegate: AnyObject {
    func didSelectCity(_ city: City)
}

final class PlaceController: BaseViewController {

    /// 导航栏标题
    var navTitle: String = "场地" { didSet { navigationItem.title = navTitle } }
    /// 当前城市ID
    var cityID: String = "" {
        didSet { if isViewLoaded { loadData() } }
    }
    /// 当前城市名（用于按钮显示）
    var cityCn: String = "北京" { didSet { cityButton.setTitle(cityCn, for: .normal) } }
    /// 城市列表（用于城市选择页）
    var cities: [City] = []

    private let cityButton = UIButton(type: .system)
    private var items: [Area] = []
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (Screen.width - 48) / 2, height: 200)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navTitle
        setupCityButton()
        setupCollectionView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if items.isEmpty { loadData() }
    }

    private func setupCityButton() {
        cityButton.setTitle(cityCn, for: .normal)
        cityButton.titleLabel?.font = QDXFont.medium(28)
        cityButton.setTitleColor(QDXColor.primary, for: .normal)
        cityButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        cityButton.tintColor = QDXColor.primary
        cityButton.semanticContentAttribute = .forceRightToLeft
        cityButton.sizeToFit()
        cityButton.addTarget(self, action: #selector(cityTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cityButton)
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PlaceCell.self, forCellWithReuseIdentifier: PlaceCell.reuseID)
        let header = MJRefreshNormalHeader { [weak self] in self?.loadData() }
        header?.lastUpdatedTimeLabel?.isHidden = true
        collectionView.mj_header = header
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
    }

    @objc private func cityTapped() {
        let vc = CityChoiceController()
        vc.cities = cities
        vc.currentCity = cityCn
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    private func loadData() {
        guard !cityID.isEmpty else { return }
        ContentAPI.areas(cityID: cityID) { [weak self] result in
            DispatchQueue.main.async {
                self?.collectionView.mj_header?.endRefreshing()
                switch result {
                case .success(let paged):
                    self?.items = paged.items
                    self?.collectionView.reloadData()
                    if paged.items.isEmpty { self?.showEmpty("该城市暂无场地") } else { self?.hideEmpty() }
                case .failure(let err):
                    self?.showToast(err.localizedDescription)
                }
            }
        }
    }
}

extension PlaceController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceCell.reuseID, for: indexPath) as! PlaceCell
        cell.configure(with: items[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = AreaGoodsListController()
        vc.area = items[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension PlaceController: CitySelectionDelegate {
    func didSelectCity(_ city: City) {
        cityID = city.id ?? ""
        cityCn = city.cn ?? ""
    }
}

// MARK: - 场地卡片
final class PlaceCell: UICollectionViewCell {
    static let reuseID = "PlaceCell"
    private let coverView  = UIImageView()
    private let titleLabel = UILabel()
    private let cityLabel  = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        coverView.contentMode = .scaleAspectFill
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = 12
        contentView.addSubview(coverView)
        coverView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(140)
        }
        titleLabel.font = QDXFont.semibold(28)
        titleLabel.textColor = QDXColor.black
        titleLabel.numberOfLines = 1
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(coverView.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        cityLabel.font = QDXFont.regular(22)
        cityLabel.textColor = QDXColor.gray
        contentView.addSubview(cityLabel)
        cityLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with a: Area) {
        titleLabel.text = a.cn
        cityLabel.text  = (a.cityCn ?? "") + " · " + (a.countyCn ?? "")
        if let urlString = a.url, let url = URL(string: APIHost.oldBase + urlString) {
            coverView.sd_setImage(with: url, placeholderImage: UIImage(named: "banner_cell"))
        } else {
            coverView.image = UIImage(named: "banner_cell")
        }
    }
}
