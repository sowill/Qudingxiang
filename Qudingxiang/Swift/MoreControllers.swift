//
//  MoreControllers.swift
//  趣定向 (Swift 迁移版)
//
//  集中迁移剩余零散控制器：
//  - SignViewController           → SignController（个性签名编辑）
//  - MoreCooperationViewController → MoreCooperationController（合作单位列表）
//  - QDXLineChooseViewController  → LineChooseController（线路选择 + 图片放大）
//
//  视觉：卡片化 + SnapKit 链式布局 + UICollectionViewCompositionalLayout
//

import UIKit
import SnapKit
import SDWebImage
import MBProgressHUD

// MARK: - SignController（替代 SignViewController）

/// 个性签名编辑页：UITextView 编辑 → 调用 modify 提交 customer_signature
final class SignController: BaseViewController {

    /// 进入时预填的签名（默认读取当前用户签名）
    var initialSignature: String? {
        didSet { signView.text = initialSignature }
    }

    private let signView = UITextView()
    private let placeholderLabel = UILabel()
    private let commitButton = UIButton(type: .system)
    private let countLabel = UILabel()
    private let maxCount = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "个性签名"
        view.backgroundColor = QDXColor.background
        setupUI()
        signView.becomeFirstResponder()
    }

    private func setupUI() {
        // 卡片容器
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 8
        view.addSubview(card)
        card.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen.navBarHeight + 16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(140)
        }

        signView.font = .systemFont(ofSize: 16)
        signView.textColor = UIColor(white: 0.2, alpha: 1.0)
        signView.backgroundColor = .clear
        signView.delegate = self
        signView.returnKeyType = .done
        card.addSubview(signView)
        signView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-26)
        }

        placeholderLabel.text = "请输入个性签名"
        placeholderLabel.textColor = UIColor(white: 0.75, alpha: 1.0)
        placeholderLabel.font = .systemFont(ofSize: 16)
        card.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.top.left.equalTo(signView).offset(6)
        }

        countLabel.textColor = QDXColor.gray
        countLabel.font = .systemFont(ofSize: 12)
        countLabel.textAlignment = .right
        card.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(10)
        }

        // 预填当前签名
        if initialSignature == nil {
            initialSignature = AccountManager.shared.current?.signature
        }
        signView.text = initialSignature
        updatePlaceholder()

        // 提交按钮
        commitButton.setTitle("提交", for: .normal)
        commitButton.setTitleColor(.white, for: .normal)
        commitButton.setTitleColor(UIColor(white: 0.6, alpha: 1.0), for: .highlighted)
        commitButton.backgroundColor = QDXColor.primary
        commitButton.layer.cornerRadius = 20
        commitButton.addTarget(self, action: #selector(commitTapped), for: .touchUpInside)
        view.addSubview(commitButton)
        commitButton.snp.makeConstraints { make in
            make.top.equalTo(card.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
    }

    private func updatePlaceholder() {
        let text = signView.text ?? ""
        placeholderLabel.isHidden = !text.isEmpty
        countLabel.text = "\(text.count)/\(maxCount)"
    }

    @objc private func commitTapped() {
        view.endEditing(true)
        let text = signView.text ?? ""
        guard !text.isEmpty else {
            showToast("签名不能为空")
            return
        }
        showLoading("提交中...")
        MineAPI.modify(params: ["customer_signature": text]) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case .success:
                    self.showToast("修改成功")
                    NotificationCenter.default.post(name: .stateRefresh, object: nil)
                    self.navigationController?.popViewController(animated: true)
                case .failure(let e):
                    self.showToast(e.localizedDescription)
                }
            }
        }
    }
}

extension SignController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholder()
        if (textView.text ?? "").count > maxCount {
            textView.text = String((textView.text ?? "").prefix(maxCount))
            updatePlaceholder()
        }
    }
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

// MARK: - MoreCooperationController（替代 MoreCooperationViewController）

/// 合作单位列表页：UICollectionView 网格展示 Partner logo
final class MoreCooperationController: BaseViewController {

    /// 外部传入的合作单位数据源
    var partners: [Partner] = [] {
        didSet { collectionView.reloadData() }
    }

    private let collectionView: UICollectionView
    private static let reuseID = "LogoCell"

    init() {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(Screen.fit(140))
                ),
                subitems: [item, item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            return section
        }
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "合作单位"
        view.backgroundColor = QDXColor.background

        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(LogoCell.self, forCellWithReuseIdentifier: Self.reuseID)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

extension MoreCooperationController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection s: Int) -> Int {
        partners.count
    }
    func collectionView(_ cv: UICollectionView, cellForItemAt ip: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: Self.reuseID, for: ip) as! LogoCell
        cell.configure(with: partners[ip.item])
        return cell
    }
}

/// 合作单位 logo 卡片：圆角 + 阴影
final class LogoCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4

        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(12)
            make.height.equalTo(Screen.fit(90))
        }

        titleLabel.font = QDXFont.regular(24)
        titleLabel.textColor = QDXColor.gray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(6)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with p: Partner) {
        titleLabel.text = p.cn
        if let s = p.url, !s.isEmpty {
            let urlStr = s.hasPrefix("http") ? s : (APIHost.oldBase + s)
            imageView.sd_setImage(with: URL(string: urlStr),
                                  placeholderImage: UIImage(named: "banner_cell"))
        } else {
            imageView.image = UIImage(named: "banner_cell")
        }
    }
}

// MARK: - LineChooseController（替代 QDXLineChooseViewController）

/// 线路选择页：展示线路地图 + 介绍 → 选择后进入协议页
final class LineChooseController: BaseViewController {

    /// 外部传入：线路 ID（OC 中传入的是 QDXLineModel 的 line_id）
    var lineID: String = ""

    private let scrollView = UIScrollView()
    private let mapImageView = UIImageView()
    private let placeLabel = UILabel()
    private let detailsLabel = UILabel()
    private let selectButton = UIButton(type: .system)

    private var mapImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "选择路线"
        view.backgroundColor = QDXColor.background
        setupUI()
        loadData()
    }

    private func setupUI() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 地图卡片
        mapImageView.contentMode = .scaleAspectFill
        mapImageView.clipsToBounds = true
        mapImageView.layer.cornerRadius = 8
        mapImageView.backgroundColor = .white
        mapImageView.isUserInteractionEnabled = true
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(zoomMap))
        doubleTap.numberOfTapsRequired = 2
        mapImageView.addGestureRecognizer(doubleTap)
        scrollView.addSubview(mapImageView)
        mapImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(Screen.width - 32)
        }

        // 地点名横幅
        let banner = UIView()
        banner.backgroundColor = UIColor(hex: 0x93E6FB)
        banner.layer.cornerRadius = 8
        scrollView.addSubview(banner)
        banner.snp.makeConstraints { make in
            make.top.equalTo(mapImageView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }

        placeLabel.font = QDXFont.semibold(34)
        placeLabel.textColor = QDXColor.primary
        banner.addSubview(placeLabel)
        placeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }

        // 路线介绍标题
        let infoTitle = UILabel()
        infoTitle.text = "路线介绍"
        infoTitle.font = QDXFont.semibold(34)
        infoTitle.textColor = QDXColor.primary
        scrollView.addSubview(infoTitle)
        infoTitle.snp.makeConstraints { make in
            make.top.equalTo(banner.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }

        // 详情文本
        detailsLabel.font = .systemFont(ofSize: 16)
        detailsLabel.textColor = QDXColor.gray
        detailsLabel.numberOfLines = 0
        scrollView.addSubview(detailsLabel)
        detailsLabel.snp.makeConstraints { make in
            make.top.equalTo(infoTitle.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }

        // 底部选择按钮
        selectButton.setTitle("选择", for: .normal)
        selectButton.setTitleColor(.white, for: .normal)
        selectButton.setTitleColor(UIColor(white: 0.6, alpha: 1.0), for: .highlighted)
        selectButton.backgroundColor = QDXColor.primary
        selectButton.layer.cornerRadius = 20
        selectButton.addTarget(self, action: #selector(selectTapped), for: .touchUpInside)
        view.addSubview(selectButton)
        selectButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-Screen.safeAreaBottom - 16)
            make.height.equalTo(40)
        }
    }

    private func loadData() {
        showLoading()
        NetworkService.shared.requestJSON(
            path: APIPath.lineInfoUrl,
            parameters: ["line_id": lineID],
            needToken: false
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case .success(let dict):
                    if (dict["Code"] as? Int) == 1, let msg = dict["Msg"] as? [String: Any] {
                        let mapStr = (msg["area"] as? [String: Any])?["map"] as? String ?? ""
                        let sub = msg["line_sub"] as? String ?? ""
                        let desc = msg["description"] as? String ?? ""
                        self.placeLabel.text = sub
                        self.detailsLabel.text = desc
                        if !mapStr.isEmpty {
                            let urlStr = mapStr.hasPrefix("http") ? mapStr : (APIHost.oldBase + mapStr)
                            self.mapImageView.sd_setImage(
                                with: URL(string: urlStr),
                                placeholderImage: UIImage(named: "banner_cell")
                            ) { img, _, _, _ in
                                self.mapImage = img
                            }
                        }
                    }
                case .failure(let e):
                    self.showToast(e.localizedDescription)
                }
            }
        }
    }

    @objc private func selectTapped() {
        let alert = UIAlertController(title: "提示", message: "确定你所选择的比赛线路吗？",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            self?.confirmSelect()
        })
        present(alert, animated: true)
    }

    private func confirmSelect() {
        showLoading()
        NetworkService.shared.requestJSON(
            path: APIPath.choiceUrl,
            parameters: ["line_id": lineID]
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoading()
                switch result {
                case .success(let dict):
                    if (dict["Code"] as? Int) == 1 {
                        let vc = ProtocolViewController()
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        self.showToast((dict["Msg"] as? String) ?? "选择失败")
                    }
                case .failure(let e):
                    self.showToast(e.localizedDescription)
                }
            }
        }
    }

    @objc private func zoomMap() {
        guard let img = mapImage ?? mapImageView.image else { return }
        let viewer = FullScreenImageViewController(image: img)
        viewer.modalPresentationStyle = .fullScreen
        present(viewer, animated: true)
    }
}

// MARK: - FullScreenImageViewController（替代 JTSImageViewController）

/// 轻量级全屏图片查看器：单击关闭，双击缩放
final class FullScreenImageViewController: UIViewController, UIScrollViewDelegate {

    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override var prefersStatusBarHidden: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        scrollView.frame = view.bounds
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.delegate = self
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scrollView)

        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.frame = scrollView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(imageView)

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(close))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
        doubleTap.numberOfTapsRequired = 2
        singleTap.require(toFail: doubleTap)
        view.addGestureRecognizer(singleTap)
        view.addGestureRecognizer(doubleTap)
    }

    func viewForZooming(in sv: UIScrollView) -> UIView? { imageView }

    @objc private func close() {
        dismiss(animated: true)
    }

    @objc private func doubleTapped(_ tap: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let point = tap.location(in: imageView)
            let scale = scrollView.maximumZoomScale
            scrollView.zoom(to: CGRect(x: point.x - 50, y: point.y - 50, width: 100, height: 100),
                            animated: true)
            _ = scale
        }
    }
}
