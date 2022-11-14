//
//  WeatherAPIClient.swift
//  weathero
//
//  Created by Robert Hamilton on 05/11/2022.
//

import Foundation
import CocoaLumberjackSwift

class WeatherAPIClient: APIClient {
    let session = URLSession.shared
    // TODO: This should be in a proxy service
    private var secretKey: String = ""
    var basePath = "weatherkit.apple.com"
    
    func perform<T>(request: T, completion: @escaping ((Result<T.Response, Error>) -> Void)) where T : APIRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = basePath
        components.path = request.resource
        components.queryItems = request.queries.filter { $0.value != nil }
        guard let url = components.url else {
            completion(.failure(APIError.requestError))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = request.body
        urlRequest.httpMethod = request.method
        urlRequest.setValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
        DDLogInfo("Running request: \(urlRequest)")
        session.dataTask(with: urlRequest) { data, response, error in
            let httpUrlResponse = response as? HTTPURLResponse
            if let statusCode = httpUrlResponse?.statusCode {
                DDLogInfo("PR API response status code: \(statusCode)")
            } else {
                DDLogInfo("PR API response status code: None")
            }
            guard let data = data else {
                completion(.failure(APIError.responseError("No data provided")))
                return
            }
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let model = try decoder.decode(T.Response.self, from: data)
                completion(.success(model))
            } catch let error {
                completion(.failure(error))
            }
        }.resume()
    }
}
