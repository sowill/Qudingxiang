//
//  QRCodeGenerator.swift
//  趣定向 (Swift 迁移版)
//
//  使用 CoreImage 生成二维码，替代 libqrencode
//  使用 Vision + AVFoundation 进行二维码扫描，替代 ZBar
//

import UIKit
import CoreImage

enum QRCodeGenerator {
    /// 生成二维码图片
    static func image(from string: String, size: Int) -> UIImage? {
        let data = string.data(using: .utf8)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        guard let ciImage = filter.outputImage else { return nil }
        let scale = CGFloat(size) / ciImage.extent.width
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
