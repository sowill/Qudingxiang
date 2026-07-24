//
//  BaseGameViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 BaseGameViewController.m：定向游戏核心
//  - 4 状态机：1待开始 / 2进行中 / 3已完成 / 4已失败
//  - CoreBluetooth 感应 Beacon，匹配 MAC 触发任务
//  - 倒计时（限时模式 linetype_id=3）
//  - WKWebView 加载任务书 + JS 回调 Success
//  - 完成弹层动画 + 证书图
//  - 历史足迹 / 地图 / 任务 / 扫码 / 退赛 更多菜单
//

import UIKit
import SnapKit
import WebKit
import CoreBluetooth
import AudioToolbox
import SDWebImage
import MBProgressHUD

final class BaseGameViewController: BaseViewController {

    /// 当前线路 ID
    var mylineID: String = ""

    // MARK: - 状态
    private enum GameState: Int { case pending = 1, playing = 2, finished = 3, failed = 4 }

    // MARK: - 数据
    private var task: TaskRefresh?
    private var history: [History] = []

    // MARK: - 蓝牙
    private var central: CBCentralManager?
    private var rmoveMac = "0"

    // MARK: - UI（不同状态共用容器）
    private let scrollView = UIScrollView()
    private var webView: WKWebView?
    private var popView: PopContainerView?
    private var countDownTimer: Timer?
    private var secondsCountDown: Int = 0

    // playing 状态视图
    private var topView: UIView?
    private var bottomView: UIView?
    private var timeScoreLabel: UILabel!
    private var pointLabel: UILabel!

    // finished 状态视图
    private var certificateView: UIImageView?
    private var historyTableView: UITableView?

    // 完成弹层
    private var bgView: UIView?
    private var deliverView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "定向游戏"
        view.backgroundColor = QDXColor.background

        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 更多菜单按钮
        let moreBtn = UIButton(type: .system)
        moreBtn.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreBtn.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreBtn)

        countDownTimer = Timer.scheduledTimer(
            timeInterval: 1, target: self, selector: #selector(timerFire), userInfo: nil, repeats: true
        )
        loadTaskRefresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        countDownTimer?.fireDate = .distantPast
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countDownTimer?.fireDate = .distantFuture
        central?.stopScan()
    }

    // MARK: - 拉取任务状态
    private func loadTaskRefresh() {
        GameAPI.taskRefresh(mylineID: mylineID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self, case .success(let task) = result else { return }
                self.task = task
                guard let state = GameState(rawValue: Int(task.mylinestID ?? "0") ?? 0) else { return }
                switch state {
                case .pending:  self.setupPendingUI()
                case .playing:  self.setupPlayingUI()
                case .finished: self.setupFinishedUI()
                case .failed:   self.setupFailedUI()
                }
            }
        }
    }

    // MARK: - 状态 1：待开始（WKWebView 任务书）
    private func setupPendingUI() {
        clearStateViews()
        central = CBCentralManager(delegate: self, queue: nil)
        let wk = WKWebView(frame: .zero)
        scrollView.addSubview(wk)
        wk.snp.makeConstraints { $0.edges.equalToSuperview() }
        if let id = task?.mylineID,
           let url = URL(string: APIHost.base + APIPath.taskIndex + "/myline_id/\(id)") {
            wk.load(URLRequest(url: url))
        }
        webView = wk
    }

    // MARK: - 状态 2：进行中（成绩 + 点标 + 操作按钮）
    private func setupPlayingUI() {
        clearStateViews()
        dismissPopView()
        central = CBCentralManager(delegate: self, queue: nil)

        let top = UIView()
        top.backgroundColor = QDXColor.blue
        scrollView.addSubview(top)
        top.snp.makeConstraints { make in
            make.top.left.right.width.equalToSuperview()
            make.height.equalTo(Screen.height)
        }
        topView = top

        // logo
        let logo = UIImageView(image: UIImage(named: "趣定向logo副本"))
        logo.contentMode = .scaleAspectFit
        top.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Screen.fit(160))
            make.width.equalTo(Screen.fit(138)); make.height.equalTo(Screen.fit(85))
        }
        // 当前成绩
        let scoreTitle = UILabel()
        scoreTitle.text = "当前成绩"
        scoreTitle.textColor = .white
        scoreTitle.font = QDXFont.medium(28)
        scoreTitle.textAlignment = .center
        top.addSubview(scoreTitle)
        scoreTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logo.snp.bottom).offset(Screen.fit(60))
            make.width.equalTo(Screen.width)
        }
        // 成绩数值
        timeScoreLabel = UILabel()
        timeScoreLabel.textColor = .white
        timeScoreLabel.font = .systemFont(ofSize: 60, weight: .bold)
        timeScoreLabel.textAlignment = .center
        top.addSubview(timeScoreLabel)
        timeScoreLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(scoreTitle.snp.bottom).offset(Screen.fit(40))
            make.width.equalTo(Screen.width)
        }
        computeInitialSeconds()
        // 目标点标
        let pointTitle = UILabel()
        pointTitle.text = "目标点标"
        pointTitle.textColor = .white
        pointTitle.font = QDXFont.medium(28)
        pointTitle.textAlignment = .center
        top.addSubview(pointTitle)
        pointTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(timeScoreLabel.snp.bottom).offset(Screen.fit(60))
            make.width.equalTo(Screen.width)
        }
        pointLabel = UILabel()
        pointLabel.text = task?.pointmapCn
        pointLabel.textColor = .white
        pointLabel.font = .systemFont(ofSize: 44, weight: .bold)
        pointLabel.textAlignment = .center
        top.addSubview(pointLabel)
        pointLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(pointTitle.snp.bottom).offset(Screen.fit(20))
            make.width.equalTo(Screen.width)
        }

        // 底部贝塞尔曲线遮罩
        let bottom = UIView()
        scrollView.addSubview(bottom)
        bottom.snp.makeConstraints { make in
            make.left.right.width.equalToSuperview()
            make.top.equalTo(top.snp.bottom).offset(-100)
            make.height.equalTo(200)
        }
        let shape = CAShapeLayer()
        shape.fillColor = QDXColor.lightBlue.cgColor
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addQuadCurve(to: CGPoint(x: Screen.width, y: 0),
                          controlPoint: CGPoint(x: Screen.width/2, y: 130))
        path.addLine(to: CGPoint(x: Screen.width, y: 200))
        path.addLine(to: CGPoint(x: 0, y: 200))
        path.close()
        shape.path = path.cgPath
        bottom.layer.addSublayer(shape)

        let mapTip = UILabel()
        mapTip.text = "点击地图放大"
        mapTip.textColor = .white
        mapTip.font = QDXFont.regular(24)
        mapTip.textAlignment = .center
        bottom.addSubview(mapTip)
        mapTip.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        bottomView = bottom

        // 地图圆形大按钮
        let mapBtn = UIButton(type: .system)
        mapBtn.setImage(UIImage(named: "地图"), for: .normal)
        mapBtn.layer.cornerRadius = 25
        mapBtn.clipsToBounds = true
        mapBtn.addTarget(self, action: #selector(openMap), for: .touchUpInside)
        scrollView.addSubview(mapBtn)
        mapBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Screen.height - Screen.fit(420))
            make.width.height.equalTo(Screen.fit(214))
        }

        // 任务 / 足迹 按钮组
        addFloatingButton(icon: "任务", action: #selector(openTask), side: .right, offset: 234)
        addFloatingButton(icon: "足迹", action: #selector(openHistory), side: .left, offset: 234)

        scrollView.contentSize = CGSize(width: Screen.width, height: Screen.height)
    }

    private enum FloatSide { case left, right }
    private func addFloatingButton(icon: String, action: Selector, side: FloatSide, offset: CGFloat) {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: icon), for: .normal)
        btn.addTarget(self, action: action, for: .touchUpInside)
        scrollView.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.width.height.equalTo(Screen.fit(120))
            make.top.equalToSuperview().offset(Screen.height - Screen.fit(offset + 120) - 64)
            if side == .left {
                make.left.equalToSuperview().offset(Screen.fit(70))
            } else {
                make.right.equalToSuperview().offset(-Screen.fit(70))
            }
        }
    }

    // MARK: - 状态 3：已完成（证书 + 足迹列表）
    private func setupFinishedUI() {
        clearStateViews()
        // 清除当前线路缓存
        try? FileManager.default.removeItem(atPath: QDXPath.currentMyLine)

        GameAPI.history(mylineID: mylineID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if case .success(let list) = result { self.history = list }
                self.renderFinished()
            }
        }
    }

    private func renderFinished() {
        // 证书图
        let cert = UIImageView()
        cert.contentMode = .scaleAspectFit
        if let id = task?.mylineID,
           let url = URL(string: APIHost.base + APIPath.toimg + "/myline_id/\(id)") {
            cert.sd_setImage(with: url, placeholderImage: UIImage(named: "加载中"))
        }
        scrollView.addSubview(cert)
        cert.snp.makeConstraints { make in
            make.top.left.right.width.equalToSuperview()
            make.height.equalTo(Screen.width * 1.425)
        }
        certificateView = cert

        // 足迹列表
        let table = UITableView(frame: .zero, style: .plain)
        table.dataSource = self
        table.delegate = self
        table.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.reuseID)
        table.rowHeight = 73
        table.backgroundColor = QDXColor.background
        table.tableFooterView = UIView()
        table.isScrollEnabled = false
        scrollView.addSubview(table)
        historyTableView = table
        table.snp.makeConstraints { make in
            make.top.equalTo(cert.snp.bottom).offset(10)
            make.left.right.width.equalToSuperview()
            make.height.equalTo(73 * CGFloat(history.count) + 40)
        }
        scrollView.contentSize = CGSize(width: Screen.width,
                                        height: Screen.width * 1.425 + 73 * CGFloat(history.count) + 40 + 114)
    }

    // MARK: - 状态 4：已失败
    private func setupFailedUI() {
        clearStateViews()
        try? FileManager.default.removeItem(atPath: QDXPath.currentMyLine)

        let sad = UIImageView(image: UIImage(named: "哭脸－遗憾"))
        sad.contentMode = .scaleAspectFit
        scrollView.addSubview(sad)
        sad.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Screen.height * 0.22)
            make.width.height.equalTo(40)
        }
        let label = UILabel()
        label.text = (task?.mylinestID == "4") ? "您已经强制结束比赛" : "您已经超时结束比赛"
        label.font = QDXFont.regular(24)
        label.textColor = QDXColor.gray
        label.textAlignment = .center
        scrollView.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(sad.snp.bottom).offset(15)
        }
        scrollView.contentSize = CGSize(width: Screen.width, height: Screen.height)
    }

    private func clearStateViews() {
        webView?.removeFromSuperview(); webView = nil
        topView?.removeFromSuperview(); topView = nil
        bottomView?.removeFromSuperview(); bottomView = nil
        certificateView?.removeFromSuperview(); certificateView = nil
        historyTableView?.removeFromSuperview(); historyTableView = nil
        scrollView.subviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - 计时
    @objc private func timerFire() {
        secondsCountDown += 1
        guard let task = task else { return }
        if task.linetypeID == "3" {
            // 限时模式：倒计时
            let total = Int(task.lineTime ?? "0") ?? 0
            let remaining = total - secondsCountDown
            timeScoreLabel?.text = formatScore(remaining)
            if remaining <= 900 { timeScoreLabel?.textColor = .red }
            if remaining <= 0 {
                countDownTimer?.fireDate = .distantFuture
                loadTaskRefresh()
            }
        } else {
            timeScoreLabel?.text = formatScore(secondsCountDown)
        }
    }

    private func computeInitialSeconds() {
        guard let adate = task?.mylineAdate else { return }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let start = fmt.date(from: adate) else { return }
        secondsCountDown = Int(Date().timeIntervalSince(start))
    }

    private func formatScore(_ seconds: Int) -> String {
        let h = max(0, seconds) / 3600
        let m = (max(0, seconds) % 3600) / 60
        let s = max(0, seconds) % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    // MARK: - 更多菜单
    @objc private func moreTapped() {
        let state = Int(task?.mylinestID ?? "0") ?? 0
        var actions: [(String, () -> Void)] = []
        if state == 1 {
            actions.append(("扫一扫", { [weak self] in self?.openScan() }))
            actions.append(("帮助",    { [weak self] in self?.openHelp() }))
            actions.append(("组队",    { [weak self] in self?.openTeams() }))
            actions.append(("退赛",    { [weak self] in self?.confirmGameover() }))
        } else if state == 2 {
            actions.append(("扫一扫", { [weak self] in self?.openScan() }))
            actions.append(("帮助",   { [weak self] in self?.openHelp() }))
            actions.append(("退赛",   { [weak self] in self?.confirmGameover() }))
        } else if state == 3 {
            actions.append(("分享",     { [weak self] in self?.self.shareTapped() }))
            actions.append(("帮助",     { [weak self] in self?.openHelp() }))
            actions.append(("打印成绩", { [weak self] in self?.showPrintQR() }))
        } else {
            actions.append(("帮助", { [weak self] in self?.openHelp() }))
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for (title, handler) in actions {
            alert.addAction(UIAlertAction(title: title, style: .default) { _ in handler() })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func openMap() {
        let vc = MapViewController()
        vc.mylineID = mylineID
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func openTask() {
        guard let id = task?.mylineID else { return }
        let imei = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let url = APIHost.base + APIPath.taskTask + "/myline_id/\(id)/imei/\(imei)"
        showTaskWebView(url: url)
    }
    @objc private func openHistory() {
        let vc = HistoryViewController()
        vc.mylineID = mylineID
        navigationController?.pushViewController(vc, animated: true)
    }
    private func openScan() { showToast("扫码待接入") }
    private func openHelp() { showToast("帮助待接入") }
    private func openTeams() { showToast("组队待接入") }
    @objc private func shareTapped() { showToast("分享待接入") }

    private func showPrintQR() {
        guard let content = task?.mylinePrint else { return }
        let bg = UIView(frame: view.bounds)
        bg.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        bg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPrint)))
        view.addSubview(bg)
        bgView = bg

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        bg.addSubview(card)
        card.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(Screen.fit(560))
            make.height.equalTo(Screen.fit(480))
        }
        let title = UILabel()
        title.text = "请到自助终端打印成绩单:"
        title.textAlignment = .center
        title.font = QDXFont.medium(28)
        card.addSubview(title)
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Screen.fit(36))
            make.centerX.equalToSuperview()
        }
        let qr = QRCodeGenerator.image(from: content, size: Int(Screen.fit(340)))
        let qrIV = UIImageView(image: qr)
        card.addSubview(qrIV)
        qrIV.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(Screen.fit(36))
            make.centerX.equalToSuperview()
            make.width.height.equalTo(Screen.fit(340))
        }
        deliverView = card
    }
    @objc private func dismissPrint() {
        bgView?.removeFromSuperview(); bgView = nil
        deliverView?.removeFromSuperview(); deliverView = nil
    }

    private func confirmGameover() {
        let alert = UIAlertController(title: "提示", message: "真的要结束活动吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            GameAPI.gameover(mylineID: self?.mylineID ?? "") { result in
                DispatchQueue.main.async {
                    if case .success(let msg) = result {
                        self?.showToast(msg)
                        self?.loadTaskRefresh()
                    } else if case .failure(let err) = result {
                        self?.showToast(err.localizedDescription)
                    }
                }
            }
        })
        present(alert, animated: true)
    }

    // MARK: - 任务书 WebView（带 JS Success 回调）
    private func showTaskWebView(url: String) {
        dismissPopView()
        central?.scanForPeripherals(withServices: nil, options: nil)
        let pop = PopContainerView()
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let wk = WKWebView(frame: .zero, configuration: config)
        if let u = URL(string: url) { wk.load(URLRequest(url: u)) }
        config.userContentController.add(self, name: "Success")
        pop.setContentView(wk)
        pop.show(in: view)
        popView = pop
    }

    private func dismissPopView() {
        popView?.dismiss()
        popView = nil
        central?.scanForPeripherals(withServices: nil, options: nil)
    }

    // MARK: - 完成弹层动画
    private func showCompleteAnimation() {
        guard let popURL = task?.pointmapPop else { return }
        let bg = UIView(frame: view.bounds)
        bg.backgroundColor = .clear
        view.addSubview(bg)
        bgView = bg

        let deliver = UIView()
        deliver.backgroundColor = .clear
        deliver.layer.cornerRadius = 12
        deliver.layer.borderWidth = 1
        deliver.layer.borderColor = UIColor.clear.cgColor
        view.addSubview(deliver)
        deliverView = deliver

        let imgView = UIImageView()
        imgView.sd_setImage(with: URL(string: APIHost.oldBase + popURL),
                            placeholderImage: UIImage(named: "加载中"))
        imgView.contentMode = .scaleAspectFit
        deliver.addSubview(imgView)
        imgView.snp.makeConstraints { $0.edges.equalToSuperview() }

        let cancelBtn = UIButton(type: .system)
        cancelBtn.backgroundColor = .clear
        cancelBtn.addTarget(self, action: #selector(dismissComplete), for: .touchUpInside)
        deliver.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 起始小尺寸
        deliver.frame = CGRect(x: Screen.width * 0.5 - Screen.fit(710)/4,
                               y: 0,
                               width: Screen.fit(710)/2,
                               height: Screen.fit(1074)/2)
        UIView.animate(withDuration: 0.5, delay: 0,
                       usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3,
                       options: .curveLinear) {
            bg.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            deliver.frame = CGRect(x: Screen.width/2 - Screen.fit(710)/2,
                                   y: (Screen.height - Screen.fit(1074))/2,
                                   width: Screen.fit(710),
                                   height: Screen.fit(1074))
        }
    }
    @objc private func dismissComplete() {
        bgView?.removeFromSuperview(); bgView = nil
        deliverView?.removeFromSuperview(); deliverView = nil
    }
}

// MARK: - WKScriptMessageHandler
extension BaseGameViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if message.name == "Success" {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            showCompleteAnimation()
            loadTaskRefresh()
            rmoveMac = "0"
            central?.scanForPeripherals(withServices: nil, options: nil)
        }
    }
}

// MARK: - CBCentralManagerDelegate（蓝牙感应点标）
extension BaseGameViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard let task = task,
              let threshold = Int(task.pointmapRssi ?? "0"),
              abs(RSI.intValue) < abs(threshold) else { return }
        // 提取 MAC
        guard let uuids = advertisementData["kCBAdvDataServiceUUIDs"] as? [Any],
              let raw = uuids.first as? CustomStringConvertible else { return }
        let s = String(describing: raw)
        guard s.count > 8 else { return }
        let start = s.index(s.startIndex, offsetBy: 8)
        let end = s.index(start, offsetBy: 12)
        let mac = String(s[start..<end])
        let target = (task.pointmapMac ?? "").replacingOccurrences(of: ":", with: "")
        guard target.contains(mac), mac != rmoveMac else { return }
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        central.stopScan()
        rmoveMac = mac

        let state = Int(task.mylinestID ?? "0") ?? 0
        if state == 1 {
            // 待开始：弹确认
            let alert = UIAlertController(title: "提示", message: "是否确定开始本次活动？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel) { [weak self] _ in
                self?.rmoveMac = "0"
                self?.central?.scanForPeripherals(withServices: nil, options: nil)
            })
            alert.addAction(UIAlertAction(title: "确定", style: .default) { [weak self] _ in
                self?.triggerTask(mac: task.pointmapMac ?? "")
            })
            present(alert, animated: true)
        } else {
            triggerTask(mac: task.pointmapMac ?? "")
        }
    }

    private func triggerTask(mac: String) {
        guard let id = task?.mylineID else { return }
        let imei = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let url = APIHost.base + APIPath.taskTask + "/myline_id/\(id)/imei/\(imei)/pointmap_mac/\(mac)"
        showTaskWebView(url: url)
    }
}

// MARK: - 足迹 Cell（状态 3 共用）
final class HistoryCell: UITableViewCell {
    static let reuseID = "HistoryCell"
    private let timeLabel = UILabel()
    private let pointLabel = UILabel()
    private let scoreLabel = UILabel()
    private let btn = UIButton(type: .system)

    var viewHistory: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        timeLabel.font = QDXFont.regular(24); timeLabel.textColor = QDXColor.gray
        pointLabel.font = QDXFont.medium(30); pointLabel.textColor = QDXColor.black
        scoreLabel.font = QDXFont.bold(28); scoreLabel.textColor = QDXColor.primary
        scoreLabel.textAlignment = .right
        btn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        btn.tintColor = QDXColor.lightGray
        btn.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
        contentView.addSubview(timeLabel)
        contentView.addSubview(pointLabel)
        contentView.addSubview(scoreLabel)
        contentView.addSubview(btn)
        timeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16); make.top.equalToSuperview().offset(12)
        }
        pointLabel.snp.makeConstraints { make in
            make.left.equalTo(timeLabel); make.top.equalTo(timeLabel.snp.bottom).offset(6)
        }
        scoreLabel.snp.makeConstraints { make in
            make.right.equalTo(btn.snp.left).offset(-8); make.centerY.equalToSuperview()
        }
        btn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12); make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with h: History) {
        timeLabel.text  = h.cdate
        pointLabel.text = h.pointmapCn
        scoreLabel.text = h.score
    }
    @objc private func btnTapped() { viewHistory?() }
}

extension BaseGameViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        history.count
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.reuseID, for: indexPath) as! HistoryCell
        let h = history[history.count - 1 - indexPath.row]
        cell.configure(with: h)
        cell.viewHistory = { [weak self] in
            guard let id = h.pointmapID else { return }
            let url = APIHost.base + APIPath.pointhistory + "/pointmap_id/\(id)"
            self?.showTaskWebView(url: url)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .white
        let label = UILabel()
        label.text = "定向足迹"
        label.font = QDXFont.medium(28)
        label.textColor = QDXColor.black
        header.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12); make.centerY.equalToSuperview()
        }
        let line = UIView(); line.backgroundColor = UIColor(white: 0.875, alpha: 1)
        header.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview(); make.height.equalTo(1)
        }
        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 40 }
}
