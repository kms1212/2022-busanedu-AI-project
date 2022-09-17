//
//  LoadableValue.swift
//  iosApp
//
//  Created by 권민수 on 2022/08/10.
//

import Foundation

enum LoadableValue<T> {
    case success(T)
    case failure(Error)
    case loading
    case waiting
}

extension LoadableValue {
    init(_ from: Result<T, Error>) {
        switch from {
        case .success(let val):
            self = .success(val)
        case .failure(let err):
            self = .failure(err)
        }
    }

    init() {
        self = .waiting
    }

    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }

    var isFailure: Bool {
        switch self {
        case .failure:
            return true
        default:
            return false
        }
    }

    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }

    var isWaiting: Bool {
        switch self {
        case .waiting:
            return true
        default:
            return false
        }
    }

    var getData: T? {
        switch self {
        case .success(let data):
            return data
        default:
            return nil
        }
    }
}
