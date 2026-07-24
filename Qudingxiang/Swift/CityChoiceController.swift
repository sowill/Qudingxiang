//
//  CityChoiceController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 LocationChoiceViewController：城市选择（定位 + 开放城市网格）
//

import UIKit
import SnapKit

final class CityChoiceController: BaseViewController {

    var cities: [City] = []
    var currentCity: String = ""
    weak var delegate: CitySelectionDelegate?

    private let locationLabel = UILabel()
    private let locationButton = UIButton(type: .system)
    private let openCityLabel = UILabel()
    private let collectionView: UICollectionView = {
        let layout = LeftAlignedFlowLayout()
        layout.estimatedItemSize = CGSize(width: 80, height: 36)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "切换城市"
        setupUI()
        if cities.isEmpty { loadCities() }
    }

    private func setupUI() {
        locationLabel.text = "定位城市"
        locationLabel.font = QDXFont.medium(26)
        locationLabel.textColor = QDXColor.gray
        view.addSubview(locationLabel)
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.equalToSuperview().offset(16)
        }
        locationButton.setTitle(currentCity.isEmpty ? "定位失败" : currentCity, for: .normal)
        locationButton.setTitleColor(.white, for: .normal)
        locationButton.titleLabel?.font = QDXFont.medium(28)
        locationButton.backgroundColor = QDXColor.primary
        locationButton.layer.cornerRadius = 6
        locationButton.addTarget(self, action: #selector(locationTapped), for: .touchUpInside)
        view.addSubview(locationButton)
        locationButton.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(100)
            make.height.equalTo(36)
        }

        openCityLabel.text = "开放城市"
        openCityLabel.font = QDXFont.medium(26)
        openCityLabel.textColor = QDXColor.gray
        view.addSubview(openCityLabel)
        openCityLabel.snp.makeConstraints { make in
            make.top.equalTo(locationButton.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(16)
        }

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CityCell.self, forCellWithReuseIdentifier: CityCell.reuseID)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(openCityLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }

    private func loadCities() {
        ContentAPI.cities { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let list) = result {
                    self?.cities = list
                    self?.collectionView.reloadData()
                }
            }
        }
    }

    @objc private func locationTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension CityChoiceController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cities.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CityCell.reuseID, for: indexPath) as! CityCell
        cell.configure(with: cities[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let city = cities[indexPath.item]
        delegate?.didSelectCity(city)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - 城市标签 Cell
final class CityCell: UICollectionViewCell {
    static let reuseID = "CityCell"
    private let titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 6
        layer.borderColor  = QDXColor.lineColor.cgColor
        layer.borderWidth  = 0.5
        titleLabel.font = QDXFont.medium(26)
        titleLabel.textColor = QDXColor.black
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(with c: City) {
        titleLabel.text = c.cn
    }
}

// MARK: - 左对齐 FlowLayout（开放城市标签自动换行）
final class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let original = super.layoutAttributesForElements(in: rect) else { return nil }
        var x: CGFloat = sectionInset.left
        for attr in original where attr.representedElementCategory == .cell {
            if attr.frame.origin.x < x {
                attr.frame.origin.x = x
            }
            x = attr.frame.maxX + minimumInteritemSpacing
        }
        return original
    }
}
