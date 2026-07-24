//
//  UIKitExtensions.swift
//  趣定向 (Swift 迁移版)
//
//  集中迁移 Tool/ 下零散 OC 工具类：
//  - ToolView               → ToolView（创建 ImageView/Label/Button、scoreTransfer、md5、缩放、透明度）
//  - UIImage+watermark      → UIImage.qdx_watermark(text:)
//  - UIImage+RTTint         → UIImage.qdx_tinted(_:)
//  - UIButton+ImageText     → UIButton.qdx_setImage(position:spacing:)
//  - NSMutableAttributedString+ChangeColorFont → NSMutableAttributedString.qdx_append
//  - UIControl+UIControl_buttonCon（点击防抖，已用现代 controlEvent 替代，不再单独迁移）
//
//  CheckDataTool 已在第一批迁移为 Validator；QDXOfflineDB 已在第五批迁移为 OfflineDownloadStore。
//

import UIKit
import CommonCrypto

// MARK: - ToolView（替代 OC ToolView.m）

enum ToolView {

    /// 创建圆角 UIImageView
    static func createImageView(frame: CGRect) -> UIImageView {
        let iv = UIImageView(frame: frame)
        iv.backgroundColor = .clear
        iv.layer.masksToBounds = true
        return iv
    }

    /// 创建 UILabel 并加入父视图
    @discardableResult
    static func createLabel(frame: CGRect,
                            text: String,
                            font size: CGFloat,
                            in superView: UIView) -> UILabel {
        let label = UILabel(frame: frame)
        label.text = text
        label.font = .systemFont(ofSize: size)
        label.textAlignment = .left
        superView.addSubview(label)
        return label
    }

    /// 创建带图片背景的按钮
    @discardableResult
    static func createButton(frame: CGRect,
                             title: String,
                             backgroundImage: String,
                             target: Any?,
                             action: Selector,
                             in superView: UIView) -> UIButton {
        let btn = UIButton(type: .system)
        btn.frame = frame
        btn.setTitle(title, for: .normal)
        btn.setImage(UIImage(named: backgroundImage), for: .normal)
        btn.addTarget(target, action: action, for: .touchUpInside)
        superView.addSubview(btn)
        return btn
    }

    /// 由 UIColor 生成 1x73 纯色 UIImage（OC 默认尺寸）
    static func image(from color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 20, height: 73)
        UIGraphicsBeginImageContext(rect.size)
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.setFillColor(color.cgColor)
            ctx.fill(rect)
        }
        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return img
    }

    /// 等比缩放图片
    static func scale(_ image: UIImage, to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: .zero, size: size))
        let scaled = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return scaled
    }

    /// 应用透明度
    static func apply(alpha: CGFloat, to image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return image
        }
        let area = CGRect(origin: .zero, size: image.size)
        ctx.scaleBy(x: 1, y: -1)
        ctx.translateBy(x: 0, y: -area.height)
        ctx.setBlendMode(.multiply)
        ctx.setAlpha(alpha)
        if let cg = image.cgImage {
            ctx.draw(cg, in: area)
        }
        let new = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return new
    }

    /// 秒数 → "HH:MM:SS"（超过 24 小时显示 "Nd HH:MM:SS"）
    /// 等价 OC +[ToolView scoreTransfer:]
    static func scoreTransfer(_ seconds: Int) -> String {
        var h = seconds / 3600
        let m = (seconds - h * 3600) / 60
        let s = (seconds - h * 3600) % 60

        if h > 24 {
            let d = h / 24
            h = h % 24
            return String(format: "%d天%02d:%02d:%02d", d, h, m, s)
        }
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    /// 字符串 MD5
    static func md5(_ string: String) -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        let data = string.data(using: .utf8) ?? Data()
        _ = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            CC_MD5(ptr.baseAddress, CC_LONG(data.count), &digest)
        }
        return (0..<length).reduce("") { $0 + String(format: "%02x", digest[$1]) }
    }
}

// MARK: - UIImage 扩展：水印 + 着色

extension UIImage {

    /// 在底部绘制水印文字，等价 OC -[UIImage imageFromText:]
    func qdx_watermark(text: String) -> UIImage {
        let size = self.size
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: size))

        let rect = CGRect(x: 0, y: size.height - 30, width: size.width, height: 20)
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13),
            .paragraphStyle: style,
            .foregroundColor: UIColor(white: 0.067, alpha: 1.0)
        ]
        (text as NSString).draw(in: rect, withAttributes: attrs)

        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }

    /// 重新着色（保留 alpha），等价 OC UIImage+RTTint
    func qdx_tinted(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        let rect = CGRect(origin: .zero, size: size)
        color.setFill()
        draw(in: rect)
        UIRectFillUsingBlendMode(rect, .sourceIn)
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

// MARK: - UIButton 扩展：图文位置

extension UIButton {

    /// 图文位置枚举
    enum QDXImagePosition { case left, right, top, bottom }

    /// 调整图文相对位置与间距
    /// 等价 OC -[UIButton setImagePosition:spacing:]
    func qdx_setImage(position: QDXImagePosition, spacing: CGFloat) {
        guard let imageView = imageView,
              let titleLabel = titleLabel,
              let image = imageView.image,
              let text = titleLabel.text else { return }

        let labelSize = (text as NSString).size(withAttributes: [.font: titleLabel.font ?? UIFont.systemFont(ofSize: 14)])
        let imageW = image.size.width
        let imageH = image.size.height
        let labelW = labelSize.width
        let labelH = labelSize.height

        let imageOffsetX = labelW / 2
        let imageOffsetY = labelH / 2 + spacing / 2
        let labelOffsetX = imageW / 2
        let labelOffsetY = imageH / 2 + spacing / 2

        switch position {
        case .left:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing/2)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: -spacing/2)
        case .right:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelW + spacing/2, bottom: 0, right: -(labelW + spacing/2))
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageW + spacing/2), bottom: 0, right: imageW + spacing/2)
        case .top:
            imageEdgeInsets = UIEdgeInsets(top: -imageOffsetY, left: imageOffsetX, bottom: imageOffsetY, right: -imageOffsetX)
            titleEdgeInsets = UIEdgeInsets(top: labelOffsetY, left: -labelOffsetX, bottom: -labelOffsetY, right: labelOffsetX)
        case .bottom:
            imageEdgeInsets = UIEdgeInsets(top: imageOffsetY, left: imageOffsetX, bottom: -imageOffsetY, right: -imageOffsetX)
            titleEdgeInsets = UIEdgeInsets(top: -labelOffsetY, left: -labelOffsetX, bottom: labelOffsetY, right: labelOffsetX)
        }
    }

    /// 按图文距边框距离调整
    func qdx_setImage(position: QDXImagePosition, margin: CGFloat) {
        guard let imageW = imageView?.image?.size.width,
              let text = titleLabel?.text,
              let font = titleLabel?.font else { return }
        let labelW = (text as NSString).size(withAttributes: [.font: font]).width
        let spacing = bounds.width - imageW - labelW - 2 * margin
        qdx_setImage(position: position, spacing: spacing)
    }
}

// MARK: - NSMutableAttributedString 扩展

extension NSMutableAttributedString {

    /// 追加指定颜色与字体的字符串
    /// 等价 OC -[NSMutableAttributedString appendString:withColor:font:]
    func qdx_append(_ string: String, color: UIColor, font: UIFont) {
        let attr = NSAttributedString(string: string, attributes: [
            .font: font,
            .foregroundColor: color
        ])
        append(attr)
    }
}

// MARK: - QDXStateView（替代 OC View/QDXStateView，空数据/成功/失败统一占位视图）

/// 通用状态占位视图（图标 + 描述 + 按钮）
final class QDXStateView: UIView {

    var onTapButton: (() -> Void)?

    let stateImageView = UIImageView()
    let stateDetailLabel = UILabel()
    let stateButton = UIButton(type: .system)

    init(frame: CGRect, image: UIImage? = nil, detail: String = "", buttonTitle: String = "") {
        super.init(frame: frame)
        backgroundColor = .clear

        stateImageView.image = image
        stateImageView.contentMode = .scaleAspectFit
        addSubview(stateImageView)
        stateImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.width.height.equalTo(Screen.fit(280))
        }

        stateDetailLabel.text = detail
        stateDetailLabel.textColor = QDXColor.gray
        stateDetailLabel.font = QDXFont.regular(28)
        stateDetailLabel.textAlignment = .center
        stateDetailLabel.numberOfLines = 0
        addSubview(stateDetailLabel)
        stateDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(stateImageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(24)
        }

        stateButton.setTitle(buttonTitle, for: .normal)
        stateButton.titleLabel?.font = QDXFont.medium(28)
        stateButton.setTitleColor(.white, for: .normal)
        stateButton.backgroundColor = QDXColor.primary
        stateButton.layer.cornerRadius = 8
        stateButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addSubview(stateButton)
        stateButton.snp.makeConstraints { make in
            make.top.equalTo(stateDetailLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(Screen.fit(360))
            make.height.equalTo(Screen.fit(88))
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func buttonTapped() { onTapButton?() }
}
