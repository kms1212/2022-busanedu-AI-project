//
//  APIRequestManager.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/04.
//

import Foundation
import Alamofire

class APIRequestManager {
    static let session: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 10

        let interceptor = APIAuthInterceptor()

        return Session(
            configuration: configuration,
            interceptor: interceptor)
    }()
}
