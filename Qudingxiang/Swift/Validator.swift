//
//  Validator.swift
//  趣定向 (Swift 迁移版)
//
//  替代 CheckDataTool.h/.m：表单输入校验
//

import Foundation

enum Validator {
    /// 网址
    static func isWebURL(_ string: String?) -> Bool {
        match(string, pattern: #"^([hH][tT]{2}[pP]://|[hH][tT]{2}[pP][sS]://)"#)
    }
    /// 邮箱
    static func isEmail(_ string: String?) -> Bool {
        match(string, pattern: #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}"#)
    }
    /// 手机号（国内 11 位）
    static func isMobilePhone(_ string: String?) -> Bool {
        match(string, pattern: #"^1[3-9]\d{9}$"#)
    }
    /// 座机
    static func isPhoneNumber(_ string: String?) -> Bool {
        match(string, pattern: #"^(\d{3,4}-)\d{7,8}$"#)
    }
    /// 身份证号（15 位或 18 位）
    static func isIDCard(_ string: String?) -> Bool {
        match(string, pattern: #"(^[0-9]{15}$)|([0-9]{17}([0-9]|X)$)"#)
    }
    /// 密码长度范围
    static func isPassword(_ string: String?, shortest: Int = 6, longest: Int = 16) -> Bool {
        guard let s = string, !s.isEmpty else { return false }
        let pattern = "^[a-zA-Z0-9]{\(shortest),\(longest)}+$"
        return match(s, pattern: pattern)
    }
    /// 数字 + 字母
    static func isNumberAndCase(_ string: String?) -> Bool {
        match(string, pattern: #"^[A-Za-z0-9]+$"#)
    }
    /// 全小写
    static func isLowerCase(_ string: String?) -> Bool {
        match(string, pattern: #"^[a-z]+$"#)
    }
    /// 全大写
    static func isUpperCase(_ string: String?) -> Bool {
        match(string, pattern: #"^[A-Z]+$"#)
    }
    /// 仅字母
    static func isLetters(_ string: String?) -> Bool {
        match(string, pattern: #"^[A-Za-z]+$"#)
    }
    /// 含特殊字符 %&',;=?$\ 等
    static func containsSpecialChar(_ string: String?) -> Bool {
        match(string, pattern: #"[^%&',;=?$\x22]+"#)
    }
    /// 仅数字
    static func isNumber(_ string: String?) -> Bool {
        match(string, pattern: #"^[0-9]*$"#)
    }
    /// 指定位数数字
    static func isNumber(_ string: String?, length: Int) -> Bool {
        guard let s = string else { return false }
        return match(s, pattern: #"^\d{\#(length)}$"#)
    }

    private static func match(_ string: String?, pattern: String) -> Bool {
        guard let s = string else { return false }
        return s.range(of: pattern, options: .regularExpression) != nil
    }
}
