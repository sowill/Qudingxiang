//
//  QRScannerViewController.swift
//  趣定向 (Swift 迁移版)
//
//  替代 ImagePickerController.m：二维码扫描
//  - AVFoundation 现代化封装（OC 原本也是 AVFoundation，此处用 Swift 重写）
//  - 保留 OC 接口语义：ScanResult 回调 (result, flag, from)
//  - 扫描框 + 扫描线动画 + 提示文案
//  - 摄像头权限：需在 Info.plist 配置 NSCameraUsageDescription（已在第一批适配）
//
//  注：原 OC 工程也使用了 ZBar（View/ 下 ImagePickerController 实为 AVFoundation 版本），
//  本迁移不引入 Vision，沿用 AVFoundation 以保持与 OC 行为一致。
//

import UIKit
import AVFoundation
import SnapKit

final class QRScannerViewController: BaseViewController {

    /// 扫描结果回调：(result, success, from)
    typealias ScanResult = (String, Bool, String) -> Void

    /// 扫描结果回调（外部注入）
    var scanResult: ScanResult?

    /// 来源标记："0" 点标感应 / "1" 其他；与 OC 字段保持一致
    var from: String = "0"

    // MARK: - AVFoundation

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let metadataOutput = AVCaptureMetadataOutput()

    // 扫描动画
    private let scanBoxView = UIView()
    private let scanLine = CALayer()
    private var scanTimer: Timer?
    private var isReading = false

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "扫一扫"
        view.backgroundColor = UIColor(red: 35/255, green: 138/255, blue: 215/255, alpha: 1)

        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showToast("设备不支持摄像头")
            return
        }
        setupScanner()
        setupScanBox()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scanTimer?.fireDate = .distantFuture
        session.stopRunning()
    }

    // MARK: - 摄像头配置

    private func setupScanner() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) { session.addInput(input) }
        } catch {
            showToast("摄像头初始化失败")
            return
        }

        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
        }
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue(label: "qdx.qrscanner"))
        metadataOutput.metadataObjectTypes = [.qr]

        // 扫描区域：与 OC 一致 CGRectMake(80, 80, 280, 310) 在 1080x1920 视频流上换算
        let cropRect = CGRect(x: 80, y: 80, width: 280, height: 310)
        let p1 = Screen.height / Screen.width
        let p2: CGFloat = 1920.0 / 1080.0
        if p1 < p2 {
            let fixHeight = Screen.width * 1920.0 / 1080.0
            let fixPadding = (fixHeight - Screen.height) / 2
            metadataOutput.rectOfInterest = CGRect(
                x: (cropRect.origin.y + fixPadding) / fixHeight,
                y: cropRect.origin.x / Screen.width,
                width: cropRect.height / fixHeight,
                height: cropRect.width / Screen.width
            )
        } else {
            let fixWidth = Screen.height * 1080.0 / 1920.0
            let fixPadding = (fixWidth - Screen.width) / 2
            metadataOutput.rectOfInterest = CGRect(
                x: cropRect.origin.y / Screen.height,
                y: (cropRect.origin.x + fixPadding) / fixWidth,
                width: cropRect.height / Screen.height,
                height: cropRect.width / fixWidth
            )
        }

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.layer.bounds
        view.layer.addSublayer(preview)
        previewLayer = preview

        session.startRunning()
        isReading = true
    }

    // MARK: - 扫描框 + 扫描线动画

    private func setupScanBox() {
        scanBoxView.frame = CGRect(x: 0, y: 0, width: Screen.width, height: Screen.height - Screen.navBarHeight)
        scanBoxView.isUserInteractionEnabled = true
        view.addSubview(scanBoxView)

        let tipLabel = UILabel()
        tipLabel.text = "将取景框对准二维码，即可自动扫描。"
        tipLabel.textColor = .white
        tipLabel.textAlignment = .center
        tipLabel.numberOfLines = 2
        tipLabel.font = .systemFont(ofSize: 12)
        tipLabel.backgroundColor = .clear
        scanBoxView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.top.equalTo(scanBoxView.snp.height).multipliedBy(0.5)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }

        scanLine.frame = CGRect(x: Screen.width * 0.13, y: Screen.height * 0.09, width: Screen.width * 0.74, height: 1)
        scanLine.backgroundColor = UIColor.green.cgColor
        scanBoxView.layer.addSublayer(scanLine)

        scanTimer = Timer.scheduledTimer(
            timeInterval: 0.2, target: self, selector: #selector(moveScanLine), userInfo: nil, repeats: true
        )
        scanTimer?.fire()
    }

    @objc private func moveScanLine() {
        var frame = scanLine.frame
        if frame.origin.y > Screen.height * 0.46 {
            frame.origin.y = Screen.height * 0.09
            scanLine.frame = frame
        } else {
            frame.origin.y += 5
            UIView.animate(withDuration: 0.08) {
                self.scanLine.frame = frame
            }
        }
    }

    /// 简易 Toast
    private func showToast(_ text: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = text
        hud.mode = .text
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1.5)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard !metadataObjects.isEmpty,
              let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let result = obj.stringValue else { return }

        session.stopRunning()
        isReading = false

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.scanResult?(result, true, self.from)
            if self.from == "0" {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
