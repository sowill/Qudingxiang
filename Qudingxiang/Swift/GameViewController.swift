//
//  GameViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXGameViewController：定向游戏核心
//  集成 CoreBluetooth 感应 Beacon，触发点标任务
//

import UIKit
import SnapKit
import CoreBluetooth
import AudioToolbox
import MBProgressHUD

final class GameViewController: BaseViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var points: [PointModel] = []
    private var central: CBCentralManager?
    private var discoveredPeripherals: [UUID: CBPeripheral] = [:]

    /// 当前进度视图
    private let progressContainer = UIView()
    private let progressLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)

    struct PointModel {
        let id: String
        let cn: String
        var finished: Bool
        let mac: String?
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "定向游戏"
        setupProgressView()
        setupTableView()
        setupBluetooth()
    }

    // MARK: - 进度
    private func setupProgressView() {
        progressContainer.backgroundColor = .white
        progressContainer.layer.cornerRadius = 12
        view.addSubview(progressContainer)
        progressContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(80)
        }
        progressLabel.text = "已完成 0 / 0"
        progressLabel.font = QDXFont.medium(28)
        progressLabel.textColor = QDXColor.black
        progressContainer.addSubview(progressLabel)
        progressLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(16)
        }
        progressView.progressTintColor = QDXColor.primary
        progressView.trackTintColor = QDXColor.lineColor
        progressContainer.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(16)
            make.height.equalTo(4)
        }
    }

    // MARK: - 点标列表
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PointCell.self, forCellReuseIdentifier: PointCell.reuseID)
        tableView.backgroundColor = .clear
        tableView.rowHeight = 64
        tableView.sectionHeaderHeight = 0
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(progressContainer.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }
    }

    // MARK: - 蓝牙
    private func setupBluetooth() {
        central = CBCentralManager(delegate: self, queue: .main)
    }

    private func updateProgress() {
        let total = points.count
        let done = points.filter { $0.finished }.count
        progressLabel.text = "已完成 \(done) / \(total)"
        UIView.animate(withDuration: 0.25) {
            self.progressView.setProgress(total == 0 ? 0 : Float(done) / Float(total), animated: true)
        }
    }
}

extension GameViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { points.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PointCell.reuseID, for: indexPath) as! PointCell
        cell.configure(with: points[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 打开任务书（待接入 WebView）
        showToast("打开点标任务")
    }
}

extension GameViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard !discoveredPeripherals.keys.contains(peripheral.identifier) else { return }
        discoveredPeripherals[peripheral.identifier] = peripheral
        // 通过 mac / name 匹配点标，触发震动 + 推进进度
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        // TODO: 匹配 points 中 mac 后标记 finished
    }
}

// MARK: - 点标 Cell
final class PointCell: UITableViewCell {
    static let reuseID = "PointCell"
    private let indexLabel = UILabel()
    private let titleLabel = UILabel()
    private let statusImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        indexLabel.font = QDXFont.bold(32)
        indexLabel.textColor = QDXColor.primary
        indexLabel.textAlignment = .center
        contentView.addSubview(indexLabel)
        indexLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(32)
        }
        titleLabel.font = QDXFont.medium(30)
        titleLabel.textColor = QDXColor.black
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(indexLabel.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
        statusImageView.tintColor = QDXColor.green
        statusImageView.contentMode = .scaleAspectFit
        contentView.addSubview(statusImageView)
        statusImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with p: GameViewController.PointModel) {
        indexLabel.text = p.cn
        titleLabel.text = p.cn
        statusImageView.image = UIImage(systemName: p.finished ? "checkmark.circle.fill" : "circle")
        statusImageView.tintColor = p.finished ? QDXColor.green : QDXColor.lightGray
    }
}
