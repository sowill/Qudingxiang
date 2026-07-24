//
//  MapViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 MapViewController.m：高德 MAMapKit 地图 + 自定义底图 + 点标
//  视觉：圆角悬浮按钮（关闭/定位/切换地图）+ 卫星/平面切换菜单
//

import UIKit
import SnapKit
import MAMapKit
import AMapFoundationKit

final class MapViewController: BaseViewController, MAMapViewDelegate {

    /// 当前线路 ID
    var mylineID: String = ""

    private var mapView: MAMapView!
    private var groundOverlay: MAGroundOverlay?
    private var taskLocation: TaskLocation?

    private let closeButton    = UIButton(type: .system)
    private let locationButton = UIButton(type: .system)
    private let changeMapButton = UIButton(type: .system)

    override var prefersStatusBarHidden: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "地图"
        setupMap()
        setupButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        mapView.showsUserLocation = false
        mapView.delegate = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTaskLocation()
    }

    // MARK: - 地图
    private func setupMap() {
        mapView = MAMapView(frame: view.bounds)
        mapView.mapType = .standard
        mapView.showsScale = false
        mapView.rotateCameraEnabled = false
        view.addSubview(mapView)
        mapView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - 悬浮按钮
    private func setupButtons() {
        configMapButton(closeButton, icon: "xmark")
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-Screen.safeAreaBottom - 24)
            make.width.height.equalTo(48)
        }

        configMapButton(locationButton, icon: "location.fill")
        locationButton.tintColor = QDXColor.primary
        locationButton.addTarget(self, action: #selector(locationTapped), for: .touchUpInside)
        view.addSubview(locationButton)
        locationButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(closeButton)
            make.width.height.equalTo(48)
        }

        configMapButton(changeMapButton, icon: "map.fill")
        changeMapButton.addTarget(self, action: #selector(changeMapTapped), for: .touchUpInside)
        view.addSubview(changeMapButton)
        changeMapButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(locationButton.snp.top).offset(-12)
            make.width.height.equalTo(48)
        }
    }

    private func configMapButton(_ btn: UIButton, icon: String) {
        btn.setImage(UIImage(systemName: icon), for: .normal)
        btn.tintColor = .darkText
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        btn.layer.cornerRadius = 24
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.15
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 6
    }

    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }
    @objc private func locationTapped() {
        let span = MACoordinateSpanMake(0.008, 0.008)
        let region = MACoordinateRegionMake(mapView.userLocation.location?.coordinate ?? kCLLocationCoordinate2DInvalid, span)
        mapView.setRegion(region, animated: true)
    }
    @objc private func changeMapTapped() {
        let alert = UIAlertController(title: "切换地图", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "卫星地图", style: .default) { [weak self] _ in
            self?.mapView.mapType = .satellite
        })
        alert.addAction(UIAlertAction(title: "平面地图", style: .default) { [weak self] _ in
            self?.mapView.mapType = .standard
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - 数据 + 点标
    private func loadTaskLocation() {
        GameAPI.taskLocation(mylineID: mylineID) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let loc) = result {
                    self?.taskLocation = loc
                    self?.setupPointsAndMap()
                }
            }
        }
    }

    private func setupPointsAndMap() {
        guard let loc = taskLocation else { return }
        if loc.lineMapon == "1" {
            // 自定义底图覆盖
            let bounds = MACoordinateBoundsMake(
                CLLocationCoordinate2DMake(Double(loc.lineBotLat ?? "0") ?? 0,
                                           Double(loc.lineBotLon ?? "0") ?? 0),
                CLLocationCoordinate2DMake(Double(loc.lineTopLat ?? "0") ?? 0,
                                           Double(loc.lineTopLon ?? "0") ?? 0)
            )
            if let urlString = loc.lineMap, let url = URL(string: APIHost.oldBase + urlString),
               let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                groundOverlay = MAGroundOverlay(bounds: bounds, icon: image)
                if let overlay = groundOverlay {
                    mapView.add(overlay)
                    mapView.setVisibleMapRect(overlay.boundingMapRect, animated: true)
                }
            }
        } else {
            let span = MACoordinateSpanMake(0.008, 0.008)
            let region = MACoordinateRegionMake(
                mapView.userLocation.location?.coordinate ?? kCLLocationCoordinate2DInvalid, span)
            mapView.setRegion(region, animated: true)
        }
        // 点标
        for p in loc.pointmaps {
            let annotation = MAPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(
                Double(p.lat ?? "0") ?? 0, Double(p.lon ?? "0") ?? 0)
            annotation.title = p.pointmapCn
            mapView.addAnnotation(annotation)
        }
    }

    // MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView, rendererFor overlay: MAOverlay) -> MAOverlayRenderer! {
        if let ground = overlay as? MAGroundOverlay {
            return MAGroundOverlayRenderer(groundOverlay: ground)
        }
        return nil
    }

    func mapView(_ mapView: MAMapView, viewFor annotation: MAAnnotation) -> MAAnnotationView? {
        guard annotation is MAPointAnnotation else { return nil }
        let reuseID = "pointAnnotation"
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
