//
//  PointManageControllers.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXPointListViewController.m + QDXPointSettingViewController.m
//  - PointListController：点标管理列表（getPointList + 点击进入设置）
//  - PointSettingController：点标位置设置（MAMapView + 当前位置显示 + pointModify 提交）
//
//  PointModel 已并入此文件，无需单独建模文件。
//

import UIKit
import SnapKit
import MAMapKit
import AMapFoundationKit
import MBProgressHUD
import Alamofire

// MARK: - Point 模型

struct PointItem {
    var id:     String   // point_id
    var cn:     String   // point_cn 名称
    var lat:    String   // point_lat
    var lon:    String   // point_lon
    var mac:    String   // point_mac
    var rssi:   String   // point_rssi
    var areaID: String   // area_id
    var sn:     String   // point_sn
    var qr:     String   // point_qr

    init(from dict: [String: Any]) {
        id     = (dict["point_id"]   as? String) ?? ""
        cn     = (dict["point_cn"]   as? String) ?? ""
        lat    = (dict["point_lat"]  as? String) ?? ""
        lon    = (dict["point_lon"]  as? String) ?? ""
        mac    = (dict["point_mac"]  as? String) ?? ""
        rssi   = (dict["point_rssi"] as? String) ?? ""
        areaID = (dict["area_id"]    as? String) ?? ""
        sn     = (dict["point_sn"]   as? String) ?? ""
        qr     = (dict["point_qr"]   as? String) ?? ""
    }
}

// MARK: - Point API

enum PointAPI {
    /// 获取点标列表
    static func list(completion: @escaping (Result<[PointItem], APIError>) -> Void) {
        NetworkService.shared.requestJSON(path: APIPath.getPointList) { result in
            switch result {
            case .success(let dict):
                if (dict["Code"] as? Int) == 1,
                   let arr = dict["Msg"] as? [[String: Any]] {
                    completion(.success(arr.map { PointItem(from: $0) }))
                } else {
                    completion(.success([]))
                }
            case .failure:
                // 请求不到时返回默认空列表
                completion(.success([]))
            }
        }
    }

    /// 修改点标位置
    static func modify(pointID: String, lat: String, lon: String,
                       completion: @escaping (Result<Void, APIError>) -> Void) {
        NetworkService.shared.requestJSON(
            path: APIPath.pointModify,
            parameters: [
                "point_id":  pointID,
                "point_lat": lat,
                "point_lon": lon
            ]
        ) { result in
            switch result {
            case .success(let dict):
                if (dict["Code"] as? Int) == 1 {
                    completion(.success(()))
                } else {
                    completion(.failure(.business(
                        code: dict["Code"] as? Int ?? -1,
                        message: (dict["Msg"] as? String) ?? "提交失败"
                    )))
                }
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }
}

// MARK: - PointListController（替代 QDXPointListViewController）

final class PointListController: BaseViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var points: [PointItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "点标管理"
        view.backgroundColor = QDXColor.background

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PointCell")
        tableView.backgroundColor = QDXColor.background
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    private func loadData() {
        PointAPI.list { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if case .success(let list) = result {
                    self.points = list
                    self.tableView.reloadData()
                    if list.isEmpty { self.showEmpty("暂无点标") } else { self.hideEmpty() }
                }
            }
        }
    }
}

extension PointListController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        points.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PointCell", for: indexPath)
        cell.textLabel?.text = points[indexPath.row].cn
        cell.textLabel?.font = QDXFont.medium(30)
        cell.textLabel?.textColor = QDXColor.black
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .white
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Screen.fit(96)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = PointSettingController()
        vc.point = points[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - PointSettingController（替代 QDXPointSettingViewController）

final class PointSettingController: BaseViewController, MAMapViewDelegate {

    /// 当前点标（外部注入）
    var point: PointItem!

    private var mapView: MAMapView!
    private let scrollView = UIScrollView()
    private let playView = UIView()
    private let setView = UIView()
    private let localLabel = UILabel()
    private let nowLabel = UILabel()
    private let latLabel = UILabel()
    private let lonLabel = UILabel()
    private var annotation: MAPointAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = point?.cn ?? "点标设置"
        view.backgroundColor = UIColor(white: 0.949, alpha: 1.0)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "提交", style: .plain, target: self, action: #selector(commitTapped)
        )

        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor(white: 0.949, alpha: 1.0)
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 1. 地图（与 OC 一致：先放地图占满，再覆盖两个白色卡片）
        mapView = MAMapView(frame: view.bounds)
        mapView.mapType = .standard
        mapView.delegate = self
        mapView.showsScale = false
        mapView.rotateCameraEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        scrollView.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Screen.height)
        }

        // 2. 已设置卡片
        playView.backgroundColor = .white
        scrollView.addSubview(playView)
        playView.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(Screen.fit(24))
            make.left.right.equalToSuperview().inset(Screen.fit(24))
            make.height.equalTo(Screen.fit(80))
        }

        localLabel.font = .systemFont(ofSize: 15)
        localLabel.textAlignment = .left
        if let p = point {
            let text = "已设置：经度\(p.lat)  纬度\(p.lon)"
            let attr = NSMutableAttributedString(string: text)
            attr.addAttribute(.foregroundColor, value: QDXColor.gray, range: NSRange(location: 0, length: 6))
            if text.count > 7 + p.lat.count {
                attr.addAttribute(.foregroundColor, value: QDXColor.gray,
                                  range: NSRange(location: 7 + p.lat.count, length: 3))
            }
            localLabel.attributedText = attr
        }
        playView.addSubview(localLabel)
        localLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Screen.fit(24))
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-Screen.fit(24))
        }

        // 3. 当前位置卡片
        setView.backgroundColor = .white
        scrollView.addSubview(setView)
        setView.snp.makeConstraints { make in
            make.top.equalTo(playView.snp.bottom).offset(Screen.fit(24))
            make.left.right.equalTo(playView)
            make.height.equalTo(Screen.fit(240))
            make.bottom.equalToSuperview().offset(-Screen.fit(24))
        }

        nowLabel.text = "当前位置"
        nowLabel.font = .systemFont(ofSize: 18)
        nowLabel.textColor = QDXColor.gray
        setView.addSubview(nowLabel)
        nowLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen.fit(26))
            make.left.equalToSuperview().offset(Screen.fit(24))
        }

        latLabel.font = .systemFont(ofSize: 18)
        latLabel.textColor = QDXColor.black
        setView.addSubview(latLabel)
        latLabel.snp.makeConstraints { make in
            make.top.equalTo(nowLabel.snp.bottom).offset(Screen.fit(54))
            make.left.equalTo(nowLabel)
        }

        lonLabel.font = .systemFont(ofSize: 18)
        lonLabel.textColor = QDXColor.black
        setView.addSubview(lonLabel)
        lonLabel.snp.makeConstraints { make in
            make.top.equalTo(latLabel.snp.bottom).offset(Screen.fit(54))
            make.left.equalTo(nowLabel)
        }

        // 4. 添加点标标注
        if let p = point {
            let ann = MAPointAnnotation()
            let coor = CLLocationCoordinate2D(
                latitude: CLLocationDegrees(p.lat) ?? 0,
                longitude: CLLocationDegrees(p.lon) ?? 0
            )
            ann.coordinate = coor
            ann.title = p.cn
            mapView.addAnnotation(ann)
            annotation = ann
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 与 OC 一致：清理地图资源
        mapView.showsUserLocation = false
        mapView.userTrackingMode = .follow
        mapView.layer.removeAllAnimations()
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        mapView.delegate = nil
    }

    @objc private func commitTapped() {
        // 与 OC 一致：从 label 文本截取数值（去除前 3 字符 "经度："/"纬度："）
        let latStr = String((latLabel.text ?? "").dropFirst(3))
        let lonStr = String((lonLabel.text ?? "").dropFirst(3))
        guard let p = point, !latStr.isEmpty, !lonStr.isEmpty else {
            showToast("请等待定位")
            return
        }

        PointAPI.modify(pointID: p.id, lat: latStr, lon: lonStr) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.showToast("提交成功")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let e):
                    self.showToast(e.localizedDescription)
                }
            }
        }
    }

    private func showToast(_ text: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = text
        hud.mode = .text
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1.5)
    }

    // MARK: - MAMapViewDelegate

    func mapView(_ mapView: MAMapView, didUpdate userLocation: MAUserLocation!,
                 updatingLocation: Bool) {
        guard updatingLocation, let coord = userLocation?.location?.coordinate else { return }

        // 与 OC 一致：label 显示 "经度：xxx"/"纬度：xxx"
        let lonAttr = NSMutableAttributedString(string: "纬度：\(coord.longitude)")
        lonAttr.addAttribute(.foregroundColor, value: QDXColor.gray, range: NSRange(location: 0, length: 3))
        lonLabel.attributedText = lonAttr

        let latAttr = NSMutableAttributedString(string: "经度：\(coord.latitude)")
        latAttr.addAttribute(.foregroundColor, value: QDXColor.gray, range: NSRange(location: 0, length: 3))
        latLabel.attributedText = latAttr

        mapView.setCenter(coord, animated: true)
    }

    func mapView(_ mapView: MAMapView, viewFor annotation: MAAnnotation) -> MAAnnotationView? {
        guard annotation is MAPointAnnotation else { return nil }
        let reuseID = "PointAnnotation"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MAPinAnnotationView
        if view == nil {
            view = MAPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        }
        view?.image = UIImage(named: "targetPoint")
        view?.canShowCallout = false
        view?.centerOffset = CGPoint(x: 0, y: -18)
        return view
    }
}
