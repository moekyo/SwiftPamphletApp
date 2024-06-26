//
//  File.swift
//  
//
//  Created by Ming Dai on 2024/4/27.
//

import Foundation

// github api 入口 https://api.github.com
public class GitHubReq {
    public static let shared = GitHubReq()
    public var githubat = "" // access token
    public func req<T>(_ path: String, type: T.Type) async throws -> T where T : Decodable {
        var req = URLRequest(url: URL(string: "https://api.github.com/\(path)")!)

        req.addValue("token \(githubat)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let response = response as? HTTPURLResponse else {
            throw APIError.server
        }
        switch response.statusCode {
        case 400 ..< 500: throw APIError.client
        case 500 ..< 600: throw APIError.server
        default: break
        }
        
        let de = JSONDecoder()
        de.keyDecodingStrategy = .convertFromSnakeCase
        
        return try de.decode(type.self, from: data)
    }
}

public enum APIError: Error {
    case server
    case client
    case parseError

    var message: String {
        switch self {
        case .server:
            return "api 服务出错"
        case .client:
            return "端侧网络出错"
        case .parseError:
            return "网络出错"
        }
    }
}
