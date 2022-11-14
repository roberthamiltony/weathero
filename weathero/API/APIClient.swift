//
//  APIClient.swift
//  weathero
//
//  Created by Robert Hamilton on 05/11/2022.
//

import Foundation
import Combine

protocol APIClient {
    func perform<T: APIRequest>(request: T, completion: @escaping ((Result<T.Response, Error>) -> Void))
}

extension APIClient {
    func perform<T>(request: T) -> Future<T.Response, Error> where T: APIRequest {
        Future { [self] promise in
            perform(request: request) { promise($0) }
        }
    }
}

protocol APIRequest {
    associatedtype Response: Decodable
    var resource: String { get }
    var queries: [URLQueryItem] { get }
    var method: String { get }
    var body: Data? { get }
    var headers: [String: String?]? { get }
}

extension APIRequest {
    var queries: [URLQueryItem] { [] }
    var method: String { "GET" }
    var body: Data? { nil }
    var headers: [String: String?]? { nil }
}

enum APIError: Error {
    case jsonError
    case responseError(String)
    case titleBodyResponseError(String, String)
    case codeResponseError(String, String)
    case requestError
    case dataError
}
