//
//  OfflineGameViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 QDXOffLineController.m：离线下载型游戏控制器
//  - 启动后先「下载」（拉取 myline/point/question/地图图片落地 SQLite）
//  - 「开始」进入游戏：地图图、计时、目标点标、CoreBluetooth 扫描
//  - 命中点标后无题直接通过 / 有题弹出 UIAlertController 四选一
//  - 历史 / 详情 / 扫码 / 退赛 更多菜单
//  - 状态：0准备 / 1待开始 / 2进行中 / 3完成 / 4强制结束
//
//  与 BaseGameViewController 区别：
//  - 后者是在线模式，taskRefresh 接口返回当前状态
//  - 本控制器是离线下载模式，全部数据来自 OfflineDownloadStore
//

import UIKit
import SnapKit
import CoreBluetooth
import AudioToolbox
import MBProgressHUD
import Alamofire

final class OfflineGameViewController: BaseViewController {

    /// 当前线路 ID（外部注入）
    var mylineID: String = ""

    // MARK: - 状态

    private enum GameState: Int {
        case pending   = 0   // 准备
        case standby   = 1   // 待开始（已扫描到起点）
        case playing   = 2   // 进行中
        case finished  = 3   // 完成
        case failed    = 4   // 强制结束
    }

    private var state: GameState = .pending {
        didSet { applyStateTitle() }
    }

    // MARK: - 数据

    private let store = OfflineDownloadStore.shared
    private var myline: OfflineMyline?
    private var macLabels: [String] = []      // 当前目标点标 MAC（无冒号）
    private var rssiThreshold: String = ""
    private var pointmapID: String = ""
    private var isFinishPoint: String = ""
    private var tempPointNames: [String] = [] // 自由模式的剩余点标名

    // 当前题目
    private var currentQuestion: OfflineQuestion?

    // 蓝牙
    private var central: CBCentralManager?
    private var lock = false
    private var matchedMac = "0"

    // 计时
    private var countDownTimer: Timer?
    private var secondsCountDown = 0
    private var sdateStr = ""

    // MARK: - UI

    private let downloadButton = UIButton(type: .system)
    private let startButton    = UIButton(type: .system)
    private let mapImageView   = UIImageView()
    private let timeLabel      = UILabel()
    private let timeCaption    = UILabel()
    private let pointNameLabel = UILabel()
    private let pointCaption   = UILabel()
    private let historyButton  = UIButton(type: .system)
    private let detailsButton  = UIButton(type: .system)

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "离线下载"
        view.backgroundColor = QDXColor.white
        setupDownloadUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countDownTimer?.fireDate = .distantFuture
    }

    // MARK: - 初始下载界面

    private func setupDownloadUI() {
        downloadButton.setTitle("下载线路数据", for: .normal)
        downloadButton.titleLabel?.font = QDXFont.medium(32)
        downloadButton.setTitleColor(.white, for: .normal)
        downloadButton.backgroundColor = QDXColor.primary
        downloadButton.layer.cornerRadius = 12
        downloadButton.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
        view.addSubview(downloadButton)
        downloadButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(Screen.fit(440))
            make.height.equalTo(Screen.fit(120))
        }

        startButton.setTitle("开始活动", for: .normal)
        startButton.titleLabel?.font = QDXFont.medium(32)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = QDXColor.accent
        startButton.layer.cornerRadius = 12
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        view.addSubview(startButton)
        startButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(downloadButton.snp.bottom).offset(24)
            make.width.height.equalTo(downloadButton)
        }
    }

    @objc private func downloadTapped() {
        guard let token = AccountManager.shared.token else { return }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = "下载中..."
        hud.mode = .indeterminate

        let group = DispatchGroup()

        group.enter()
        OfflineDownloadAPI.setupMylineInfo(mylineID: mylineID, token: token) { _ in group.leave() }

        group.enter()
        OfflineDownloadAPI.loadPoints(mylineID: mylineID) { _ in group.leave() }

        group.enter()
        OfflineDownloadAPI.loadQuestions(mylineID: mylineID) { _ in group.leave() }

        group.notify(queue: .main) { [weak self] in
            self?.store.deleteDuplicates()
            hud.hide(animated: true)
            self?.showToast("下载完成")
        }
    }

    @objc private func startTapped() {
        // 校验是否已下载
        guard store.selectMyline(mylineID: mylineID) != nil else {
            showToast("请先下载线路数据")
            return
        }
        downloadButton.removeFromSuperview()
        startButton.removeFromSuperview()
        setupGameUI()
        selectMethod()
    }

    /// 简易 Toast（基于 MBProgressHUD）
    private func showToast(_ text: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = text
        hud.mode = .text
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1.5)
    }

    // MARK: - 游戏界面

    private func setupGameUI() {
        // 1. 地图图片
        mapImageView.contentMode = .scaleAspectFill
        mapImageView.clipsToBounds = true
        mapImageView.isUserInteractionEnabled = true
        let mapPath = "\(QDXPath.documents)/image/map_\(mylineID).png"
        mapImageView.image = UIImage(contentsOfFile: mapPath)
        let tap = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        mapImageView.addGestureRecognizer(tap)
        view.addSubview(mapImageView)
        mapImageView.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview(); $0.height.equalTo(Screen.height / 3) }

        // 2. 计时
        timeLabel.font = .systemFont(ofSize: 30, weight: .bold)
        timeLabel.textColor = QDXColor.black
        timeLabel.textAlignment = .center
        timeLabel.text = "00:00:00"
        view.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(mapImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(36)
        }

        timeCaption.text = "当前成绩"
        timeCaption.font = QDXFont.regular(24)
        timeCaption.textColor = QDXColor.gray
        timeCaption.textAlignment = .center
        view.addSubview(timeCaption)
        timeCaption.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        // 3. 目标点标
        pointNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        pointNameLabel.textColor = QDXColor.black
        pointNameLabel.textAlignment = .center
        view.addSubview(pointNameLabel)
        pointNameLabel.snp.makeConstraints { make in
            make.top.equalTo(timeCaption.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }

        pointCaption.text = "目标点标"
        pointCaption.font = QDXFont.regular(24)
        pointCaption.textColor = QDXColor.gray
        pointCaption.textAlignment = .center
        view.addSubview(pointCaption)
        pointCaption.snp.makeConstraints { make in
            make.top.equalTo(pointNameLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        // 4. 底部按钮
        historyButton.setTitle("历史足迹", for: .normal)
        historyButton.titleLabel?.font = QDXFont.medium(28)
        historyButton.setTitleColor(.white, for: .normal)
        historyButton.backgroundColor = QDXColor.primary
        historyButton.layer.cornerRadius = 8
        historyButton.addTarget(self, action: #selector(historyTapped), for: .touchUpInside)
        view.addSubview(historyButton)
        historyButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-Screen.safeAreaBottom - 24)
            make.width.equalTo(Screen.fit(280))
            make.height.equalTo(Screen.fit(100))
        }

        detailsButton.setTitle("活动详情", for: .normal)
        detailsButton.titleLabel?.font = QDXFont.medium(28)
        detailsButton.setTitleColor(.white, for: .normal)
        detailsButton.backgroundColor = QDXColor.darkBlue
        detailsButton.layer.cornerRadius = 8
        detailsButton.addTarget(self, action: #selector(detailsTapped), for: .touchUpInside)
        view.addSubview(detailsButton)
        detailsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.height.width.equalTo(historyButton)
        }

        // 5. 右上角更多
        let moreBtn = UIButton(type: .system)
        moreBtn.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreBtn.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreBtn)
    }

    // MARK: - 进入下一关 / 状态推进

    private func selectMethod() {
        store.deleteDuplicates()

        guard let m = store.selectMyline(mylineID: mylineID) else { return }
        let historyArr = store.selectHistory(mylineID: mylineID)
        let linePoints = store.selectLinePoints(lineID: m.lineID)

        let linetypeID = Int(linePoints.first?.linetypeID ?? "0") ?? 0

        if linetypeID == 2 {
            // 自由模式：从所有点标中扣除已访问的，剩余点标的 MAC 全部作为目标
            var remainIDs = linePoints.map { $0.pointID }
            for h in historyArr {
                remainIDs.removeAll { $0 == h.pointID }
            }
            let points = store.selectAllPoints(pointIDs: remainIDs)
            tempPointNames = points.map { $0.pointName }
            macLabels = points.compactMap { macNoColon(from: $0.label) }
            if let r = points.first?.rssi { rssiThreshold = r }
            pointNameLabel.text = "神秘点标"
        } else {
            // 依次模式：取 historyArr.count 索引的点标
            let idx = min(historyArr.count, linePoints.count - 1)
            let lp = linePoints[idx]
            if let p = store.selectPoint(pointID: lp.pointID) {
                rssiThreshold = p.rssi
                isFinishPoint = lp.pindex
                pointNameLabel.text = p.pointName
                pointmapID = lp.pointmapID
                // label 可能是 "MAC1,MAC2" 多 mac 串
                macLabels = p.label
                    .components(separatedBy: ",")
                    .compactMap { macNoColon(from: $0) }
            }
        }

        // 更新 myline 当前点标
        var updated = m
        if let lp = linePoints.first(where: { $0.pointmapID == pointmapID }) {
            updated.pointmapID = lp.pointmapID
        }
        updated.mstatusID = "\(state.rawValue)"
        store.modifyMyline(updated)
        myline = updated
        sdateStr = m.sdate

        // 计时器
        computeSecondsSinceStart()
        countDownTimer = Timer.scheduledTimer(
            timeInterval: 1, target: self, selector: #selector(timerFire), userInfo: nil, repeats: true
        )
        state = GameState(rawValue: Int(m.mstatusID) ?? 0) ?? .pending

        // 加载当前题目
        loadCurrentQuestion()

        if state == .pending {
            navigationItem.title = "准备活动"
        } else if state == .finished {
            lock = true
            clearCurrentMyLine()
            navigationItem.title = "活动结束"
        } else if state == .failed {
            lock = true
            clearCurrentMyLine()
            navigationItem.title = "强制结束"
        }

        // 启动蓝牙
        central = CBCentralManager(delegate: self, queue: nil)
    }

    private func applyStateTitle() {
        switch state {
        case .pending:  navigationItem.title = "准备活动"
        case .standby:  navigationItem.title = "待开始"
        case .playing:  navigationItem.title = "进行中"
        case .finished: navigationItem.title = "活动结束"
        case .failed:   navigationItem.title = "强制结束"
        }
    }

    private func clearCurrentMyLine() {
        let path = (QDXPath.documents as NSString).appendingPathComponent("QDXMyLine.data")
        try? FileManager.default.removeItem(atPath: path)
    }

    // MARK: - 题目

    private func loadCurrentQuestion() {
        let qs = store.selectQuestions(pointmapID: pointmapID)
        currentQuestion = qs.first
    }

    private func compareQuestion(answer: String?) {
        lock = false
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let now = formatter.string(from: Date())

        guard let q = currentQuestion else {
            // 无题：直接写历史并推进
            store.insertHistory(OfflineHistory(
                edate: "1", mylineID: mylineID, pointID: pointmapID, score: now
            ))
            selectMethod()
            return
        }

        // 有题
        if let ans = answer, !ans.isEmpty {
            if ans == q.qkey {
                store.insertHistory(OfflineHistory(
                    edate: "1", mylineID: mylineID, pointID: pointmapID, score: now
                ))
                selectMethod()
            } else {
                // 答错：再次出题
                presentQuestionAlert()
            }
        } else {
            // 首次进入：弹题
            presentQuestionAlert()
        }
    }

    private func presentQuestionAlert() {
        guard let q = currentQuestion else { return }
        let alert = UIAlertController(
            title: "问题",
            message: q.questionName,
            preferredStyle: .alert
        )
        let options = [("A", q.qa), ("B", q.qb), ("C", q.qc), ("D", q.qd)]
        for (key, text) in options {
            alert.addAction(UIAlertAction(
                title: "\(key). \(text)", style: .default
            ) { [weak self] _ in
                self?.compareQuestion(answer: key)
            })
        }
        present(alert, animated: true)
    }

    // MARK: - 计时

    private func computeSecondsSinceStart() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let now = formatter.date(from: formatter.string(from: Date())),
              let start = formatter.date(from: sdateStr) else { return }
        secondsCountDown = Int(now.timeIntervalSince(start))
    }

    @objc private func timerFire() {
        secondsCountDown += 1
        timeLabel.text = scoreTransfer(secondsCountDown)
    }

    /// 秒数 -> "HH:MM:SS"
    private func scoreTransfer(_ sec: Int) -> String {
        let h = sec / 3600
        let m = (sec % 3600) / 60
        let s = sec % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    // MARK: - 工具：MAC 转换

    /// "AA:BB:CC:DD:EE:FF" -> "AABBCCDDEEFF"
    private func macNoColon(from label: String) -> String {
        label.replacingOccurrences(of: ":", with: "")
    }

    // MARK: - 按钮事件

    @objc private func historyTapped() {
        let vc = HistoryViewController()
        vc.mylineID = mylineID
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func detailsTapped() {
        let names = tempPointNames.isEmpty ? [pointNameLabel.text ?? ""] : tempPointNames
        let alert = UIAlertController(
            title: "活动详情",
            message: names.joined(separator: "\n"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }

    @objc private func mapTapped() {
        // 简化版：点击放大查看
        let vc = UIViewController()
        vc.view.backgroundColor = .black
        let imgView = UIImageView(image: mapImageView.image)
        imgView.contentMode = .scaleAspectFit
        vc.view.addSubview(imgView)
        imgView.snp.makeConstraints { $0.edges.equalToSuperview() }
        let close = UITapGestureRecognizer(target: self) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        vc.view.addGestureRecognizer(close)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @objc private func moreTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "扫一扫", style: .default) { [weak self] _ in
            self?.scanCode()
        })
        alert.addAction(UIAlertAction(title: "退赛", style: .destructive) { [weak self] _ in
            self?.confirmQuit()
        })
        alert.addAction(UIAlertAction(title: "帮助", style: .default) { [weak self] _ in
            self?.showHelp()
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    private func scanCode() {
        // 简化：扫码后假定匹配，触发流程
        // 完整实现可基于 Vision 框架，此处与 BaseGameViewController 复用
        let alert = UIAlertController(
            title: "扫码",
            message: "请使用扫码页扫描点标",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }

    private func confirmQuit() {
        let alert = UIAlertController(
            title: "提示",
            message: "确定要退赛吗？",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "退赛", style: .destructive) { [weak self] _ in
            self?.state = .failed
            self?.clearCurrentMyLine()
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    private func showHelp() {
        let vc = WebViewController()
        vc.url = APIHost.base + APIPath.help
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - CBCentralManagerDelegate

extension OfflineGameViewController: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {

        let b = abs(RSSI.intValue)
        let rssiAbs = abs(Int(rssiThreshold) ?? 0)
        let ci = Double(b - rssiAbs) / (10.0 * 4.0)
        guard pow(10.0, ci) < 1 else {
            central.scanForPeripherals(withServices: nil, options: nil)
            return
        }

        // 从 advertisementData 中提取 MAC（与 OC 解析逻辑保持一致）
        guard let uuids = advertisementData["kCBAdvDataServiceUUIDs"] as? [Any] else {
            central.scanForPeripherals(withServices: nil, options: nil)
            return
        }
        let raw = uuids.map { String(describing: $0) }.joined()
            .replacingOccurrences(of: "Unknown (<", with: "")
            .replacingOccurrences(of: ">)", with: "")
        guard raw.count > 20 else { return }

        let macStr = String(raw.dropFirst(8).prefix(12))

        if lock { return }
        for label in macLabels where macStr == label && macStr != matchedMac {
            lock = true
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

            if state == .standby || state == .pending {
                // 起点确认
                let alert = UIAlertController(
                    title: "提示",
                    message: "是否确定开始本次活动？",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "确定", style: .default) { [weak self] _ in
                    self?.matchedMac = macStr
                    self?.state = .playing
                    self?.compareQuestion(answer: nil)
                })
                alert.addAction(UIAlertAction(title: "取消", style: .cancel) { [weak self] _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self?.lock = false
                    }
                })
                present(alert, animated: true)
            } else {
                matchedMac = macStr
                compareQuestion(answer: nil)
            }
            break
        }

        central.scanForPeripherals(withServices: nil, options: nil)
    }
}
