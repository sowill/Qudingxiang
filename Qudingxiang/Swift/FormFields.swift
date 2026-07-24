//
//  FormFields.swift
//  趣定向 (Swift 迁移版)
//
//  可复用的表单输入组件，替代原 OC 中大量重复的 UITextField + 分隔线 + 显示密码按钮
//

import UIKit
import SnapKit

/// 单行输入框：左侧图标(可选) + 输入框 + 右侧操作按钮(可选：清除 / 显隐密码)
final class FormField: UIView, UITextFieldDelegate {

    enum RightAction {
        case none
        case clear                  // 清除按钮
        case passwordToggle         // 密码显隐
        case custom(UIImage?)       // 自定义图标
    }

    private let textField = UITextField()
    private let lineView  = UIView()
    private let rightButton = UIButton(type: .system)
    private var action: RightAction = .none

    var text: String? { textField.text }
    var valueChanged: ((String?) -> Void)?

    init(placeholder: String,
         keyboardType: UIKeyboardType = .default,
         isSecure: Bool = false,
         leftIcon: UIImage? = nil,
         rightAction: RightAction = .none) {
        super.init(frame: .zero)
        backgroundColor = .white
        self.action = rightAction

        textField.placeholder = placeholder
        textField.font = QDXFont.regular(28)
        textField.textColor = QDXColor.black
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecure
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        if let icon = leftIcon {
            textField.leftView = makeLeftView(icon)
            textField.leftViewMode = .always
        }
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
            make.height.equalTo(56)
        }

        lineView.backgroundColor = QDXColor.lineColor
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        // 右侧操作
        rightButton.tintColor = QDXColor.gray
        rightButton.addTarget(self, action: #selector(rightTapped), for: .touchUpInside)
        rightButton.isHidden = true
        addSubview(rightButton)
        rightButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        configureRightAction(rightAction, isSecure: isSecure)
    }
    required init?(coder: NSCoder) { fatalError() }

    private func makeLeftView(_ icon: UIImage) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 24))
        let iv = UIImageView(image: icon.withRenderingMode(.alwaysTemplate))
        iv.tintColor = QDXColor.gray
        iv.contentMode = .scaleAspectFit
        container.addSubview(iv)
        iv.frame = container.bounds
        return container
    }

    private func configureRightAction(_ action: RightAction, isSecure: Bool) {
        switch action {
        case .none:
            rightButton.isHidden = true
        case .clear:
            rightButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            rightButton.isHidden = false
        case .passwordToggle:
            let img = UIImage(systemName: isSecure ? "eye.slash" : "eye")
            rightButton.setImage(img, for: .normal)
            rightButton.isHidden = false
        case .custom(let img):
            rightButton.setImage(img, for: .normal)
            rightButton.isHidden = false
        }
    }

    @objc private func rightTapped() {
        switch action {
        case .clear:
            textField.text = nil
            textChanged()
        case .passwordToggle:
            textField.isSecureTextEntry.toggle()
            let img = UIImage(systemName: textField.isSecureTextEntry ? "eye.slash" : "eye")
            rightButton.setImage(img, for: .normal)
        default:
            break
        }
    }

    @objc private func textChanged() {
        valueChanged?(textField.text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

/// 主按钮（圆角 + 阴影）
final class PrimaryButton: UIButton {
    init(title: String, enabled: Bool = true) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = QDXFont.semibold(32)
        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .disabled)
        layer.cornerRadius = 24
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        isEnabled = enabled
        updateAppearance()
        addTarget(self, action: #selector(updateAppearance), for: .allTouchEvents)
    }
    required init?(coder: NSCoder) { fatalError() }

    @objc private func updateAppearance() {
        backgroundColor = isEnabled ? QDXColor.primary : QDXColor.lightGray
    }
}
