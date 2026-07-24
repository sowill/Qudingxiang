//
//  NetworkService.swift
//  趣定向 (Swift 迁移版)
//
//  基于 Alamofire 的统一网络层，替代 PPNetworkHelper / BaseService
//  特性：自动注入 token、统一错误处理、Codable 解析、缓存策略
//

import Foundation
import Alamofire

enum APIError: Error, LocalizedError {
    case invalidResponse
    case business(code: Int, message: String)
    case decode(Error)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:                 return "服务器返回异常"
        case .business(let code, let message): return "\(message)（\(code)）"
        case .decode(let e):                   return "数据解析失败: \(e.localizedDescription)"
        case .network(let e):                  return e.localizedDescription
        }
    }
}

final class NetworkService {
    static let shared = NetworkService()
    private init() {
        let cfg = Configuration.default
        cfg.timeoutIntervalForRequest = 15
        cfg.timeoutIntervalForResource = 30
        session = Session(configuration: cfg)
    }

    private let session: Session
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    // MARK: - 通用请求
    @discardableResult
    func request<T: Decodable>(
        path: String,
        method: HTTPMethod = .post,
        parameters: [String: Any] = [:],
        encoding: ParameterEncoding = URLEncoding.default,
        needToken: Bool = true,
        completion: @escaping (Result<T, APIError>) -> Void
    ) -> DataRequest {
        let url = APIHost.base + path
        var params = parameters
        if needToken, let token = AccountManager.shared.token {
            params["customer_token"] = token
        }
        return session.request(url, method: method, parameters: params, encoding: encoding)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: APIResponse<T>.self, decoder: decoder) { resp in
                switch resp.result {
                case .success(let body):
                    if body.code == 0, let data = body.msg {
                        completion(.success(data))
                    } else if body.code == 0 {
                        completion(.failure(.invalidResponse))
                    } else {
                        // 业务码非 0，尝试取消息
                        let msg = (body.msg as? [String: Any])?["msg"] as? String ?? "请求失败"
                        completion(.failure(.business(code: body.code, message: msg)))
                    }
                case .failure(let err):
                    completion(.failure(.network(err)))
                }
            }
    }

    /// 原始 JSON 请求（用于字段不固定或需手动解析的接口）
    @discardableResult
    func requestJSON(
        path: String,
        method: HTTPMethod = .post,
        parameters: [String: Any] = [:],
        needToken: Bool = true,
        completion: @escaping (Result<[String: Any], APIError>) -> Void
    ) -> DataRequest {
        let url = APIHost.base + path
        var params = parameters
        if needToken, let token = AccountManager.shared.token {
            params["customer_token"] = token
        }
        return session.request(url, method: method, parameters: params)
            .validate()
            .responseJSON { resp in
                switch resp.result {
                case .success(let value):
                    if let dict = value as? [String: Any] {
                        completion(.success(dict))
                    } else {
                        completion(.failure(.invalidResponse))
                    }
                case .failure(let err):
                    completion(.failure(.network(err)))
                }
            }
    }

    // MARK: - 上传图片
    func uploadImage(
        _ imageData: Data,
        fileName: String = "img.jpg",
        mimeType: String = "image/jpeg",
        completion: @escaping (Result<String, APIError>) -> Void
    ) {
        let url = APIHost.base + APIPath.uploadImage
        session.upload(
            multipartFormData: { formData in
                formData.append(imageData, withName: "imgfile", fileName: fileName, mimeType: mimeType)
                if let token = AccountManager.shared.token {
                    formData.append(token.data(using: .utf8)!, withName: "customer_token")
                }
            },
            to: url
        )
        .validate()
        .responseJSON { resp in
            switch resp.result {
            case .success(let value):
                if let dict = value as? [String: Any],
                   let path = dict["Msg"] as? String {
                    completion(.success(path))
                } else {
                    completion(.failure(.invalidResponse))
                }
            case .failure(let err):
                completion(.failure(.network(err)))
            }
        }
    }
}

// MARK: - 业务 API 封装
enum AuthAPI {
    static func login(account: String, password: String,
                      completion: @escaping (Result<Customer, APIError>) -> Void) {
        NetworkService.shared.request(
            path: APIPath.login,
            parameters: ["customer_code": account, "customer_pwd": password],
            needToken: false
        ) { (result: Result<Customer, APIError>) in
            if case .success(let c) = result { AccountManager.shared.save(c) }
            completion(result)
        }
    }

    static func register(cn: String, account: String, password: String,
                         completion: @escaping (Result<Customer, APIError>) -> Void) {
        NetworkService.shared.request(
            path: APIPath.register,
            parameters: ["customer_cn": cn, "customer_code": account, "customer_pwd": password],
            needToken: false,
            completion: completion
        )
    }

    static func getVcode(account: String,
                         completion: @escaping (Result<EmptyMsg, APIError>) -> Void) {
        NetworkService.shared.request(
            path: APIPath.getVcode,
            parameters: ["customer_code": account],
            needToken: false,
            completion: completion
        )
    }
}

/// 空消息占位（部分接口 Msg 为字符串）
struct EmptyMsg: Decodable {
    let value: String?
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        value = try? c.decode(String.self)
    }
}
