//
//  APIAuthInterceptor.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/04.
//

import Foundation
import Alamofire

class APIAuthInterceptor: RequestInterceptor {
    let retryLimit = 1

    init() {
        Self.getCsrfToken { _ in
            return
        }
    }

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var urlRequest = urlRequest
        if let token = APITokenStorage.shared.token {
            urlRequest.setValue(token, forHTTPHeaderField: "X-CSRFToken")
        }

        completion(.success(urlRequest))
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode != 401 && response.statusCode != 404 else {
            return completion(.doNotRetryWithError(error))
        }

        Self.getCsrfToken { result in
            switch result {
            case .success:
                if request.retryCount < self.retryLimit {
                    completion(.retry)
                }
                completion(.doNotRetry)
            case .failure(let error):
                completion(.doNotRetryWithError(error))
            }
        }
    }

    static func getCsrfToken(_ completion: @escaping (_ result: Result<String?, Error>) -> Void) {
        AF.request(Constants.apiurl + "auth/login/").validate()
            .responseData(queue: .global(qos: .userInitiated)) { response in
                var result: Result<String?, Error>?

                switch response.result {
                case .success:
                    if let headerFields = response.response?.allHeaderFields as? [String: String] {
                        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields,
                                                         for: response.request!.url!)
                        result = .failure(APIError.cookieNotFound)
                        for cookie in cookies where cookie.name == "csrftoken" {
                            result = .success(cookie.value)
                            APITokenStorage.shared.token = cookie.value
                        }
                    }
                case .failure(let error):
                    result = .failure(error)
                    print(error.localizedDescription)
                }

                completion(result!)
            }.resume()
    }
}
