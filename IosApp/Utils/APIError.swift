//
//  APIError.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/04.
//

import Foundation

enum APIError: Error {
    case cookieNotFound
    case notExpectedValue
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cookieNotFound:
            return "Cookie not found."
        case .notExpectedValue:
            return "Unexpected value is returned"
        }
    }
}
